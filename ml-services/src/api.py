import base64 # Needed for decoding the image string
from flask import Flask, request, jsonify
# ✅ FIX 1: Use a direct import instead of a relative one
from ocr_processor import extract_text_from_image 
from chatbot_model import get_chatbot_response 

app = Flask(__name__)

@app.route('/ocr', methods=['POST'])
def process_ocr():
    """
    Endpoint to process an image and extract text.
    ✅ FIX 2: Expects JSON data with a base64 encoded 'image' string.
    """
    data = request.get_json()
    if not data or 'image' not in data:
        return jsonify({"error": "No image data provided in JSON body"}), 400
    
    # 1. Get the base64 string from the JSON payload
    base64_image_string = data['image']
    
    try:
        # 2. Decode the base64 string into image bytes
        image_bytes = base64.b64decode(base64_image_string)
    except Exception as e:
        return jsonify({"error": f"Invalid base64 data: {e}"}), 400

    # 3. Pass the image bytes to your ocr_processor function
    extracted_text = extract_text_from_image(image_bytes)
    
    if "Error:" in extracted_text:
        return jsonify({"error": extracted_text}), 500
        
    return jsonify({"text": extracted_text})

    # ✅ 2. ADD THE CHATBOT ENDPOINT LOGIC
@app.route('/chat', methods=['POST'])
def chat():
    """
    Endpoint to interact with the chatbot.
    """
    data = request.get_json()
    if not data or 'query' not in data or 'role' not in data:
        return jsonify({"error": "Missing 'query' or 'role' in request body"}), 400
        
    query = data['query']
    role = data['role']
    
    # Call the chatbot function to get a response
    response = get_chatbot_response(query, role)
    
    return jsonify({"response": response})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)