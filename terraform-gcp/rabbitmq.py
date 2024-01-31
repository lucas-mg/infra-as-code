import pika

# Replace with the actual RabbitMQ server address and credentials
rabbitmq_address = "<RABBITMQ_SERVER_ADDRESS>"
credentials = pika.PlainCredentials(username="<USERNAME>", password="<PASSWORD>")
connection_params = pika.ConnectionParameters(rabbitmq_address, 5672, "/", credentials)

connection = pika.BlockingConnection(connection_params)
channel = connection.channel()

# Declare a queue named 'my_queue'
channel.queue_declare(queue='my_queue')

connection.close()
