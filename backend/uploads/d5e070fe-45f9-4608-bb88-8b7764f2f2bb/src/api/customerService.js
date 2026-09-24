import api from "./axiosConfig";

const BASE_URL = "/customers";

export const getCustomers = (page = 0, size = 5) => {
  return api.get(`${BASE_URL}?page=${page}&size=${size}`);
};

export const createCustomer = (customer) => {
  return api.post(BASE_URL, customer);
};

export const deleteCustomer = (id) => {
  return api.delete(`${BASE_URL}/${id}`);
};

// UI-specific logic removed. Provide a simple helper that components can call and
// then set local UI state with the response. Hooks must not appear in service files.
export const fetchCustomers = (pageNumber = 0, status = "", size = 5) => {
  const url = status
    ? `${BASE_URL}/status?status=${status}&page=${pageNumber}&size=${size}`
    : `${BASE_URL}?page=${pageNumber}&size=${size}`;

  return api.get(url);
};

