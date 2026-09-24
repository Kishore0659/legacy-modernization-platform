// src/pages/Users.js
import React from "react";
import { DataGrid } from "@mui/x-data-grid";

export default function Users({
  customers,
  columns,
  loading,
  paginationModel,
  setPaginationModel,
  totalElements,
  search,
  setSearch,
  status,
  setStatus,
  planFilter,
  setPlanFilter,
  openAddCustomer,
  isAdmin    
}) {

  return (
    <div className="space-y-6">
      {/* HEADER */}
      <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Customers</h1>
          <p className="text-sm text-slate-600 mt-1">Manage all customer subscriptions</p>
        </div>
        {isAdmin && (
          <button
            onClick={openAddCustomer}
            className="inline-flex items-center gap-2 bg-gradient-to-r from-indigo-500 to-blue-600 text-white px-6 py-2.5 rounded-lg font-semibold hover:from-indigo-600 hover:to-blue-700 transition shadow-lg"
          >
            <span>➕</span> Add Customer
          </button>
        )}
      </div>

      {/* SEARCH & FILTERS */}
      <div className="space-y-4">
        {/* SEARCH BAR */}
        <div className="relative">
          <div className="absolute inset-y-0 left-0 flex items-center pl-4 pointer-events-none">
            <span className="text-xl text-slate-400">🔍</span>
          </div>
          <input
            type="text"
            placeholder="Search by customer name or email..."
            className="w-full pl-12 pr-4 py-3 bg-white border border-slate-300 rounded-lg text-slate-900 placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        {/* FILTERS */}
        <div className="flex flex-col sm:flex-row gap-3">
          {/* STATUS FILTER */}
          <div className="flex-1 sm:flex-none">
            <select
              value={status}
              onChange={(e) => {
                setStatus(e.target.value);
                setPaginationModel(prev => ({ ...prev, page: 0 }));
              }}
              className="w-full px-4 py-2.5 bg-white border border-slate-300 rounded-lg text-slate-900 font-medium focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition"
            >
              <option value="">📊 All Status</option>
              <option value="ACTIVE">✅ Active</option>
              <option value="TRIAL">🔄 Trial</option>
              <option value="INACTIVE">⏸️ Inactive</option>
            </select>
          </div>

          {/* PLAN FILTER */}
          <div className="flex-1 sm:flex-none">
            <select
              value={planFilter}
              onChange={(e) => {
                setPlanFilter(e.target.value);
                setPaginationModel(prev => ({ ...prev, page: 0 }));
              }}
              className="w-full px-4 py-2.5 bg-white border border-slate-300 rounded-lg text-slate-900 font-medium focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition"
            >
              <option value="">💰 All Plans</option>
              <option value="FREE">Free</option>
              <option value="BASIC">Basic</option>
              <option value="PRO">Pro</option>
              <option value="ENTERPRISE">Enterprise</option>
            </select>
          </div>
        </div>
      </div>

      {/* TABLE */}
      <div className="bg-white rounded-xl shadow-lg overflow-hidden border border-slate-200">
        <div className="overflow-x-auto">
          <DataGrid
            rows={customers}
            columns={columns}
            getRowId={(row) => row._id || row.id}
            loading={loading}
            checkboxSelection={isAdmin}
            disableRowSelectionOnClick={!isAdmin}
            paginationMode="server"
            rowCount={totalElements}
            paginationModel={paginationModel}
            onPaginationModelChange={setPaginationModel}
            pageSizeOptions={[10, 25, 50]}
            autoHeight
            sx={{
              border: 0,
              "& .MuiDataGrid-columnHeaders": {
                backgroundColor: "#f1f5f9",
                fontWeight: "600",
                fontSize: "0.875rem",
                textTransform: "uppercase",
                letterSpacing: "0.05em",
                color: "#334155",
                borderBottomColor: "#e2e8f0",
              },
              "& .MuiDataGrid-cell": {
                borderBottomColor: "#f1f5f9",
                padding: "12px 16px",
              },
              "& .MuiDataGrid-row:hover": {
                backgroundColor: "#f8fafc",
              },
              "& .MuiDataGrid-footerContainer": {
                backgroundColor: "#f1f5f9",
                borderTopColor: "#e2e8f0",
              },
            }}
          />
        </div>
      </div>
    </div>
  );
}
