import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    db_host = os.getenv('DB_HOST', 'localhost')
    env = os.getenv('APP_ENV', 'development')
    return jsonify({
        "status": "online",
        "message": "Hello from backend!",
        "environment": env,
        "connected_to_db_at": db_host
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
