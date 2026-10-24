import boto3
import json
import random
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

ENDPOINT = "https://a1hk5rmogool6r-ats.iot.us-east-1.amazonaws.com"
TOPIC = "trabajo1/flights"

client = boto3.client("iot-data", region_name="us-east-1", endpoint_url=ENDPOINT)

random.seed(42)
airports = ["ATL", "JFK", "MIA", "ORD", "LAX", "DFW", "DEN", "SFO"]
airlines = ["AA", "DL", "UA", "WN", "B6", "NK"]

run_id = str(int(time.time()))
events = []

for i in range(10000):
    origin = random.choice(airports)
    dest = random.choice([a for a in airports if a != origin])
    delay = random.randint(0, 90)
    events.append({
        "event_id": f"{run_id}-V-{i:05d}",
        "sent_at_ms": None,
        "flight_number": f"{random.choice(airlines)}{random.randint(100, 9999)}",
        "origin": origin,
        "dest": dest,
        "status": "DELAYED" if delay >= 15 else "ON_TIME",
        "delay_minutes": delay
    })

for i in range(10):
    events.append({
        "event_id": f"{run_id}-X-ORIGIN-{i:02d}",
        "sent_at_ms": None,
        "flight_number": f"TEST{i}",
        "dest": "JFK",
        "status": "ON_TIME",
        "delay_minutes": 0
    })

for i in range(10):
    events.append({
        "event_id": f"{run_id}-X-TIME-{i:02d}",
        "flight_number": f"TESTX{i}",
        "origin": "ATL",
        "dest": "JFK",
        "status": "ON_TIME",
        "delay_minutes": 0
    })

def publish_event(event):
    event = dict(event)
    if "sent_at_ms" in event:
        event["sent_at_ms"] = int(time.time() * 1000)

    for attempt in range(3):
        try:
            client.publish(
                topic=TOPIC,
                qos=0,
                payload=json.dumps(event).encode("utf-8")
            )
            return True
        except Exception:
            if attempt == 2:
                return False
            time.sleep(0.2)

success = 0
failed = 0

with ThreadPoolExecutor(max_workers=20) as executor:
    futures = [executor.submit(publish_event, e) for e in events]
    for future in as_completed(futures):
        if future.result():
            success += 1
        else:
            failed += 1

print("RUN_ID:", run_id)
print("PUBLICADOS_ACEPTADOS:", success)
print("FALLOS_PUBLICACION:", failed)
print("TOTAL_INTENTADOS:", len(events))
