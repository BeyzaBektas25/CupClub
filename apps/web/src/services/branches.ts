
import { apiRequest } from './api';

export type Branch = {
  id: number;
  name: string;
  address: string;
  latitude: string;
  longitude: string;
  working_hours: string;
  is_active: boolean;
};

export type CreateBranchData = {
  name: string;
  address?: string;
  latitude?: number;
  longitude?: number;
  working_hours?: string;
};

export function getBranches(token: string) {
  return apiRequest<Branch[]>('/branches', {
    token,
  });
}

export function createBranch(data: CreateBranchData, token: string) {
  return apiRequest<Branch>('/branches', {
    method: 'POST',
    token,
    body: data,
  });
}

export function updateBranch(
  branchId: number,
  data: Partial<CreateBranchData>,
  token: string
) {
  return apiRequest<Branch>(`/branches/${branchId}`, {
    method: 'PATCH',
    token,
    body: data,
  });
}

export function deleteBranch(
  branchId: number,
  password: string,
  token: string
) {
  return apiRequest(`/branches/${branchId}`, {
    method: 'DELETE',
    token,
    body: { password },
  });
}
