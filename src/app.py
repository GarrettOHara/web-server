from flask import Flask, request, send_file
import logging

app = Flask(__name__)

# Setup logging
logging.basicConfig(filename="requests.log", level=logging.INFO)


@app.route("/")
def home():
    # Log the headers part of the incoming request
    headers = request.headers
    logging.info(f"Headers: {headers}")

    # You could also extract and log specific header fields, for example:
    user_agent = request.headers.get("User-Agent")
    logging.info(f"User Agent: {user_agent}")

    # Log the remote IP address of the client
    client_ip = request.remote_addr
    logging.info(f"Client IP: {client_ip}")

    # Log other metadata as needed
    # ...

    return send_file("../templates/index.html")


if __name__ == "__main__":
    app.run(debug=True)
