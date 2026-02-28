"""Python example showing how to consume Avro events with Schema Registry."""

from confluent_kafka.avro import AvroConsumer


def main():
    conf = {
        'bootstrap.servers': 'localhost:9092',
        'group.id': 'test-group',
        'schema.registry.url': 'http://localhost:8081',
        'auto.offset.reset': 'earliest',
    }

    consumer = AvroConsumer(conf)
    consumer.subscribe(['dbserver1.public.customers'])

    try:
        while True:
            msg = consumer.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                print("Error: {}".format(msg.error()))
                continue

            print("Received message: key={}, value={}".format(msg.key(), msg.value()))
    except KeyboardInterrupt:
        pass
    finally:
        consumer.close()


if __name__ == '__main__':
    main()
