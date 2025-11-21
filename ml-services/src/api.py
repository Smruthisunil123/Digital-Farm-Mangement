from flask import Flask, request, jsonify
# ✅ THE FIX: Import the new, powerful functions from your chatbot_model
from chatbot_model import process_scan_and_speak, get_chat_response, calculate_withdrawal
import base64

app = Flask(__name__)

# ✅ NEW FEATURE: The Scan-to-Speak endpoint
# ... existing imports ...

@app.route('/scan-and-speak', methods=['POST'])
def scan_and_speak_endpoint():
    data = request.get_json()
    # ✅ FIX 1: Require and get the farmerId from the JSON body
    if not data or 'image' not in data or 'farmerId' not in data: 
        return jsonify({"error": "Missing image or farmer ID"}), 400
    
    try:
        image_bytes = base64.b64decode(data['image'])
        farmer_id = data['farmerId'] # Get the dynamic ID
        
        # ✅ FIX 2: Pass the dynamic ID to the logic function
        audio_base64 = process_scan_and_speak(image_bytes, farmer_id=farmer_id)
        
        if not audio_base64:
             return jsonify({"error": "Could not process the request."}), 500

        return jsonify({"audio": audio_base64})
    except Exception as e:
        print(f"Error in /scan-and-speak: {e}")
        return jsonify({"error": str(e)}), 500

# ... rest of api.py ...

# ✅ UPDATED: The general chatbot endpoint
@app.route('/chat', methods=['POST'])
def chat_endpoint():
    """ Handles general chatbot queries in local language. """
    data = request.get_json()
    if not data or 'query' not in data:
        return jsonify({"error": "No query provided"}), 400
        
    query = data['query']
    role = data.get('role', 'farmer')
    
    # This function now handles translation and speech
    response_text, response_audio_base64 = get_chat_response(query, role)
    
    return jsonify({
        "text_response": response_text,
        "audio_response": response_audio_base64,
    })

@app.route('/calculate-withdrawal', methods=['POST'])
def calculate_withdrawal_endpoint():
    data = request.get_json()
    if not data or 'medications' not in data:
        return jsonify({"error": "No medications list provided"}), 400
    
    medications = data['medications']
    
    try:
        # ✅ This will now work because we imported the function
        days = calculate_withdrawal(medications)
        return jsonify({"withdrawal_days": days})
    except Exception as e:
        print(f"Error calculating withdrawal: {e}")
        return jsonify({"withdrawal_days": 0})
        
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)