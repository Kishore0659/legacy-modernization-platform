// src/components/Topbar.js
import React, { useState, useRef, useEffect } from "react";

export default function Topbar({ customers = [], onLogout }) {
  const [open, setOpen] = useState(false);
  const dropdownRef = useRef(null);

  // Find customers expiring in <= 7 days
  const expiringSoon = customers.filter((c) => {
    if (!c.endDate) return false;
    const daysLeft =
      (new Date(c.endDate) - new Date()) / (1000 * 60 * 60 * 24);
    return daysLeft > 0 && daysLeft <= 7;
  });

  // Close dropdown on outside click
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
        setOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const now = new Date().getHours();
  const greeting = now < 12 ? "Good morning" : now < 18 ? "Good afternoon" : "Good evening";

  return (
    <div className="h-16 bg-gradient-to-r from-slate-900 via-slate-800 to-slate-900 border-b border-slate-700 flex items-center justify-between px-6 shadow-lg">
      {/* LEFT */}
      <h1 className="text-base font-semibold text-white">
        {greeting}! 👋
      </h1>

      {/* RIGHT */}
      <div className="flex items-center gap-6" ref={dropdownRef}>
        {/* 🔔 Notification Bell */}
        <div className="relative">
          <button
            onClick={() => setOpen((prev) => !prev)}
            className="relative p-2.5 rounded-lg bg-slate-700/50 hover:bg-slate-700 transition text-white text-lg"
          >
            🔔
            {expiringSoon.length > 0 && (
              <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs font-bold w-6 h-6 rounded-full flex items-center justify-center shadow-lg">
                {expiringSoon.length}
              </span>
            )}
          </button>

          {/* 🔽 DROPDOWN */}
          {open && (
            <div className="absolute right-0 top-14 w-96 bg-white rounded-xl shadow-2xl z-50 border border-slate-200 overflow-hidden">
              {/* Header */}
              <div className="bg-gradient-to-r from-orange-500 to-red-500 px-4 py-3 text-white font-semibold flex items-center gap-2">
                <span className="text-lg">⏰</span>
                Expiring Subscriptions
              </div>

              {/* Content */}
              <div className="max-h-80 overflow-y-auto">
                {expiringSoon.length === 0 ? (
                  <div className="p-8 text-center">
                    <p className="text-3xl mb-2">🎉</p>
                    <p className="text-sm text-slate-600 font-medium">
                      No subscriptions expiring soon!
                    </p>
                  </div>
                ) : (
                  expiringSoon.map((c, idx) => {
                    const daysLeft = Math.ceil(
                      (new Date(c.endDate) - new Date()) /
                        (1000 * 60 * 60 * 24)
                    );

                    return (
                      <div
                        key={c._id || c.id}
                        className={`px-4 py-4 border-b border-slate-100 hover:bg-slate-50 transition ${
                          idx === expiringSoon.length - 1 ? "border-b-0" : ""
                        }`}
                      >
                        <div className="flex items-start justify-between mb-1">
                          <p className="font-semibold text-slate-900">{c.customerName}</p>
                          <span className="text-xs font-bold px-2.5 py-1 bg-red-100 text-red-700 rounded-full">
                            {daysLeft} days
                          </span>
                        </div>
                        <p className="text-xs text-slate-500 truncate">
                          {c.email}
                        </p>
                        <p className="text-xs text-slate-600 mt-1">
                          Expires: {c.endDate}
                        </p>
                      </div>
                    );
                  })
                )}
              </div>

              {/* Footer */}
              {expiringSoon.length > 0 && (
                <div className="px-4 py-3 bg-slate-50 border-t border-slate-100 text-center">
                  <p className="text-xs text-slate-600">Action required for {expiringSoon.length} subscription(s)</p>
                </div>
              )}
            </div>
          )}
        </div>

        {/* User Profile */}
        <div className="h-8 w-8 rounded-full bg-gradient-to-br from-indigo-400 to-blue-600 flex items-center justify-center text-white font-bold shadow-lg">
          👤
        </div>
      </div>
    </div>
  );
}
