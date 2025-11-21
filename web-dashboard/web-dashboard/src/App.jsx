import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import AuthorityDashboard from './pages/AuthorityDashboard';
import ConsumerQRScan from './pages/ConsumerQRScan';

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
                <li className="nav-item">
                  <Link className="nav-link text-white" to="/authority">Authority Dashboard</Link>
                </li>
                <li className="nav-item">
                  <Link className="nav-link text-white" to="/verify/123">Consumer Scan (Demo)</Link>
                </li>
              </ul>
            </div>
          </div>
        </nav>

        {/* Main Content Container */}
        <div className="container">
          <Routes>
            <Route path="/authority" element={<AuthorityDashboard />} />
            <Route path="/verify/:id" element={<ConsumerQRScan />} />
            <Route path="/" element={
              <div className="text-center mt-5">
                <h1 className="display-4 text-success">Welcome to Digital Farm Management</h1>
                <p className="lead">Ensuring safer food through technology and traceability.</p>
                <Link to="/authority" className="btn btn-success btn-lg mt-3">Go to Dashboard</Link>
              </div>
            } />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;