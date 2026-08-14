import json
import random
import time
from datetime import datetime

from kafka import KafkaProducer


producer = KafkaProducer(
    bootstrap_servers="localhost:9094",
    value_serializer=lambda value: json.dumps(value).encode("utf-8"),
)

while True:
    sensor_data = {
        "sensor_id": f"sensor_{random.randint(1, 5)}",
        "temperature": round(random.uniform(15, 35), 2),
        "humidity": round(random.uniform(30, 90), 2),
        "air_quality_index": random.randint(20, 150),
        "timestamp": datetime.now().isoformat(),
    }

    producer.send("urban_sensors", value=sensor_data)

    print(f"Enviado: {sensor_data}")
    time.sleep(2)