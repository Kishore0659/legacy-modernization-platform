import React, { useEffect, useState, useCallback } from "react";
import api from "./api/axiosConfig";
import Login from "./Login";
import { Button } from "@mui/material";
import Sidebar from "./components/Sidebar";
import { Routes, Route } from "react-router-dom";
import Users from "./pages/Users";
import Dashboard from "./pages/Dashboard"; // ✅ ADD THIS
import Topbar from "./components/Topbar"; // ✅ ADD THIS
import CustomerModal from "./components/CustomerModal";

const downloadCSV = (data) => {
  if (data.length === 0) return;

  // Headers defined by assignment requirements
  const headers = ["Customer Name", "Email", "Plan Name", "Status", "Start Date", "End Date"];
  
  const csvRows = data.map(cust => [
    `"${cust.customerName}"`,
    `"${cust.email}"`,
    `"${cust.planName}"`,
    `"${cust.subscriptionStatus}"`,
    cust.startDate,
    cust.endDate
  ].join(","));

  const csvContent = [headers.join(","), ...csvRows].join("\n");
  
  const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.setAttribute("href", url);
  link.setAttribute("download", "saas_customers_export.csv");
  link.style.visibility = 'hidden';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};
/* Inline Login component removed — using external `Login` from ./Login */
/* -----------------------------------------------------------
   2. MAIN APP COMPONENT
----------------------------------------------------------- */
function App() {
  const [openModal, setOpenModal] = useState(false);
  const [role, setRole] = useState(localStorage.getItem("role"));

  const [customers, setCustomers] = useState([]);
  const [paginationModel, setPaginationModel] = useState({
     page: 0,
     pageSize: 10, 
  } );
  // ===== STATS CALCULATION =====

  const [totalElements, setTotalElements] = useState(0);
  const totalSubscriptions = totalElements;

const activeUsers = customers.filter(
  (c) => c.subscriptionStatus === "ACTIVE"
).length;

const inactiveUsers = customers.filter(
  (c) => c.subscriptionStatus === "INACTIVE"
).length;

const trialUsers = customers.filter(
  (c) => c.subscriptionStatus === "TRIAL"
).length;

  const [loading, setLoading] = useState(false);
  const [status, setStatus] = useState("");
  const [search, setSearch] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");
const [planFilter, setPlanFilter] = useState(""); // State for Requirement #13
  const [emailError, setEmailError] = useState("");
  const [dateError, setDateError] = useState("");

  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({
    customerName: "", email: "", planName: "", subscriptionStatus: "ACTIVE", startDate: "", endDate: ""
  });

  const isAdmin = role === "ADMIN";

 useEffect(() => {
  const timer = setTimeout(() => {
    setDebouncedSearch(search);
    // CHANGE THIS LINE:
    setPaginationModel(prev => ({ ...prev, page: 0 })); 
  }, 500);
  return () => clearTimeout(timer);
}, [search]);

 const fetchCustomers = useCallback(async () => {
   const token = localStorage.getItem("token");
   if (!token) return;
   if (!role) return;
   try {
      const { page, pageSize } = paginationModel;
      let url = "/customers";

      // Logic to match your Specific Controller Endpoints
      if (debouncedSearch) {
        url += `/search?keyword=${debouncedSearch}&page=${page}&size=${pageSize}`;
      } else if (status && !planFilter) {
        url += `/status?status=${status}&page=${page}&size=${pageSize}`;
      } else if (status || planFilter) {
        url += `/sorted?page=${page}&size=${pageSize}&status=${status}&plan=${planFilter}`;
      } else {
        url += `/sorted?page=${page}&size=${pageSize}&sortBy=createdAt&direction=desc`;
      }

      const res = await api.get(url);
      setCustomers(res.data.content || []);
      setTotalElements(res.data.totalElements || 0);
    } catch (err) {
      console.error("Fetch error:", err);
    }
  }, [debouncedSearch, status, paginationModel, role, planFilter]);

  useEffect(() => { fetchCustomers(); }, [fetchCustomers]);

  const handleLogout = () => {
    localStorage.removeItem("role");
    setRole(null);
  };

  const deleteCustomer = async (id) => {
    if (!isAdmin) return;
    if (!id) return;
    if (window.confirm("Delete this customer?")) {
      await api.delete(`/customers/${id}`);
      fetchCustomers();
    }
  };

 const openAddCustomer = () => {
  setEditingId(null); // very important
  setFormData({
    customerName: "",
    email: "",
    planName: "",
    subscriptionStatus: "ACTIVE",
    startDate: "",
    endDate: "",
  });
  setOpenModal(true);
};

  const editCustomer = (cust) => {
  setEditingId(cust._id || cust.id);
  setFormData({
    ...cust,
    startDate: cust.startDate?.split("T")[0],
    endDate: cust.endDate?.split("T")[0],
  });
  setOpenModal(true);
};

const closeModal = () => {
  setOpenModal(false);
  setEditingId(null);
};

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    if (name === "email") setEmailError("");
    if (name === "startDate" || name === "endDate") setDateError("");
    setFormData({ ...formData, [name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!isAdmin) return;
    const now = new Date().toISOString();
    try {
      if (editingId) {
        await api.put(`/customers/${editingId}`, { ...formData, updatedAt: now });
      } else {
        await api.post(`/customers`, { ...formData, createdAt: now, updatedAt: now });
      }
      setEditingId(null);
      setFormData({ customerName: "", email: "", planName: "", subscriptionStatus: "ACTIVE", startDate: "", endDate: "" });
      // NEW CODE (Add this)
      setPaginationModel(prev => ({ ...prev, page: 0 }));
      fetchCustomers();
    } catch (error) {
      if (error.response?.data) {
        const msg = error.response.data;
        if (typeof msg === 'string' && msg.includes("Email already exists")) setEmailError("Email already in use.");
        else if (typeof msg === 'string' && msg.includes("End date must be after start date")) setDateError("Invalid date range.");
      }
    }
  };

  const columns = [
    { field: "customerName", headerName: "Name", flex: 1 },
    { field: "email", headerName: "Email", flex: 1.5 },
    { field: "planName", headerName: "Plan", flex: 1 },
    {
      field: "subscriptionStatus",
      headerName: "Status",
      flex: 1,
      renderCell: (params) => {
        const s = params.value;
        const colorClass = s === "ACTIVE" ? "bg-green-100 text-green-700" : s === "TRIAL" ? "bg-yellow-100 text-yellow-700" : "bg-red-100 text-red-700";
        return <span className={`px-3 py-1 rounded-full text-xs font-bold ${colorClass}`}>{s}</span>;
      }
    },
    { field: "startDate", headerName: "Start", flex: 1 },
    {
    field: "endDate",
    headerName: "End Date",
    flex: 1.2, // Increased slightly to fit the badge
    renderCell: (params) => {
      const today = new Date();
      const expiryDate = new Date(params.value);
      const diffTime = expiryDate - today;
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

      // Requirement #14: Alert logic (7 days threshold)
      const isExpiringSoon = diffDays <= 7 && diffDays > 0;
      
      return (
        <div className="flex items-center gap-2 h-full">
          <span className={isExpiringSoon ? "text-red-600 font-bold" : "text-gray-700"}>
            {params.value}
          </span>
          {isExpiringSoon && (
            <span className="animate-pulse bg-red-50 text-red-600 text-[9px] px-2 py-0.5 rounded-md border border-red-100 font-black">
              ALERT
            </span>
          )}
        </div>
      );
    }
  },
];

  // Only add the Actions column if the user is an ADMIN
  if (isAdmin) {
    columns.push({
      field: "actions",
      headerName: "Actions",
      flex: 1.2,
      renderCell: (params) => (
        <div className="flex gap-2">
          <Button size="small" variant="outlined" onClick={() => editCustomer(params.row)}>Edit</Button>
          <Button size="small" variant="outlined" color="error" onClick={() => deleteCustomer(params.row._id || params.row.id)}>Delete</Button>
        </div>
      )
    });
  }

  if (!role) return <Login onLogin={setRole} />;

return (
  <div className="flex h-screen bg-gray-100">
    {/* SIDEBAR ALWAYS VISIBLE */}
    <Sidebar
      search={search}
      setSearch={setSearch}
      customers={customers}
      onDownloadCSV={() => downloadCSV(customers)}
      onLogout={handleLogout}
    />

    {/* PAGE CONTENT */}
   <div className="flex-1 flex flex-col overflow-hidden">

  {/* 🔝 TOPBAR — ADD HERE */}
  <Topbar customers={customers} onLogout={handleLogout} />

  {/* PAGE CONTENT */}
  <div className="flex-1 p-6 overflow-y-auto">
    <Routes>

        {/* DASHBOARD */}
        <Route
          path="/"
          element={
            <div>
              <h1 className="text-2xl font-bold mb-6">Dashboard</h1>

              <div className="grid grid-cols-4 gap-6">
                <div className="bg-white p-6 rounded-xl shadow">
                  <p className="text-gray-400">Total</p>
                  <h2 className="text-3xl font-bold">{totalSubscriptions}</h2>
                </div>

                <div className="bg-white p-6 rounded-xl shadow">
                  <p className="text-gray-400">Active</p>
                  <h2 className="text-3xl font-bold text-green-600">
                    {activeUsers}
                  </h2>
                </div>

                <div className="bg-white p-6 rounded-xl shadow">
                  <p className="text-gray-400">Inactive</p>
                  <h2 className="text-3xl font-bold text-red-500">
                    {inactiveUsers}
                  </h2>
                </div>

                <div className="bg-white p-6 rounded-xl shadow">
                  <p className="text-gray-400">Trial</p>
                  <h2 className="text-3xl font-bold text-yellow-500">
                    {trialUsers}
                  </h2>
                </div>
              </div>
            </div>
          }
        />
        <Route
  path="/dashboard"
  element={<Dashboard customers={customers} />}
/>
<Route
  path="/users"
  element={
    <Users
      customers={customers}
      columns={columns}
      loading={loading}
      paginationModel={paginationModel}
      setPaginationModel={setPaginationModel}
      totalElements={totalElements}
      search={search}
      setSearch={setSearch}
      openAddCustomer={openAddCustomer} 
       status={status}
      setStatus={setStatus}
      planFilter={planFilter}
      setPlanFilter={setPlanFilter}
       isAdmin={isAdmin}
    />
  }
/>
    </Routes>
    </div>
        <CustomerModal
        open={openModal}
        onClose={closeModal}
        editingId={editingId}
        formData={formData}
        handleInputChange={handleInputChange}
        handleSubmit={handleSubmit}
        emailError={emailError}
        dateError={dateError}
      />

  </div>
  </div>
);
}

export default App;
