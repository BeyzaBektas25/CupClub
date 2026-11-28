import { apiRequest } from "./api";

export type Product = {
  id: number;
  category_id: number;
  category: {
    id: number;
    name: string;
    display_order: number;
  };
  name: string;
  description: string | null;
  image_url: string | null;
  allergens: string | null;
  is_active: boolean;
};
export function getProducts(token: string) {
  return apiRequest<Product[]>("/products", {
    token,
  });
}
export type CreateProductData = {
  category_id: number;
  name: string;
  description?: string;
  image_url?: string;
  allergens?: string;
  is_active?: boolean;
};
export function createProduct(data: CreateProductData, token: string) {
  return apiRequest<Product>("/products", {
    method: "POST",
    token,
    body: data,
  });
}
export function updateProduct(
  productId: number,
  data: Partial<CreateProductData>,
  token: string,
) {
  return apiRequest<Product>(`/products/${productId}`, {
    method: "PATCH",
    token,
    body: data,
  });
}
export function deleteProduct(productId: number, token: string) {
  return apiRequest(`/products/${productId}`, {
    method: "DELETE",
    token,
  });
}
export function updateBranchProduct(
  branchId: number,
  productId: number,
  data: { price?: number; is_in_stock?: boolean },
  token: string
) {
  return apiRequest(
    `/branches/${branchId}/products/${productId}`,
    {
      method: "PATCH",
      token,
      body: data,
    }
  );
}

export type Category = {
  id: number;
  name: string;
  display_order: number;
};

export function getCategories(token: string) {
  return apiRequest<Category[]>("/categories", {
    token,
  });
}