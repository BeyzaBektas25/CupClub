import { apiRequest } from './api';

export type OrderItem = {
  id: number;
  product_id: number;
  quantity: number;
  unit_price: number | string;
  product: {
    id: number;
    name: string;
  };
  options: {
    id: number;
  }[];
};

export type Order = {
  id: number;
  order_number: string;
  user_id: number;
  branch_id: number;
  total_amount: number | string;
  discount_amount: number | string;
  final_amount: number | string;
  status: string;
  created_at: string;
  items: OrderItem[];
};

export function getBranchOrders(branchId: number, token: string) {
  return apiRequest<Order[]>(`/branches/${branchId}/orders`, {
    token,
  });
}
export function updateOrderStatus(
  orderId: number,
  branchId: number,
  status: string,
  token: string
) {
  return apiRequest(`/orders/${orderId}/status`, {
    method: 'PATCH',
    token,
    body: {
      branchId,
      status,
    },
  });
}