import { Dialog } from "@mui/material";

export default function CustomerModal({
  open,
  onClose,
  editingId,
  formData,
  handleInputChange,
  handleSubmit,
  emailError,
  dateError,
}) {
  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <div className="p-8 bg-white rounded-xl">
        <h2 className="text-xl font-bold mb-6 flex items-center gap-2">
          <span className="w-2 h-6 bg-blue-600 rounded-full"></span>
          {editingId ? "Update Customer" : "Register New Customer"}
        </h2>

        <form
          className="grid grid-cols-1 md:grid-cols-3 gap-6"
          onSubmit={handleSubmit}
        >
          {/* NAME */}
          <div>
            <label className="text-xs font-bold text-gray-500">FULL NAME</label>
            <input
              name="customerName"
              value={formData.customerName}
              onChange={handleInputChange}
              className="w-full mt-1 p-3 border rounded-lg"
              required
            />
          </div>

          {/* EMAIL */}
          <div>
            <label className="text-xs font-bold text-gray-500">
              EMAIL ADDRESS
            </label>
            <input
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              className={`w-full mt-1 p-3 border rounded-lg ${
                emailError ? "border-red-500" : ""
              }`}
              required
            />
            {emailError && (
              <p className="text-red-500 text-xs mt-1">{emailError}</p>
            )}
          </div>

          {/* PLAN */}
          <div>
            <label className="text-xs font-bold text-gray-500">SERVICE PLAN</label>
            <select
              name="planName"
              value={formData.planName}
              onChange={handleInputChange}
              className="w-full mt-1 p-3 border rounded-lg"
              required
            >
              <option value="">Select Plan</option>
              <option value="FREE">FREE</option>
              <option value="BASIC">BASIC</option>
              <option value="PRO">PRO</option>
            </select>
          </div>

          {/* STATUS */}
          <div>
            <label className="text-xs font-bold text-gray-500">
              SYSTEM STATUS (AUTO)
            </label>
            <input
              disabled
              value={formData.subscriptionStatus}
              className="w-full mt-1 p-3 border rounded-lg bg-gray-100"
            />
          </div>

          {/* START */}
          <div>
            <label className="text-xs font-bold text-gray-500">START DATE</label>
            <input
              type="date"
              name="startDate"
              value={formData.startDate}
              onChange={handleInputChange}
              className="w-full mt-1 p-3 border rounded-lg"
              required
            />
          </div>

          {/* END */}
          <div>
            <label className="text-xs font-bold text-gray-500">END DATE</label>
            <input
              type="date"
              name="endDate"
              value={formData.endDate}
              onChange={handleInputChange}
              className="w-full mt-1 p-3 border rounded-lg"
              required
            />
            {dateError && (
              <p className="text-red-500 text-xs mt-1">{dateError}</p>
            )}
          </div>

          {/* ACTIONS */}
          <div className="col-span-full flex gap-4 mt-4">
            <button
              type="submit"
              className="flex-1 bg-blue-600 text-white py-3 rounded-lg font-bold"
            >
              {editingId ? "Update Customer" : "Add Customer to System"}
            </button>

            {editingId && (
              <button
                type="button"
                onClick={onClose}
                className="px-8 bg-gray-100 rounded-lg font-bold"
              >
                Cancel
              </button>
            )}
          </div>
        </form>
      </div>
    </Dialog>
  );
}
