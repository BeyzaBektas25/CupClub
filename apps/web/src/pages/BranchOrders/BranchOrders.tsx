import { useEffect, useState } from "react";
import { getCurrentUser } from "../../services/auth";
import {
  getBranchOrders,
  updateOrderStatus,
  type Order,
} from "../../services/orders";

function BranchOrders() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [branchId, setBranchId] = useState<number | null>(null);
  const [updatingOrderId, setUpdatingOrderId] = useState<number | null>(null);

  async function handleStatusUpdate(orderId: number, newStatus: string) {
    try {
      const token = sessionStorage.getItem("access_token");

      if (!token || branchId === null) {
        throw new Error("Oturum veya şube bilgisi bulunamadı.");
      }

      setUpdatingOrderId(orderId);
      setError("");

      await updateOrderStatus(orderId, branchId, newStatus, token);

      const updatedOrders = await getBranchOrders(branchId, token);
      setOrders(updatedOrders);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "Sipariş durumu güncellenemedi.",
      );
    } finally {
      setUpdatingOrderId(null);
    }
  }

  useEffect(() => {
    let cancelled = false;

    async function loadOrders() {
      try {
        const token = sessionStorage.getItem("access_token");

        if (!token) {
          throw new Error("Oturum bulunamadı. Lütfen tekrar giriş yapın.");
        }

        const profile = await getCurrentUser(token);

        if (profile.branchId === null) {
          throw new Error("Kullanıcının bağlı olduğu şube bulunamadı.");
        }

        if (cancelled) return;

        setBranchId(profile.branchId);

        const branchOrders = await getBranchOrders(profile.branchId, token);

        if (!cancelled) {
          setOrders(branchOrders);
        }
      } catch (err) {
        if (!cancelled) {
          setError(
            err instanceof Error ? err.message : "Siparişler yüklenemedi.",
          );
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    loadOrders();

    return () => {
      cancelled = true;
    };
  }, []);

  if (loading) {
    return <p>Siparişler yükleniyor...</p>;
  }

  return (
    <div>
      <h1>Şube Siparişleri</h1>

      <p>Şube No: {branchId}</p>

      {error && <p>Hata: {error}</p>}

      {orders.length === 0 ? (
        <p>Henüz bu şubeye gelen sipariş bulunmuyor.</p>
      ) : (
        <div>
          {orders.map((order) => (
            <div key={order.id}>
              <h2>Sipariş: {order.order_number}</h2>

              <p>Durum: {order.status}</p>

              {order.status === "Pending" && (
                <button
                  onClick={() => handleStatusUpdate(order.id, "Accepted")}
                  disabled={updatingOrderId === order.id}
                >
                  {updatingOrderId === order.id
                    ? "Güncelleniyor..."
                    : "Kabul Et"}
                </button>
              )}

              {order.status === "Accepted" && (
                <button
                  onClick={() => handleStatusUpdate(order.id, "Preparing")}
                  disabled={updatingOrderId === order.id}
                >
                  {updatingOrderId === order.id
                    ? "Güncelleniyor..."
                    : "Hazırlamaya Başla"}
                </button>
              )}

              {order.status === "Preparing" && (
                <button
                  onClick={() => handleStatusUpdate(order.id, "Ready")}
                  disabled={updatingOrderId === order.id}
                >
                  {updatingOrderId === order.id ? "Güncelleniyor..." : "Hazır"}
                </button>
              )}

              {order.status === "Ready" && (
                <button
                  onClick={() => handleStatusUpdate(order.id, "Delivered")}
                  disabled={updatingOrderId === order.id}
                >
                  {updatingOrderId === order.id
                    ? "Güncelleniyor..."
                    : "Teslim Edildi"}
                </button>
              )}

              <p>
                Toplam:{" "}
                {Number(order.final_amount ?? order.total_amount).toFixed(2)} TL
              </p>

              <p>Tarih: {new Date(order.created_at).toLocaleString("tr-TR")}</p>

              <h3>Ürünler</h3>

              {order.items.map((item) => (
                <p key={item.id}>
                  {item.product?.name ?? "Ürün bilgisi yok"} - {item.quantity}{" "}
                  adet - {Number(item.unit_price).toFixed(2)} TL
                </p>
              ))}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default BranchOrders;
