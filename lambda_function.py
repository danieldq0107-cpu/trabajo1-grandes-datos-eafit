import json
import time
import boto3
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("trabajo1-flight-events-db")

REQUIRED_FIELDS = ["event_id", "sent_at_ms", "flight_number", "origin", "dest"]

def lambda_handler(event, context):
    processed = 0
    discarded = 0

    for record in event.get("Records", []):
        try:
            body = json.loads(record["body"])
            missing = [f for f in REQUIRED_FIELDS if body.get(f) in (None, "")]

            if missing:
                discarded += 1
                print(json.dumps({
                    "status": "DISCARDED",
                    "reason": f"Missing fields: {', '.join(missing)}",
                    "event": body
                }))
                continue

            sent_at_ms = int(body["sent_at_ms"])
            processed_at_ms = int(time.time() * 1000)
            latency_ms = max(0, processed_at_ms - sent_at_ms)

            item = {
                "event_id": str(body["event_id"]),
                "sent_at_ms": sent_at_ms,
                "processed_at_ms": processed_at_ms,
                "latency_ms": latency_ms,
                "flight_number": str(body["flight_number"]),
                "origin": str(body["origin"]),
                "dest": str(body["dest"]),
                "status": str(body.get("status", "UNKNOWN")),
                "delay_minutes": Decimal(str(body.get("delay_minutes", 0)))
            }

            table.put_item(Item=item)
            processed += 1

            print(json.dumps({
                "status": "STORED",
                "event_id": item["event_id"],
                "latency_ms": latency_ms
            }))

        except Exception as e:
            discarded += 1
            print(json.dumps({
                "status": "DISCARDED",
                "reason": str(e),
                "raw_body": record.get("body")
            }))

    return {"statusCode": 200, "processed": processed, "discarded": discarded}
