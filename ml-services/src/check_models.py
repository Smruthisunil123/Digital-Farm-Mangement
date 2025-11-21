import google.generativeai as genai
import os

# 🔑 PASTE YOUR API KEY HERE DIRECTLY
GEMINI_API_KEY = "AIzaSyCy7ovbKc-oZ1GiGKlUyTUm2HejY8MVP2c"
genai.configure(api_key=GEMINI_API_KEY)

print("Listing available models...")
try:
    for m in genai.list_models():
        if 'generateContent' in m.supported_generation_methods:
            print(f"- {m.name}")
except Exception as e:
    print(f"Error: {e}")