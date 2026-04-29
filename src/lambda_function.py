"""
LUIT Serverless API — Lambda handler.

Routes (proxied via API Gateway HTTP API v2):
  GET    /items          -> list items
  POST   /items          -> create item   (body: {"id": "...", "name": "..."})
  GET    /items/{id}     -> read one item
  PUT    /items/{id}     -> update item
  DELETE /items/{id}     -> delete item

Structured JSON logs go straight to CloudWatch.
DynamoDB table name comes from the TABLE_NAME env var (set by Terraform).
"""

import json
import logging
import os
import uuid
from decimal import Decimal

import boto3
from botocore.exceptions import ClientError

LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO").upper()
TABLE_NAME = os.environ["TABLE_NAME"]
ENV = os.environ.get("ENV", "dev")

logger = logging.getLogger()
logger.setLevel(LOG_LEVEL)

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)


class DecimalEncoder(json.JSONEncoder):
    """DynamoDB returns numbers as Decimal — JSON can't serialize that natively."""

    def default(self, o):
        if isinstance(o, Decimal):
            return int(o) if o % 1 == 0 else float(o)
        return super().default(o)


def _response(status: int, body) -> dict:
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body, cls=DecimalEncoder),
    }


def _log(level: str, message: str, **kwargs) -> None:
    payload = {"level": level, "message": message, "env": ENV, **kwargs}
    getattr(logger, level.lower())(json.dumps(payload))


def list_items() -> dict:
    resp = table.scan(Limit=100)
    return _response(200, {"items": resp.get("Items", [])})


def get_item(item_id: str) -> dict:
    resp = table.get_item(Key={"pk": f"ITEM#{item_id}", "sk": "META"})
    item = resp.get("Item")
    if not item:
        return _response(404, {"error": "not found", "id": item_id})
    return _response(200, item)


def create_item(body: dict) -> dict:
    item_id = body.get("id") or str(uuid.uuid4())
    name = body.get("name")
    if not name:
        return _response(400, {"error": "name is required"})

    item = {
        "pk": f"ITEM#{item_id}",
        "sk": "META",
        "gsi1pk": "ITEMS",
        "id": item_id,
        "name": name,
    }
    table.put_item(Item=item)
    _log("info", "item_created", item_id=item_id)
    return _response(201, item)


def update_item(item_id: str, body: dict) -> dict:
    name = body.get("name")
    if not name:
        return _response(400, {"error": "name is required"})

    try:
        resp = table.update_item(
            Key={"pk": f"ITEM#{item_id}", "sk": "META"},
            UpdateExpression="SET #n = :n",
            ExpressionAttributeNames={"#n": "name"},
            ExpressionAttributeValues={":n": name},
            ConditionExpression="attribute_exists(pk)",
            ReturnValues="ALL_NEW",
        )
    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            return _response(404, {"error": "not found", "id": item_id})
        raise

    return _response(200, resp["Attributes"])


def delete_item(item_id: str) -> dict:
    table.delete_item(Key={"pk": f"ITEM#{item_id}", "sk": "META"})
    return _response(204, {})


def lambda_handler(event, context):
    method = event.get("requestContext", {}).get("http", {}).get("method", "GET")
    path = event.get("rawPath", "/")
    item_id = (event.get("pathParameters") or {}).get("id")

    _log("info", "request", method=method, path=path, item_id=item_id)

    try:
        body = json.loads(event["body"]) if event.get("body") else {}
    except json.JSONDecodeError:
        return _response(400, {"error": "invalid JSON body"})

    if path == "/items" and method == "GET":
        return list_items()
    if path == "/items" and method == "POST":
        return create_item(body)
    if item_id and method == "GET":
        return get_item(item_id)
    if item_id and method == "PUT":
        return update_item(item_id, body)
    if item_id and method == "DELETE":
        return delete_item(item_id)

    return _response(404, {"error": "route not found", "path": path, "method": method})
