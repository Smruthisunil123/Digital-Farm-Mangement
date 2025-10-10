import re

def get_chatbot_response(query: str, role: str) -> str:
    """
    Generates a response using a more scalable rule-based system.
    """
    query = query.lower()

    # Define rules as a list of dictionaries. This is easier to manage.
    # Each dictionary has keywords to look for and a response to give.
    farmer_rules = [
        {
            "keywords": ["dosage", "how much"],
            "response": "Based on the prescription, give 10ml twice a day for 5 days. Would you like me to set a reminder?"
        },
        {
            "keywords": ["withdrawal period", "withdrawal"],
            "response": "The withdrawal period for this medicine is 14 days for milk and 28 days for meat. Do not sell produce before this period ends."
        }
    ]

    vet_rules = [
        # You could add more vet-specific rules here
    ]

    # --- Logic to process the rules ---

    if role == 'farmer':
        for rule in farmer_rules:
            # Check if any of the rule's keywords are in the query
            if any(keyword in query for keyword in rule["keywords"]):
                return rule["response"]
        return "I can help with dosage and withdrawal periods. Please ask your question clearly."

    elif role == 'vet':
        if "history for" in query:
            animal_id = re.search(r'\d+', query)
            if animal_id:
                # In a real app, you would query the database here
                return f"Fetching prescription history for animal ID {animal_id.group(0)}..."
            else:
                return "Please provide an animal ID to fetch history."
        return "You can ask for animal medication history or search for prescriptions."

    # ... (other roles) ...

    else:
        return "I'm sorry, I don't recognize your role. How can I help?"