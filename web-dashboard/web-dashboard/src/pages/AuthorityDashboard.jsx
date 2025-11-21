import React, { useEffect, useState } from 'react';
import { Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';
import { getAuthorityAnalytics } from '../api/dashboardApi';
ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

const AuthorityDashboard = () => {
  const [chartData, setChartData] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      const data = await getAuthorityAnalytics();
      setChartData(data);
    };
    fetchData();
  }, []);

  // Function to handle report generation
  const handleGenerateReport = () => {
    alert("Generating Regulatory Compliance Report... (Download started)");
    // In a real app, this would trigger a backend PDF generation endpoint
  };

  return (
    <div className="animate__animated animate__fadeIn mb-5">
      {/* Header with Report Button */}
      <div className="d-flex justify-content-between align-items-center mb-4">
        <h2 className="text-secondary"><i className="bi bi-building"></i> Authority Oversight Dashboard</h2>
        <button onClick={handleGenerateReport} className="btn btn-primary shadow-sm">
          <i className="bi bi-file-earmark-arrow-down"></i> Generate Monthly Report
        </button>
      </div>
      
      <div className="row">
        {/* Analytics Chart Section */}
        <div className="col-md-8 mb-4">
          <div className="card shadow-sm h-100">
            <div className="card-header bg-white fw-bold d-flex justify-content-between">
              <span>Monthly Antibiotic Usage Trends</span>
              <select className="form-select form-select-sm" style={{width: '150px'}}>
                <option>All Regions</option>
                <option>North District</option>
                <option>South District</option>
              </select>
            </div>
            <div className="card-body">
              {chartData ? (
                <Bar 
                  data={chartData} 
                  options={{
                    responsive: true,
                    plugins: { legend: { position: 'top' } },
                  }} 
                />
              ) : (
                <div className="text-center py-5">
                  <div className="spinner-border text-success" role="status"></div>
                  <p className="mt-2">Loading analytics...</p>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Sidebar Stats Section */}
        <div className="col-md-4">
          {/* Compliance Score Card */}
          <div className="card text-white bg-success mb-3 shadow-sm">
            <div className="card-body text-center">
              <h5 className="card-title">Overall Compliance</h5>
              <h1 className="display-3 fw-bold">94.2%</h1>
              <p className="card-text">Keep up the good work!</p>
            </div>
          </div>

          {/* Alerts Card */}
          <div className="card border-danger shadow-sm">
            <div className="card-header bg-danger text-white fw-bold">
              ⚠️ Critical Alerts
            </div>
            <ul className="list-group list-group-flush">
              <li className="list-group-item text-danger d-flex justify-content-between align-items-center">
                High Dosage: Batch #992
                <span className="badge bg-danger rounded-pill">Urgent</span>
              </li>
              <li className="list-group-item text-warning d-flex justify-content-between align-items-center">
                Withdrawal Violation: Farmer #452
                <span className="badge bg-warning text-dark rounded-pill">Review</span>
              </li>
              <li className="list-group-item text-secondary d-flex justify-content-between align-items-center">
                Unregistered Vet Access
                <span className="badge bg-secondary rounded-pill">Investigating</span>
              </li>
            </ul>
          </div>
        </div>
      </div>

      {/* NEW SECTION: Recent Audit Table */}
      <div className="row mt-2">
        <div className="col-12">
            <div className="card shadow-sm">
                <div className="card-header bg-light fw-bold">
                    📋 Recent Prescription Audits
                </div>
                <div className="table-responsive">
                    <table className="table table-hover mb-0">
                        <thead className="table-light">
                            <tr>
                                <th>Audit ID</th>
                                <th>Date</th>
                                <th>Veterinarian</th>
                                <th>Medicine</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>#AUD-2023-001</td>
                                <td>2023-10-12</td>
                                <td>Dr. A. Sharma</td>
                                <td>Amoxicillin</td>
                                <td><span className="badge bg-success">Compliant</span></td>
                                <td><button className="btn btn-sm btn-outline-secondary">View</button></td>
                            </tr>
                            <tr>
                                <td>#AUD-2023-002</td>
                                <td>2023-10-11</td>
                                <td>Dr. B. Verma</td>
                                <td>Enrofloxacin</td>
                                <td><span className="badge bg-warning text-dark">Pending Review</span></td>
                                <td><button className="btn btn-sm btn-outline-secondary">View</button></td>
                            </tr>
                            <tr>
                                <td>#AUD-2023-003</td>
                                <td>2023-10-10</td>
                                <td>Dr. K. Singh</td>
                                <td>Oxytetracycline</td>
                                <td><span className="badge bg-danger">Flagged</span></td>
                                <td><button className="btn btn-sm btn-outline-danger">Investigate</button></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
      </div>

    </div>
  );
};

export default AuthorityDashboard;