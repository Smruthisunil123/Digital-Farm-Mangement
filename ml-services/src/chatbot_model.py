# src/chatbot_model.py

import re

def get_chatbot_response(query: str, role: str) -> str:
    """
    Generates a response based on the user's query and role.
    This is a simplified rule-based example.
    
    Args:
        query: The user's question.
        role: The role of the user (e.g., 'farmer', 'vet', 'consumer').

    Returns:
        A text response from the chatbot.
    """
    query = query.lower()

    if role == 'farmer':
        if "dosage" in query or "how much" in query:
            return "Based on the prescription, give 10ml twice a day for 5 days. Would you like me to set a reminder?"
        elif "withdrawal period" in query:
            return "The withdrawal period for this medicine is 14 days for milk and 28 days for meat. Do not sell produce before this period ends."
        else:
            return "I can help with dosage and withdrawal periods. Please ask your question clearly."

    elif role == 'vet':
        if "history for" in query:
            # Example: "get history for animal 123"
            animal_id = re.search(r'\d+', query)
            if animal_id:
                return f"Fetching prescription history for animal ID {animal_id.group(0)}..."
            else:
                return "Please provide an animal ID to fetch history."
        else:
            return "You can ask for animal medication history or search for prescriptions."

    elif role == 'consumer':
        if "is this product safe" in query:
            # In a real app, this would be backed by blockchain data 
            return "This product's withdrawal period was completed 5 days ago. It is verified safe for consumption."
        else:
            return "You can ask about the safety of this product by scanning its QR code."

    else:
        return "I'm sorry, I don't recognize your role. How can I help?"