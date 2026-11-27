import { Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login/Login';
import Register from './pages/Register/Register';
import BranchOrders from './pages/BranchOrders/BranchOrders';
import CentralAdmin from './pages/CentralAdmin/CentralAdmin';

function App() {
  return (
    <Routes>
      <Route path="/" element={<Navigate to="/login" replace />} />
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      <Route path="/branch/orders" element={<BranchOrders />} />
      <Route path="/central" element={<CentralAdmin />} />
    </Routes>
  );
}

export default App;
