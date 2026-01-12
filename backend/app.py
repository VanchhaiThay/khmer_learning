from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import random

app = Flask(__name__)
CORS(app)

# Load your JSON dataset safely using UTF-8 encoding
with open("responses.json", encoding="utf-8") as f:
    data = json.load(f)

@app.route("/chat", methods=["POST"])
def chat():
    # Get the user's message
    msg = request.json.get("message", "").lower()
    reply = "Sorry, I don't understand."

    # Search through dataset for a matching pattern
    for intent in data["response"]:  # note: "response" not "responese"
        for pattern in intent["patterns"]:
            if msg == pattern.lower():  # exact match
                reply = random.choice(intent["responses"])
                break
        else:
            continue
        break

    return jsonify({"reply": reply})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
