# src/api.py

from flask import Flask, request, jsonify, send_file
from .ocr_processor import extract_text_from_image
from .chatbot_model import get_chatbot_response
from .language_model import convert_text_to_speech
import io

app = Flask(__name__)

@app.route('/')
def index():
    return "ML Services for Digital Farm Management Portal is running."

@app.route('/ocr', methods=['POST'])
def process_ocr():
    """
    Endpoint to process an image and extract text.
    Expects a multipart/form-data request with an 'image' file.
    """
    if 'image' not in request.files:
        return jsonify({"error": "No image file provided"}), 400
    
    image_file = request.files['image']
    image_bytes = image_file.read()
    
    extracted_text = extract_text_from_image(image_bytes)
    
    if "Error:" in extracted_text:
        return jsonify({"error": extracted_text}), 500
        
    return jsonify({"text": extracted_text})

@app.route('/chat', methods=['POST'])
def chat():
    """
    Endpoint to interact with the chatbot.
    Expects JSON data with 'query' and 'role'.
    """
    data = request.get_json()
    if not data or 'query' not in data or 'role' not in data:
        return jsonify({"error": "Missing 'query' or 'role' in request body"}), 400
        
    query = data['query']
    role = data['role']
    
    response = get_chatbot_response(query, role)
    
    return jsonify({"response": response})

@app.route('/tts', methods=['POST'])
def text_to_speech_endpoint():
    """
    Endpoint to convert text to speech.
    Expects JSON data with 'text' and 'language_code'.
    """
    data = request.get_json()
    if not data or 'text' not in data:
        return jsonify({"error": "Missing 'text' in request body"}), 400
        
    text = data['text']
    # Default to Hindi for this example, can be customized
    language_code = data.get('language_code', 'hi-IN') 
    
    audio_bytes = convert_text_to_speech(text, language_code)
    
    if not audio_bytes:
        return jsonify({"error": "Failed to generate audio"}), 500
        
    return send_file(io.BytesIO(audio_bytes), mimetype='audio/mpeg')

if __name__ == '__main__':
    # Running on 0.0.0.0 makes it accessible on your local network
    app.run(host='0.0.0.0', port=5001, debug=True)