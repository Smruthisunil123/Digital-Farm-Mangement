import axios from 'axios';

const API_URL = 'http://localhost:3001/api/v1';

// ... (getAuthorityAnalytics stays the same) ...

export const verifyProductSafety = async (productId) => {
  try {
    // Call the real endpoint that calculates dates based on Vet input
    // Note: 'prescriptions' matches the route we set up in backend
    const response = await axios.get(`${API_URL}/prescriptions/${productId}/verify`);
    return response.data;
  } catch (error) {
    console.error("Error verifying product:", error);
    // Return null or error state so UI knows lookup failed
    return null;
  }
};