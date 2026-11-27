import { useState, type FormEvent } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { loginUser, getCurrentUser } from '../../services/auth';

function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();


async function handleSubmit(event: FormEvent<HTMLFormElement>) {
  event.preventDefault();

  setError('');
  setLoading(true);

  try {
    const response = await loginUser({
      email,
      password,
    });

    sessionStorage.setItem('access_token', response.access_token);

    const profile = await getCurrentUser(response.access_token);

    if (profile.roles.includes('BRANCH_STAFF')) {
      navigate('/branch/orders');
    } else if (profile.roles.includes('CENTRAL_ADMIN')) {
      navigate('/central');
    } else if (profile.roles.includes('SYSTEM_ADMIN')) {
      navigate('/system');
    } else {
      setError('Bu kullanıcı için tanımlanmış bir panel bulunamadı.');
    }
  } catch (err) {
    setError(
      err instanceof Error ? err.message : 'Bir hata oluştu.'
    );
  } finally {
    setLoading(false);
  }
}


  return (
    <form onSubmit={handleSubmit}>
      <h1>Giriş Yap</h1>

      <div>
        <label htmlFor="email">E-posta</label>
        <input
          id="email"
          type="email"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          required
        />
      </div>

      <div>
        <label htmlFor="password">Şifre</label>
        <input
          id="password"
          type="password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          required
        />
      </div>

      {error && <p>{error}</p>}

      <button type="submit" disabled={loading}>
        {loading ? 'Giriş yapılıyor...' : 'Giriş Yap'}
      </button>
      <p>
  Hesabın yok mu? <Link to="/register">Kayıt ol</Link>
</p>
    </form>
  );
}

export default Login;