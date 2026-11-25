import { apiRequest } from './api';

export type RegisterData = {
  first_name: string;
  last_name: string;
  email: string;
  password: string;
};

export type LoginData = {
  email: string;
  password: string;
};

export type RegisterResponse = {
  message: string;
  userId: number;
};

export type LoginResponse = {
  access_token: string;
  user: {
    id: number;
    first_name: string;
    last_name: string;
    email: string;
  };
};

export function registerUser(data: RegisterData) {
  return apiRequest<RegisterResponse>('/auth/register', {
    method: 'POST',
    body: data,
  });
}

export function loginUser(data: LoginData) {
  return apiRequest<LoginResponse>('/auth/login', {
    method: 'POST',
    body: data,
  });
}
export type ProfileResponse = {
  user: {
    id: number;
    first_name: string;
    last_name: string;
    email: string;
  };
  roles: string[];
  branchId: number | null;
};

export function getCurrentUser(token: string) {
  return apiRequest<ProfileResponse>('/auth/me', {
    token,
  });
}