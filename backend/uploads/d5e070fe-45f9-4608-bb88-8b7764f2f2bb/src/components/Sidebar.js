// src/components/Sidebar.js
import React from "react";
import { NavLink } from "react-router-dom";
import useTheme from "../hooks/useTheme";

export default function Sidebar({ onDownloadCSV }) {
  const { theme, setTheme } = useTheme();

  return (
    <div className="w-64 bg-white border-r h-screen flex flex-col">
      {/* Logo */}
      <div className="p-6 text-xl font-bold text-green-700 border-b">
          SaaS Admin
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-2">
        <NavLink
          to="/dashboard"
          className={({ isActive }) =>
  `block px-4 py-2 rounded-md font-semibold transition-all ${
    isActive
      ? "bg-green-700 text-white shadow"
      : "text-green-700 hover:bg-green-50 hover:text-green-800"
  }`
}
        >
          Dashboard
        </NavLink>

        <NavLink
          to="/users"
          className={({ isActive }) =>
  `block px-4 py-2 rounded-md font-semibold transition-all ${
    isActive
      ? "bg-green-700 text-white shadow"
      : "text-green-700 hover:bg-green-50 hover:text-green-800"
  }`
}
        >
          Users
        </NavLink>

        <NavLink
          to="/settings"
          className={({ isActive }) =>
  `block px-4 py-2 rounded-md font-semibold transition-all ${
    isActive
      ? "bg-green-700 text-white shadow"
      : "text-green-700 hover:bg-green-50 hover:text-green-800"
  }`
}
        >
          Settings
        </NavLink>
      </nav>

      {/* Bottom Controls */}
      <div className="p-4 border-t space-y-3">
        <button
          onClick={onDownloadCSV}
          className="w-full bg-green-600 text-white py-2 rounded-md text-sm font-semibold hover:bg-green-700 transition"
        >
          Export CSV
        </button>

        <button
          onClick={() => setTheme(theme === "light" ? "dark" : "light")}
          className="w-full border border-green-600 text-green-700 py-2 rounded-md text-sm hover:bg-green-50 transition"
        >
          {theme === "light" ? "🌙 Dark Mode" : "☀️ Light Mode"}
        </button>
      </div>
    </div>
  );
}
