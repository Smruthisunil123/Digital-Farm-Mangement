import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { verifyProductSafety } from '../api/dashboardApi';

const ConsumerQRScan = () => {
  const { id } = useParams();
  const [productStatus, setProductStatus] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  useEffect(() => {
    const checkSafety = async () => {
      const data = await verifyProductSafety(id);
      if (data) {
        setProductStatus(data);
      } else {
        setError(true);
      }
      setLoading(false);
    };
    checkSafety();
  }, [id]);

  if (loading) return (
    <div className="text-center mt-5">
      <div className="spinner-border text-primary" role="status"></div>
      <p className="mt-2">Verifying Vet Records...</p>
    </div>
  );

  if (error) return (
    <div className="text-center mt-5 text-danger">
      <h3>❌ Invalid Product ID</h3>
      <p>No record found for ID: {id}</p>
    </div>
  );

  return (
    <div className="row justify-content-center mt-4">
      <div className="col-md-6">
        <div className={`card shadow-lg border-0 ${productStatus.isSafe ? 'border-top border-success border-5' : 'border-top border-danger border-5'}`}>
          <div className="card-body text-center p-5">
            
            {/* Status Icon & Text */}
            {productStatus.isSafe ? (
              <>
                <div className="mb-3"><span style={{fontSize: '4rem'}}>✅</span></div>
                <h2 className="text-success fw-bold mb-3">Verified Safe</h2>
                <p className="text-muted">Withdrawal period complete. Safe for consumption.</p>
              </>
            ) : (
              <>
                <div className="mb-3"><span style={{fontSize: '4rem'}}>⛔</span></div>
                <h2 className="text-danger fw-bold mb-3">Not Safe</h2>
                <p className="text-danger fw-bold">
                    Wait {productStatus.daysRemaining} more days.
                </p>
                <p className="text-muted">Withdrawal period is still active.</p>
              </>
            )}

            <hr className="my-4" />

            {/* Details Table */}
            <div className="text-start">
              <h5 className="text-secondary mb-3">Prescription Details</h5>
              <table className="table table-borderless">
                <tbody>
                  <tr>
                    <th className="text-muted ps-0">Medicine Used:</th>
                    <td className="text-end fw-bold">{productStatus.productName}</td>
                  </tr>
                  <tr>
                    <th className="text-muted ps-0">Farmer ID:</th>
                    <td className="text-end">{productStatus.farmerName}</td>
                  </tr>
                  <tr>
                    <th className="text-muted ps-0">Safety Date:</th>
                    <td className="text-end text-primary">{productStatus.withdrawalEnds}</td>
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

export default ConsumerQRScan;