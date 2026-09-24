// src/pages/Dashboard.js
import React from "react";
import DashboardPieChart from "../components/dashboard/DashboardPieChart";

export default function Dashboard({ customers }) {
  const total = customers.length;
  const active = customers.filter(c => c.subscriptionStatus === "ACTIVE").length;
  const trial = customers.filter(c => c.subscriptionStatus === "TRIAL").length;
  const inactive = customers.filter(c => c.subscriptionStatus === "INACTIVE").length;

  // Calculate MRR (Monthly Recurring Revenue)
  const planValues = { FREE: 0, BASIC: 29, PRO: 99, ENTERPRISE: 299 };
  const mrr = customers.reduce((sum, c) => sum + (planValues[c.planName] || 0), 0);

  const StatCard = ({ icon, title, value, subtitle, gradient }) => (
    <div className={`bg-gradient-to-br ${gradient} rounded-xl shadow-lg p-6 text-white relative overflow-hidden`}>
      <div className="absolute -top-8 -right-8 w-32 h-32 bg-white/10 rounded-full blur-2xl"></div>
      <div className="relative">
        <div className="flex items-center justify-between mb-4">
          <span className="text-4xl">{icon}</span>
          <div className="text-right">
            <p className="text-xs font-semibold text-white/70 uppercase tracking-wide">{title}</p>
            <h2 className="text-3xl font-bold mt-1">{value}</h2>
          </div>
        </div>
        {subtitle && <p className="text-sm text-white/80 mt-2">{subtitle}</p>}
      </div>
    </div>
  );

  const statusData = [
    {
      name: "Active",
      value: customers.filter(c => c.subscriptionStatus === "ACTIVE").length,
    },
    {
      name: "Inactive",
      value: customers.filter(c => c.subscriptionStatus === "INACTIVE").length,
    },
    {
      name: "Trial",
      value: customers.filter(c => c.subscriptionStatus === "TRIAL").length,
    },
  ];

  const planData = [
    {
      name: "FREE",
      value: customers.filter(c => c.planName === "FREE").length,
    },
    {
      name: "BASIC",
      value: customers.filter(c => c.planName === "BASIC").length,
    },
    {
      name: "PRO",
      value: customers.filter(c => c.planName === "PRO").length,
    },
    {
      name: "ENTERPRISE",
      value: customers.filter(c => c.planName === "ENTERPRISE").length,
    },
  ];

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-4xl font-bold text-slate-900">Dashboard</h1>
        <p className="text-slate-600 mt-2">Real-time metrics and insights</p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          icon="📊"
          title="Total Subscriptions"
          value={total}
          gradient="from-indigo-500 to-indigo-600"
        />
        <StatCard
          icon="✅"
          title="Active Customers"
          value={active}
          subtitle={`${total > 0 ? Math.round((active/total)*100) : 0}% of total`}
          gradient="from-emerald-500 to-teal-600"
        />
        <StatCard
          icon="🔄"
          title="Trial Customers"
          value={trial}
          gradient="from-amber-500 to-orange-600"
        />
        <StatCard
          icon="⏸️"
          title="Inactive"
          value={inactive}
          gradient="from-red-500 to-rose-600"
        />
      </div>

      {/* Revenue Card */}
      <div className="bg-gradient-to-br from-purple-500 via-pink-500 to-red-500 rounded-xl shadow-lg p-8 text-white relative overflow-hidden">
        <div className="absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full blur-3xl"></div>
        <div className="relative">
          <p className="text-white/80 text-sm font-semibold uppercase tracking-wide mb-2">Estimated MRR</p>
          <div className="flex items-end gap-4">
            <h2 className="text-5xl font-bold">${mrr.toLocaleString()}</h2>
            <p className="text-white/80 pb-2">per month</p>
          </div>
        </div>
      </div>

      {/* Charts Section */}
      <div>
        <h2 className="text-2xl font-bold text-slate-900 mb-6">Analytics Overview</h2>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <DashboardPieChart
            title="Subscription Status Distribution"
            data={statusData}
            colors={["#10b981", "#ef4444", "#f59e0b"]}
          />

          <DashboardPieChart
            title="Plan Distribution"
            data={planData}
            colors={["#3b82f6", "#6366f1", "#0ea5e9", "#8b5cf6"]}
          />
        </div>
      </div>
    </div>
  );
}
