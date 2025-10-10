import base64
import pytesseract
from PIL import Image
from io import BytesIO
import cv2
import numpy as np

def extract_text_from_image(image_bytes: bytes) -> str:
    """
    Uses Tesseract OCR with a general-purpose page segmentation mode to find all text.
    """
    try:
        print("Preprocessing image for Tesseract OCR...")
        np_arr = np.frombuffer(image_bytes, np.uint8)
        image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # ✅ THE FIX: Use PSM '3' for automatic page segmentation.
        # This allows Tesseract to find all blocks of text automatically.
        custom_config = r'--oem 3 --psm 3'
        
        print("Processing preprocessed image with Tesseract using PSM 3...")
        
        extracted_text = pytesseract.image_to_string(gray_image, config=custom_config)
        
        print(f"Detected text with Tesseract: {extracted_text}")
        
        if not extracted_text.strip():
            return "No text found in the image."
            
        # We return the full text, preserving newlines
        return extracted_text

    except Exception as e:
        print(f"An error occurred in Tesseract OCR processing: {e}")
        return f"Error: {e}"