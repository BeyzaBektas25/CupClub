import { useEffect, useState, type FormEvent } from "react";
import {
  getBranches,
  createBranch,
  deleteBranch,
  type Branch,
} from "../../services/branches";
import {
  getProducts,
  getCategories,
  createProduct,
  updateBranchProduct,
  type Product,
  type Category,
} from "../../services/products";
import { apiRequest } from "../../services/api";

function CentralAdmin() {
  const [branches, setBranches] = useState<Branch[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const [products, setProducts] = useState<Product[]>([]);
  const [loadingProducts, setLoadingProducts] = useState(true);

  const [categories, setCategories] = useState<Category[]>([]);
  const [loadingCategories, setLoadingCategories] = useState(true);

  const [showProductForm, setShowProductForm] = useState(false);
  const [productName, setProductName] = useState("");
  const [productCategoryId, setProductCategoryId] = useState("");
  const [productDescription, setProductDescription] = useState("");
  const [productAllergens, setProductAllergens] = useState("");

  const [showBranchForm, setShowBranchForm] = useState(false);
  const [branchName, setBranchName] = useState("");
  const [branchAddress, setBranchAddress] = useState("");
  const [branchLatitude, setBranchLatitude] = useState("");
  const [branchLongitude, setBranchLongitude] = useState("");
  const [branchWorkingHours, setBranchWorkingHours] = useState("");

  const [deletingBranchId, setDeletingBranchId] = useState<number | null>(null);
  const [deletePassword, setDeletePassword] = useState("");

  const [selectedBranchId, setSelectedBranchId] = useState("");
  const [branchProducts, setBranchProducts] = useState<any[]>([]);
  const [loadingBranchProducts, setLoadingBranchProducts] = useState(false);
  const [priceInputs, setPriceInputs] = useState<Record<number, string>>({});
  const [updatingProductId, setUpdatingProductId] = useState<number | null>(
    null,
  );

  // Şubeleri yükle
  useEffect(() => {
    async function loadBranches() {
      const token = sessionStorage.getItem("access_token");

      if (!token) {
        setError("Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.");
        setLoading(false);
        return;
      }

      try {
        const data = await getBranches(token);
        setBranches(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Şubeler yüklenemedi.");
      } finally {
        setLoading(false);
      }
    }

    loadBranches();
  }, []);

  // Ürünleri yükle
  useEffect(() => {
    async function loadProducts() {
      const token = sessionStorage.getItem("access_token");

      if (!token) {
        setError("Oturum bilgisi bulunamadı.");
        setLoadingProducts(false);
        return;
      }

      try {
        const data = await getProducts(token);
        setProducts(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Ürünler yüklenemedi.");
      } finally {
        setLoadingProducts(false);
      }
    }

    loadProducts();
  }, []);

  // Kategorileri yükle
  useEffect(() => {
    async function loadCategories() {
      const token = sessionStorage.getItem("access_token");

      if (!token) {
        setError("Oturum bilgisi bulunamadı.");
        setLoadingCategories(false);
        return;
      }

      try {
        const data = await getCategories(token);
        setCategories(data);
      } catch (err) {
        setError(
          err instanceof Error ? err.message : "Kategoriler yüklenemedi.",
        );
      } finally {
        setLoadingCategories(false);
      }
    }

    loadCategories();
  }, []);

  useEffect(() => {
    const fetchBranchProducts = async () => {
      if (!selectedBranchId) {
        setBranchProducts([]);
        return;
      }

      const token = sessionStorage.getItem("access_token");

      if (!token) {
        setError("Oturum bilgisi bulunamadı.");
        return;
      }

      try {
        setLoadingBranchProducts(true);
        setError("");

        const response = await apiRequest<any[]>(
          `/branches/${selectedBranchId}/products`,
          { token },
        );

        setBranchProducts(response);

        const prices: Record<number, string> = {};

        response.forEach((item) => {
          prices[item.product_id] = String(item.price);
        });

        setPriceInputs(prices);
      } catch (err) {
        setError(
          err instanceof Error ? err.message : "Şube ürünleri yüklenemedi.",
        );
      } finally {
        setLoadingBranchProducts(false);
      }
    };

    fetchBranchProducts();
  }, [selectedBranchId]);

  // Yeni şube oluştur
  async function handleCreateBranch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const token = sessionStorage.getItem("access_token");

    if (!token) {
      setError("Oturum bilgisi bulunamadı.");
      return;
    }

    try {
      setError("");

      await createBranch(
        {
          name: branchName,
          address: branchAddress,
          latitude: branchLatitude ? Number(branchLatitude) : undefined,
          longitude: branchLongitude ? Number(branchLongitude) : undefined,
          working_hours: branchWorkingHours,
        },
        token,
      );

      const updatedBranches = await getBranches(token);
      setBranches(updatedBranches);

      setBranchName("");
      setBranchAddress("");
      setBranchLatitude("");
      setBranchLongitude("");
      setBranchWorkingHours("");
      setShowBranchForm(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Şube oluşturulamadı.");
    }
  }

  // Şube silme onayını aç
  function handleDeleteBranch(branchId: number) {
    setError("");
    setDeletePassword("");
    setDeletingBranchId(branchId);
  }

  // Şifre doğrulayarak şubeyi sil
  async function confirmDeleteBranch(branchId: number) {
    const token = sessionStorage.getItem("access_token");

    if (!token) {
      setError("Oturum bilgisi bulunamadı.");
      return;
    }

    if (!deletePassword.trim()) {
      setError("Lütfen yönetici şifrenizi girin.");
      return;
    }

    try {
      setError("");

      await deleteBranch(branchId, deletePassword, token);

      const updatedBranches = await getBranches(token);
      setBranches(updatedBranches);

      setDeletingBranchId(null);
      setDeletePassword("");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Şube silinemedi.");
    }
  }

  // Yeni ürün oluştur
  async function handleCreateProduct(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const token = sessionStorage.getItem("access_token");

    if (!token) {
      setError("Oturum bilgisi bulunamadı.");
      return;
    }

    try {
      setError("");

      await createProduct(
        {
          name: productName,
          category_id: Number(productCategoryId),
          description: productDescription,
          allergens: productAllergens,
        },
        token,
      );

      const updatedProducts = await getProducts(token);
      setProducts(updatedProducts);

      setProductName("");
      setProductCategoryId("");
      setProductDescription("");
      setProductAllergens("");
      setShowProductForm(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Ürün oluşturulamadı.");
    }
  }

  const handleUpdateBranchProduct = async (productId: number) => {
    const token = sessionStorage.getItem("access_token");

    if (!token || !selectedBranchId) {
      setError("Oturum veya şube bilgisi bulunamadı.");
      return;
    }

    const branchProduct = branchProducts.find(
      (item) => item.product_id === productId,
    );

    if (!branchProduct) {
      setError("Ürün bilgisi bulunamadı.");
      return;
    }

    const price = Number(priceInputs[productId]);

    if (!Number.isFinite(price) || price < 0) {
      setError("Geçerli bir fiyat girin.");
      return;
    }

    try {
      setUpdatingProductId(productId);
      setError("");

      await updateBranchProduct(
        Number(selectedBranchId),
        productId,
        {
          price,
          is_in_stock: branchProduct.is_in_stock,
        },
        token,
      );

      setError("");
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "Fiyat ve stok bilgisi güncellenemedi.",
      );
    } finally {
      setUpdatingProductId(null);
    }
  };

  return (
    <div>
      <h1>Merkezi Yönetim Paneli</h1>
      <p>CupClub işletme yönetimi</p>

      {error && <p>{error}</p>}

      <section>
        <h2>Şube Yönetimi</h2>

        <button
          type="button"
          onClick={() => setShowBranchForm(!showBranchForm)}
        >
          {showBranchForm ? "Formu Kapat" : "Yeni Şube Ekle"}
        </button>

        {showBranchForm && (
          <form onSubmit={handleCreateBranch}>
            <div>
              <label>Şube Adı</label>
              <input
                value={branchName}
                onChange={(event) => setBranchName(event.target.value)}
                required
              />
            </div>

            <div>
              <label>Adres</label>
              <input
                value={branchAddress}
                onChange={(event) => setBranchAddress(event.target.value)}
                required
              />
            </div>

            <div>
              <label>Enlem</label>
              <input
                type="number"
                step="any"
                value={branchLatitude}
                onChange={(event) => setBranchLatitude(event.target.value)}
              />
            </div>

            <div>
              <label>Boylam</label>
              <input
                type="number"
                step="any"
                value={branchLongitude}
                onChange={(event) => setBranchLongitude(event.target.value)}
              />
            </div>

            <div>
              <label>Çalışma Saatleri</label>
              <input
                value={branchWorkingHours}
                onChange={(event) => setBranchWorkingHours(event.target.value)}
                placeholder="08:00 - 23:00"
                required
              />
            </div>

            <button type="submit">Şubeyi Kaydet</button>
          </form>
        )}

        {loading && <p>Şubeler yükleniyor...</p>}

        {!loading && (
          <div>
            {branches.map((branch) => (
              <article key={branch.id}>
                <h3>{branch.name}</h3>
                <p>{branch.address}</p>
                <p>Durum: {branch.is_active ? "Aktif" : "Pasif"}</p>

                <button
                  type="button"
                  onClick={() => handleDeleteBranch(branch.id)}
                >
                  Şubeyi Sil
                </button>

                {deletingBranchId === branch.id && (
                  <div>
                    <p>Şubeyi silmek için yönetici şifrenizi girin:</p>

                    <input
                      type="password"
                      value={deletePassword}
                      onChange={(event) =>
                        setDeletePassword(event.target.value)
                      }
                      placeholder="Yönetici şifresi"
                    />

                    <button
                      type="button"
                      onClick={() => confirmDeleteBranch(branch.id)}
                    >
                      Silme İşlemini Onayla
                    </button>

                    <button
                      type="button"
                      onClick={() => {
                        setDeletingBranchId(null);
                        setDeletePassword("");
                      }}
                    >
                      İptal
                    </button>
                  </div>
                )}
              </article>
            ))}

            {branches.length === 0 && <p>Kayıtlı şube bulunamadı.</p>}
          </div>
        )}
      </section>

      <section>
        <h2>Ürün Yönetimi</h2>

        <button
          type="button"
          onClick={() => setShowProductForm(!showProductForm)}
        >
          {showProductForm ? "Formu Kapat" : "Yeni Ürün Ekle"}
        </button>

        {showProductForm && (
          <form onSubmit={handleCreateProduct}>
            <h3>Yeni Ürün Oluştur</h3>

            <label>
              Ürün Adı:
              <input
                type="text"
                value={productName}
                onChange={(event) => setProductName(event.target.value)}
                required
              />
            </label>

            <label>
              Kategori:
              <select
                value={productCategoryId}
                onChange={(event) => setProductCategoryId(event.target.value)}
                required
                disabled={loadingCategories}
              >
                <option value="">
                  {loadingCategories
                    ? "Kategoriler yükleniyor..."
                    : "Kategori seçin"}
                </option>

                {categories.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.name}
                  </option>
                ))}
              </select>
            </label>

            <label>
              Ürün Açıklaması:
              <textarea
                value={productDescription}
                onChange={(event) => setProductDescription(event.target.value)}
              />
            </label>

            <label>
              Alerjen Bilgisi:
              <input
                type="text"
                value={productAllergens}
                onChange={(event) => setProductAllergens(event.target.value)}
                placeholder="Örn: Süt, gluten, fındık"
              />
            </label>

            <button type="submit" disabled={loadingCategories}>
              Ürünü Kaydet
            </button>
          </form>
        )}

        {loadingProducts && <p>Ürünler yükleniyor...</p>}

        {!loadingProducts && (
          <div>
            {products.map((product) => (
              <article key={product.id}>
                <h3>{product.name}</h3>
                <p>Kategori: {product.category.name}</p>
                <p>Açıklama: {product.description}</p>
                <p>Alerjen Bilgisi: {product.allergens || "Belirtilmemiş"}</p>
                <p>Durum: {product.is_active ? "Aktif" : "Pasif"}</p>
              </article>
            ))}

            {products.length === 0 && <p>Kayıtlı ürün bulunamadı.</p>}
          </div>
        )}
      </section>

      <section>
        <h2>Fiyat ve Stok Yönetimi</h2>
        <p>Şubelere özel fiyat ve stok bilgilerini düzenle.</p>

        <label>
          Şube Seçin:
          <select
            value={selectedBranchId}
            onChange={(e) => setSelectedBranchId(e.target.value)}
          >
            <option value="">Şube seçin</option>
            {branches.map((branch) => (
              <option key={branch.id} value={branch.id}>
                {branch.name}
              </option>
            ))}
          </select>
        </label>

        {loadingBranchProducts && <p>Ürünler yükleniyor...</p>}

        {selectedBranchId && !loadingBranchProducts && (
          <div>
            {branchProducts.length === 0 ? (
              <p>Bu şubeye atanmış ürün bulunamadı.</p>
            ) : (
              branchProducts.map((item) => (
                <div key={item.id}>
                  <h3>{item.product?.name}</h3>

                  <label>
                    Fiyat:
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={priceInputs[item.product_id] ?? ""}
                      onChange={(e) =>
                        setPriceInputs((prev) => ({
                          ...prev,
                          [item.product_id]: e.target.value,
                        }))
                      }
                    />
                  </label>

                  <label>
                    <input
                      type="checkbox"
                      checked={item.is_in_stock}
                      onChange={(e) => {
                        const updatedProducts = branchProducts.map((product) =>
                          product.product_id === item.product_id
                            ? { ...product, is_in_stock: e.target.checked }
                            : product,
                        );

                        setBranchProducts(updatedProducts);
                      }}
                    />
                    Stokta
                  </label>

                  <button
                    type="button"
                    onClick={() => handleUpdateBranchProduct(item.product_id)}
                    disabled={updatingProductId === item.product_id}
                  >
                    {updatingProductId === item.product_id
                      ? "Kaydediliyor..."
                      : "Değişiklikleri Kaydet"}
                  </button>
                </div>
              ))
            )}
          </div>
        )}
      </section>

      <section>
        <h2>Kampanya Yönetimi</h2>
        <p>Kampanyaları oluştur ve yönet.</p>
      </section>
    </div>
  );
}

export default CentralAdmin;
