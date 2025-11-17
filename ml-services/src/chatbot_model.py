import base64
import pytesseract
import cv2
import numpy as np
import requests
from google.cloud import translate_v2 as translate
from google.cloud import texttospeech
import re
from fuzzywuzzy import process

# --- New Imports for RAG (AI Advisor) ---
from langchain_community.llms import Ollama
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import OllamaEmbeddings
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

# --- Configuration (Your existing config) ---
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

# --- RAG (AI Advisor) Setup ---
# This code runs ONCE when the server starts
print("Loading AI Advisor 'Brain' (Ollama + ChromaDB)...")
DB_DIR = "vector_db"
# 1. Initialize the "reading" model
embeddings = OllamaEmbeddings(model="mxbai-embed-large")
# 2. Load the "memory" from the database we built
vectordb = Chroma(persist_directory=DB_DIR, embedding_function=embeddings)
# 3. Initialize the "thinking" model (the small one we downloaded)
llm = Ollama(model="phi3:mini")
# 4. Create the retriever (the tool that finds documents)
retriever = vectordb.as_retriever(search_kwargs={"k": 3}) # Get top 3 results

# 5. Create the prompt template
template = """
You are a helpful farm assistant. Answer the user's question based ONLY on the following context.
If the context doesn't contain the answer, say "I'm sorry, I don't have that information in my knowledge base."

Context: {context}

Question: {question}
"""
prompt = ChatPromptTemplate.from_template(template)
output_parser = StrOutputParser()

# 6. Create the final RAG "chain"
rag_chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | llm
    | output_parser
)
print("--- AI Advisor 'Brain' loaded successfully. ---")
# --- End of RAG Setup ---


# --- Your existing (and correct) helper functions ---
def _translate_text(text, target_language="kn"):
    return TRANSLATE_CLIENT.translate(text, target_language=target_language)["translatedText"]

def _text_to_speech_audio(text, language_code="kn-IN"):
    synthesis_input = texttospeech.SynthesisInput(text=text)
    voice = texttospeech.VoiceSelectionParams(language_code=language_code, ssml_gender=texttospeech.SsmlVoiceGender.NEUTRAL)
    audio_config = texttospeech.AudioConfig(audio_encoding=texttospeech.AudioEncoding.MP3)
    response = TTS_CLIENT.synthesize_speech(input=synthesis_input, voice=voice, audio_config=audio_config)
    return response.audio_content

# --- Your existing (and correct) Scan-to-Speak function ---
# NO CHANGES HAVE BEEN MADE TO THIS FUNCTION
def process_scan_and_speak(image_bytes: bytes, farmer_id: str):
    np_arr = np.frombuffer(image_bytes, np.uint8)
    image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    ocr_text = pytesseract.image_to_string(gray_image).lower()
    print(f"\n--- OCR DIAGNOSTIC ---")
    print(f"[DEBUG] Tesseract raw output: '{ocr_text.strip()}'")
    
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
        translated_text = _translate_text("I scanned the image, but I could not find a clear match in your recent history.")
        audio_bytes = _text_to_speech_audio(translated_text)
        return base64.b64encode(audio_bytes).decode('utf-8')

    med_name = found_medication.get('medicationName', 'Unknown')
    dosage = found_medication.get('dosage', 'not specified')
    frequency = found_medication.get('frequency', [])
    animal_id = found_prescription_doc.get('animalTagId', 'the animal')
    
    translated_animal_id = animal_id
    match = re.match(r"([a-z]+)(\d+)", animal_id, re.IGNORECASE)
    if match:
        animal_type, animal_number = match.groups()
        translated_type = ANIMAL_TRANSLATIONS.get(animal_type.lower(), animal_type)
        translated_animal_id = f"{translated_type} {animal_number}"

    frequency_text = "as directed"
    if frequency:
        frequency_text = "in the " + " and ".join(frequency) + "."

    kannada_med_name = _translate_text(med_name)
    kannada_dosage = _translate_text(dosage)
    kannada_frequency = _translate_text(frequency_text)
    
    kannada_response = f"{translated_animal_id}ಗಾಗಿ, ಔಷಧಿ {kannada_med_name}. ಡೋಸೇಜ್ {kannada_dosage}, ಇದನ್ನು {kannada_frequency} ನೀಡಬೇಕು."

    audio_bytes = _text_to_speech_audio(kannada_response)
    return base64.b64encode(audio_bytes).decode('utf-8')

# --- ✅ NEW, UPGRADED CHATBOT FUNCTION ---
def get_chat_response(query: str, role: str):
    """
    Handles general queries using the RAG AI Advisor.
    """
    print(f"RAG Chatbot received query: '{query}' from role: '{role}'")
    
    try:
        # 1. Translate the user's query to English (for the LLM)
        original_language = "kn" # We assume Kannada for now
        
        # Check if the query is already English
        detected = TRANSLATE_CLIENT.detect_language(query)
        if detected['language'] != 'en':
            original_language = detected['language']
            english_query = TRANSLATE_CLIENT.translate(query, target_language="en")["translatedText"]
        else:
            english_query = query
        
        print(f"Translated query for LLM: {english_query}")

        # 2. Get an expert answer from the RAG system
        english_response = rag_chain.invoke(english_query)
        print(f"LLM Response (English): {english_response}")

        # 3. Translate the English answer back to the user's original language
        final_text_response = _translate_text(english_response, target_language=original_language)
        
        # 4. Convert the final text to speech in that language
        audio_bytes = _text_to_speech_audio(final_text_response, language_code=original_language)
        audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')
        
        return final_text_response, audio_base64
        
    except Exception as e:
        print(f"Error in RAG chain: {e}")
        error_text = "I'm sorry, I had an error connecting to the AI brain."
        # Fallback response
        kannada_response = _translate_text(error_text)
        audio_bytes = _text_to_speech_audio(kannada_response)
        audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')
        return kannada_response, audio_base64