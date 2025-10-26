import base64
import pytesseract
import cv2
import numpy as np
import requests
from google.cloud import translate_v2 as translate
from google.cloud import texttospeech
import re
from fuzzywuzzy import process

# --- Configuration ---
NODE_API_URL = "http://localhost:3001/api/v1"
TRANSLATE_CLIENT = translate.Client()
TTS_CLIENT = texttospeech.TextToSpeechClient()

ANIMAL_TRANSLATIONS = {
    "cow": "ಹಸು",    # Hasu
    "buff": "ಎಮ್ಮೆ", # Emme (for buffalo)
    "hen": "ಕೋಳಿ",   # Koli
    "dog": "ನಾಯಿ",   # Nayi
    "cat": "ಬೆಕ್ಕು",  # Bekku
}

def _translate_text(text, target_language="kn"):
    return TRANSLATE_CLIENT.translate(text, target_language=target_language)["translatedText"]

def _text_to_speech_audio(text, language_code="kn-IN"):
    synthesis_input = texttospeech.SynthesisInput(text=text)
    voice = texttospeech.VoiceSelectionParams(language_code=language_code, ssml_gender=texttospeech.SsmlVoiceGender.NEUTRAL)
    audio_config = texttospeech.AudioConfig(audio_encoding=texttospeech.AudioEncoding.MP3)
    response = TTS_CLIENT.synthesize_speech(input=synthesis_input, voice=voice, audio_config=audio_config)
    return response.audio_content

def process_scan_and_speak(image_bytes: bytes, farmer_id: str):
    # This part of the code (OCR, history fetch, fuzzy matching) is already correct.
    np_arr = np.frombuffer(image_bytes, np.uint8)
    image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    ocr_text = pytesseract.image_to_string(gray_image).lower()
    
    try:
        response = requests.get(f"{NODE_API_URL}/prescriptions/history?farmerId={farmer_id}")
        response.raise_for_status()
        history = response.json()
        if not history:
            return _text_to_speech_audio(_translate_text("No prescription history found."))
    except Exception as e:
        return _text_to_speech_audio(_translate_text("Could not access prescription history."))

    all_med_names = [med.get('medicationName') for pres in history for med in pres.get("medications", []) if med.get('medicationName')]
    best_match = process.extractOne(ocr_text, all_med_names)
    
    found_medication = None
    found_prescription_doc = None
    if best_match and best_match[1] > 80:
        matched_name = best_match[0]
        for pres in history:
            for med in pres.get("medications", []):
                if med.get('medicationName') == matched_name:
                    found_medication = med
                    found_prescription_doc = pres
                    break
            if found_medication:
                break
    
    if not found_medication:
        translated_text = _translate_text("This medicine is not in your recent history.")
        audio_bytes = _text_to_speech_audio(translated_text)
        return base64.b64encode(audio_bytes).decode('utf-8')

    # --- Construct the response with the specific animal ID ---
    med_name = found_medication.get('medicationName', 'Unknown')
    dosage = found_medication.get('dosage', 'not specified')
    frequency = found_medication.get('frequency', [])
    animal_id = found_prescription_doc.get('animalTagId', 'the animal')
    
    # ✅ THE FIX: Separate the animal name from the number
    translated_animal_id = animal_id
    match = re.match(r"([a-z]+)(\d+)", animal_id, re.IGNORECASE)
    if match:
        animal_type, animal_number = match.groups()
        # Look up the translated type, or default to the English type
        translated_type = ANIMAL_TRANSLATIONS.get(animal_type.lower(), animal_type)
        translated_animal_id = f"{translated_type} {animal_number}"

    frequency_text = "as directed"
    if frequency:
        frequency_text = "in the " + " and ".join(frequency)

    # Translate the other parts of the sentence
    kannada_med_name = _translate_text(med_name)
    kannada_dosage = _translate_text(dosage)
    kannada_frequency = _translate_text(frequency_text)
    
    # Construct the final sentence in Kannada with the specific, translated ID
    kannada_response = f"{translated_animal_id}ಗಾಗಿ, ಔಷಧಿ {kannada_med_name}. ಡೋಸೇಜ್ {kannada_dosage}, ಇದನ್ನು {kannada_frequency} ನೀಡಬೇಕು."

    audio_bytes = _text_to_speech_audio(kannada_response)
    return base64.b64encode(audio_bytes).decode('utf-8')


def get_chat_response(query: str, role: str):
    # This function is correct and does not need changes.
    pass