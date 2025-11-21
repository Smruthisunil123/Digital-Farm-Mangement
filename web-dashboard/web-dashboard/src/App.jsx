import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';

// Page Imports
import AuthorityDashboard from './pages/AuthorityDashboard';
import AuthorityLogin from './pages/AuthorityLogin'; // <--- NEW IMPORT
import ConsumerQRScan from './pages/ConsumerQRScan';

// ... imports above

<Route path="/" element={
  <div className="text-center mt-5">
    <div className="mb-4">
      <span style={{fontSize: "4rem"}}>🚜</span>
    </div>
    <h1 className="display-4 text-success fw-bold">Welcome to Digital Farm Management</h1>
    <p className="lead text-secondary">Ensuring safer food through technology and blockchain traceability.</p>
    
    {/* PRIMARY BUTTONS */}
    <div className="d-flex justify-content-center gap-3 mt-4">
       {/* This button acts as your "Farmer Login" for now */}
       <Link to="/login" className="btn btn-primary btn-lg">
         Farmer / Vet Login
       </Link>
       
       <Link to="/verify/123" className="btn btn-outline-success btn-lg">
         Scan Product QR
       </Link>
    </div>

    {/* ⬇️ PASTE THE NEW SNIPPET HERE (Step 3) ⬇️ */}
    <div className="mt-5 pt-4 border-top w-50 mx-auto">
        <p className="small text-muted mb-2">Government & Regulatory Access</p>
        <Link to="/authority-login" className="btn btn-sm btn-outline-secondary">
            <i className="bi bi-shield-lock"></i> Access Authority Portal
        </Link>
    </div>
    {/* ⬆️ END OF NEW SNIPPET ⬆️ */}

  </div>
} />

function App() {
  return (
    <Router>
      <div>
        {/* Bootstrap Navbar */}
        <nav className="navbar navbar-expand-lg navbar-dark bg-success mb-4 shadow-sm">
          <div className="container">
            <Link className="navbar-brand fw-bold" to="/">🌱 Digital Farm Portal</Link>
            
            <button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
              <span className="navbar-toggler-icon"></span>
            </button>
            
            <div className="collapse navbar-collapse" id="navbarNav">
              <ul className="navbar-nav ms-auto">
                {/* Updated Link: Points to Login now, not Dashboard directly */}
                <li className="nav-item">
                  <Link className="nav-link text-white" to="/authority-login">
                    <i className="bi bi-shield-lock"></i> Authority Portal
                  </Link>
                </li>
                
                <li className="nav-item">
                  <Link className="nav-link text-white" to="/verify/123">
                    <i className="bi bi-qr-code-scan"></i> Consumer Scan (Demo)
                  </Link>
                </li>
              </ul>
            </div>
          </div>
        </nav>

        {/* Main Content Container */}
        <div className="container">
          <Routes>
            {/* 1. The Login Page (Entry Point for Officials) */}
            <Route path="/authority-login" element={<AuthorityLogin />} />

            {/* 2. The Dashboard (Protected Area) */}
            {/* Note: In a real app, you would wrap this in a PrivateRoute component */}
            <Route path="/authority-dashboard" element={<AuthorityDashboard />} />

            {/* 3. Consumer Public Page */}
            <Route path="/verify/:id" element={<ConsumerQRScan />} />

            {/* 4. Home Page */}
            <Route path="/" element={
              <div className="text-center mt-5">
                <div className="mb-4">
                  <span style={{fontSize: "4rem"}}>🚜</span>
                </div>
                <h1 className="display-4 text-success fw-bold">Welcome to Digital Farm Management</h1>
                <p className="lead text-secondary">Ensuring safer food through technology and blockchain traceability.</p>
                
                <div className="d-flex justify-content-center gap-3 mt-4">
                  {/* Updated Button: Goes to Login */}
                  <Link to="/authority-login" className="btn btn-outline-success btn-lg">
                    Login as Authority
                  </Link>
                  
                  {/* Added a secondary button for the consumer demo */}
                  <Link to="/verify/123" className="btn btn-success btn-lg">
                    Scan Product QR
                  </Link>
                </div>
              </div>
            } />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;