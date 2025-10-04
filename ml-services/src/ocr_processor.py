# src/ocr_processor.py

from google.cloud import vision
from PIL import Image
import io

def extract_text_from_image(image_bytes: bytes) -> str:
    """
    Uses Google Cloud Vision API to extract text from an image.
    
    Args:
        image_bytes: The image file as a byte string.

    Returns:
        The extracted text as a single string.
    """
    try:
        client = vision.ImageAnnotatorClient()
        image = vision.Image(content=image_bytes)
        
        # Performs text detection on the image file
        response = client.text_detection(image=image)
        texts = response.text_annotations
        
        if response.error.message:
            raise Exception(f"Google Cloud Vision API Error: {response.error.message}")
            
        if texts:
            # The first text annotation is the full text block.
            return texts[0].description.replace('\n', ' ')
        else:
            return "No text found in the image."
            
    except Exception as e:
        print(f"An error occurred in OCR processing: {e}")
        return f"Error: {e}"