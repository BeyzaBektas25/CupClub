
import { useEffect, useState, type FormEvent } from "react";
import {
  getBranches,
  createBranch,
  deleteBranch,
  type Branch,
} from "../../services/branches";

function CentralAdmin() {
  const [branches, setBranches] = useState<Branch[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [showBranchForm, setShowBranchForm] = useState(false);
  const [branchName, setBranchName] = useState("");
  const [branchAddress, setBranchAddress] = useState("");
  const [branchLatitude, setBranchLatitude] = useState("");
  const [branchLongitude, setBranchLongitude] = useState("");
  const [branchWorkingHours, setBranchWorkingHours] = useState("");
  const [deletingBranchId, setDeletingBranchId] = useState<number | null>(null);
  const [deletePassword, setDeletePassword] = useState("");

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

  function handleDeleteBranch(branchId: number) {
    setError("");
    setDeletePassword("");
    setDeletingBranchId(branchId);
  }

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

  return (
    <div>
      <h1>Merkezi Yönetim Paneli</h1>
      <p>CupClub işletme yönetimi</p>

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

        {error && <p>{error}</p>}

        {!loading && !error && (
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
                      onChange={(event) => setDeletePassword(event.target.value)}
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
        <p>Ürünleri oluştur, güncelle ve sil.</p>
      </section>

      <section>
        <h2>Fiyat ve Stok Yönetimi</h2>
        <p>Şubelere özel fiyat ve stok bilgilerini düzenle.</p>
      </section>

      <section>
        <h2>Kampanya Yönetimi</h2>
        <p>Kampanyaları oluştur ve yönet.</p>
      </section>
    </div>
  );
}

export default CentralAdmin;
