import { useState, type FormEvent } from 'react';
import { Link } from 'react-router-dom';
import { registerUser } from '../../services/auth';

function Register() {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    setError('');
    setSuccess('');

    if (password.length < 6) {
      setError('Şifre en az 6 karakter olmalıdır.');
      return;
    }

    setLoading(true);

    try {
      await registerUser({
        first_name: firstName,
        last_name: lastName,
        email,
        password,
      });

      setSuccess('Kayıt başarılı! Artık giriş yapabilirsiniz.');
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
      <h1>Hesap Oluştur</h1>

      <div>
        <label htmlFor="firstName">Ad</label>
        <input
          id="firstName"
          type="text"
          value={firstName}
          onChange={(event) => setFirstName(event.target.value)}
          required
        />
      </div>

      <div>
        <label htmlFor="lastName">Soyad</label>
        <input
          id="lastName"
          type="text"
          value={lastName}
          onChange={(event) => setLastName(event.target.value)}
          required
        />
      </div>

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
          minLength={6}
          required
        />
      </div>

      {error && <p>{error}</p>}
      {success && <p>{success}</p>}

      <button type="submit" disabled={loading}>
        {loading ? 'Kayıt yapılıyor...' : 'Kayıt Ol'}
      </button>
      <p>
  Zaten hesabın var mı? <Link to="/login">Giriş yap</Link>
</p>
    </form>
  );
}

export default Register;
