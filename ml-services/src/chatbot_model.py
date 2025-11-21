import base64
import pytesseract
import cv2
import numpy as np
import requests
from google.cloud import translate_v2 as translate
from google.cloud import texttospeech
import re
from fuzzywuzzy import process
import google.generativeai as genai
import os

# --- Configuration ---
NODE_API_URL = "http://localhost:3001/api/v1"
TRANSLATE_CLIENT = translate.Client()
TTS_CLIENT = texttospeech.TextToSpeechClient()

# 🔑 PASTE YOUR API KEY HERE
GEMINI_API_KEY = "AIzaSyCy7ovbKc-oZ1GiGKlUyTUm2HejY8MVP2c"
genai.configure(api_key=GEMINI_API_KEY)

# Using the model that worked for you
gemini_model = genai.GenerativeModel('gemini-2.0-flash')

ANIMAL_TRANSLATIONS = {
    "cow": "ಹಸು", "buff": "ಎಮ್ಮೆ", "hen": "ಕೋಳಿ", "dog": "ನಾಯಿ", "cat": "ಬೆಕ್ಕು"
}

# --- Helper Functions ---
def _read_medication_guide():
    """Reads the text file directly to use as knowledge."""
    try:
        # Look for the file in the knowledge_base folder
        # Adjust path if necessary based on where you run the script from
        file_path = os.path.join("knowledge_base", "medication_withdrawal_guide.txt")
        
        # Fallback check for path if running from root
        if not os.path.exists(file_path):
             file_path = os.path.join("ml-services", "knowledge_base", "medication_withdrawal_guide.txt")
             
        if os.path.exists(file_path):
            with open(file_path, "r") as f:
                return f.read()
        return "No medication guide found."
    except Exception as e:
        print(f"Error reading guide: {e}")
        return ""

def _translate_text(text, target_language="kn"):
    try:
        return TRANSLATE_CLIENT.translate(text, target_language=target_language)["translatedText"]
    except:
        return text

def _text_to_speech_audio(text, language_code="kn-IN"):
    synthesis_input = texttospeech.SynthesisInput(text=text)
    voice = texttospeech.VoiceSelectionParams(language_code=language_code, ssml_gender=texttospeech.SsmlVoiceGender.NEUTRAL)
    audio_config = texttospeech.AudioConfig(audio_encoding=texttospeech.AudioEncoding.MP3)
    response = TTS_CLIENT.synthesize_speech(input=synthesis_input, voice=voice, audio_config=audio_config)
    return response.audio_content

# --- Feature 1: Scan-to-Speak ---
def process_scan_and_speak(image_bytes: bytes, farmer_id: str):
    np_arr = np.frombuffer(image_bytes, np.uint8)
    image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    ocr_text = pytesseract.image_to_string(gray_image).lower()
    print(f"[DEBUG] OCR Text: {ocr_text.strip()}")
    
    try:
        response = requests.get(f"{NODE_API_URL}/prescriptions/history?farmerId={farmer_id}")
        history = response.json()
    except:
        return _text_to_speech_audio(_translate_text("Could not access history."))

    all_med_names = [med.get('medicationName') for pres in history for med in pres.get("medications", []) if med.get('medicationName')]
    best_match = process.extractOne(ocr_text, all_med_names)
    
    found_medication = None
    found_prescription_doc = None
    if best_match and best_match[1] > 70:
        matched_name = best_match[0]
        for pres in history:
            for med in pres.get("medications", []):
                if med.get('medicationName') == matched_name:
                    found_medication = med
                    found_prescription_doc = pres
                    break
            if found_medication: break
            
    if not found_medication:
        return base64.b64encode(_text_to_speech_audio(_translate_text("Medicine not found in history."))).decode('utf-8')

    med_name = found_medication.get('medicationName', 'Unknown')
    dosage = found_medication.get('dosage', 'not specified')
    frequency = found_medication.get('frequency', [])
    animal_id = found_prescription_doc.get('animalTagId', 'the animal')
    diagnosis = found_prescription_doc.get('diagnosis', 'condition')
    
    translated_animal_id = animal_id
    match = re.match(r"([a-z]+)(\d+)", animal_id, re.IGNORECASE)
    if match:
        animal_type, animal_number = match.groups()
        translated_type = ANIMAL_TRANSLATIONS.get(animal_type.lower(), animal_type)
        translated_animal_id = f"{translated_type} {animal_number}"

    frequency_text = "in the " + " and ".join(frequency) if frequency else "as directed"
    
    kannada_med_name = _translate_text(med_name)
    kannada_dosage = _translate_text(dosage)
    kannada_frequency = _translate_text(frequency_text)
    kannada_diagnosis = _translate_text(diagnosis)

    kannada_response = f"{translated_animal_id}ಗಾಗಿ, ರೋಗನಿರ್ಣಯ {kannada_diagnosis}. ಔಷಧಿ {kannada_med_name}. ಡೋಸೇಜ್ {kannada_dosage}, ಇದನ್ನು {kannada_frequency} ನೀಡಬೇಕು."
    
    return base64.b64encode(_text_to_speech_audio(kannada_response)).decode('utf-8')

