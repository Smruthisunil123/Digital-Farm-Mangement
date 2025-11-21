import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom'; // Assuming you use react-router
// import { loginAuthority } from '../api/authApi'; // You'll need this API function later

const AuthorityLogin = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      // Simulate API call - Replace this with your actual API call
      // const response = await loginAuthority(email, password);
      
      console.log("Logging in as Authority...");
      
      // Temporary check for demo purposes
      if(email.includes("gov") || email.includes("admin")) {
          // Redirect to the dashboard you showed me earlier
          navigate('/authority-dashboard'); 
      } else {
          setError("Access Denied: This portal is for Authority use only.");
      }

    } catch (err) {
      setError("Invalid Credentials or Server Error");
    }
  };

  return (
    <div className="d-flex align-items-center justify-content-center vh-100 bg-light">
      <div className="card shadow-lg" style={{ width: '400px', borderTop: '5px solid #0d6efd' }}>
        <div className="card-body p-5">
          
          <div className="text-center mb-4">
            <i className="bi bi-shield-lock-fill text-primary" style={{ fontSize: '3rem' }}></i>
            <h3 className="fw-bold mt-2">Authority Portal</h3>
            <p className="text-muted small">Government Oversight & Compliance</p>
          </div>

          {error && <div className="alert alert-danger p-2 small">{error}</div>}

          <form onSubmit={handleLogin}>
            <div className="mb-3">
              <label className="form-label fw-bold small">Official Email ID</label>
              <input 
                type="email" 
                className="form-control" 
                placeholder="officer@dept.gov.in"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>

            <div className="mb-4">
              <label className="form-label fw-bold small">Secure Password</label>
              <input 
                type="password" 
                className="form-control" 
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            <button type="submit" className="btn btn-primary w-100 fw-bold">
              Secure Login
            </button>
          </form>
          
          <hr className="my-4" />
          
          <div className="text-center">
            <a href="/login" className="text-decoration-none small text-secondary">
              &larr; Back to Farmer Login
            </a>
          </div>

        </div>
      </div>
    </div>
  );
};

export default AuthorityLogin;