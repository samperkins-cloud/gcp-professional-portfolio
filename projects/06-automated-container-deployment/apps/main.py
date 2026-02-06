import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    name = os.environ.get("NAME", "World")
    return f"<h1>Hello, {name}!</h1><p>PULL REQUEST PREVIEW for PR: This change is from a PR and is deployed to a temporary URL!</p>"

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))