# --- Feature 2: Chatbot (Gemini) ---
def get_chat_response(query: str, role: str):
    print(f"Chatbot query: '{query}'")
    try:
        # 1. Translate Input
        try:
             english_query = TRANSLATE_CLIENT.translate(query, target_language="en")["translatedText"]
        except:
             english_query = query

        # ✅ THE FIX: Initialize the variable with a default value BEFORE the 'if' block
        farmer_history_context = "No recent records found."

        # 2. Fetch History for Context
        if role == 'farmer':
            try:
                resp = requests.get(f"{NODE_API_URL}/prescriptions/history?farmerId=farmer123", timeout=2)
                if resp.status_code == 200:
                    farmer_history_context = str(resp.json())
            except: pass

        # 3. Ask Gemini
        prompt = f"""
        You are a veterinary assistant.
        User Question: "{english_query}"
        User History: {farmer_history_context}
        
        Instructions:
        1. If the user asks about a specific animal ID (like 'cow111'), look for it in 'User History'.
        2. Answering "what should [animal] take?": Find the medicine/dosage in history and tell them.
        3. If not found, give general advice.
        """
        
        gemini_response = gemini_model.generate_content(prompt)
        english_response = gemini_response.text
        english_response = re.sub(r'[\*\#]', '', english_response).strip()
        # 4. Translate & Speak Output
        kannada_response = _translate_text(english_response, target_language="kn")
        audio_bytes = _text_to_speech_audio(kannada_response, language_code="kn-IN")
        
        return kannada_response, base64.b64encode(audio_bytes).decode('utf-8')
        
    except Exception as e:
        print(f"Chatbot Error: {e}")
        return _translate_text("I am having trouble thinking right now."), ""

# --- Feature 3: Withdrawal (Gemini) ---
# ... existing imports and setup ...

# --- Feature 3: Withdrawal Calculation (Gemini + RAG) ---
def calculate_withdrawal(medications: list) -> int:
    med_list = ", ".join(medications)
    print(f"[AI Logic] Calculating withdrawal for: {med_list}")
    
    # ✅ FIX: Read the text file directly instead of using 'retriever'
    knowledge_base_text = _read_medication_guide()

    try:
        prompt = f"""
        You are a veterinary expert.
        
        REFERENCE DATA:
        {knowledge_base_text}
        
        TASK:
        The vet has prescribed: {med_list}.
        Based on the 'REFERENCE DATA' above, determine the withdrawal period (milk/meat) for EACH medicine.
        
        RULES:
        1. Compare the days for all medicines listed.
        2. Find the MAXIMUM (highest) number of days.
        3. CRITICAL: Return ONLY the integer number. (e.g., if the max is 7 days, return 7).
        4. If a medicine is not in the reference data, verify with general medical knowledge, but prioritize the reference.
        """
        
        result = gemini_model.generate_content(prompt)
        
        # Extract the number
        numbers = re.findall(r'\d+', result.text)
        if numbers:
            days = int(numbers[0])
            print(f"[AI Logic] Calculated Days: {days}")
            return days
        else:
            return 0
            
    except Exception as e:
        print(f"AI Calculation Error: {e}")
        return 0