# src/language_model.py

from gtts import gTTS
from io import BytesIO

def convert_text_to_speech(text: str, language_code: str = "en") -> bytes:
    """
    Synthesizes speech from the input string of text using the gTTS library.
    
    Args:
        text: The text to be converted to speech.
        language_code: The language code (e.g., 'en', 'hi' for Hindi).

    Returns:
        The audio content as a byte string in MP3 format.
    """
    try:
        # The gTTS library requires a language code like 'en' or 'hi'
        # We can take the first part of a code like 'en-US' if provided.
        lang = language_code.split('-')[0]

        # Create an in-memory binary stream
        mp3_fp = BytesIO()
        
        # Create the gTTS object
        tts = gTTS(text=text, lang=lang)
        
        # Write the synthesized audio to the in-memory file
        tts.write_to_fp(mp3_fp)
        
        # Get the byte value of the audio
        mp3_fp.seek(0)
        audio_bytes = mp3_fp.read()
        
        return audio_bytes
        
    except Exception as e:
        print(f"An error occurred during text-to-speech conversion: {e}")
        return b"" # Return empty bytes on error