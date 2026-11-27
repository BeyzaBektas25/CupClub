import 'package:flutter/material.dart';

import '../services/auth_service.dart';

const Color registerBackgroundColor = Color(0xFFFCF5E9);
const Color registerCoffeeBrown = Color(0xFF7A4A2F);
const Color registerWhite = Colors.white;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  DateTime? _selectedDate;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Doğum tarihini seç',
      cancelText: 'İptal',
      confirmText: 'Seç',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: registerCoffeeBrown,
              onPrimary: registerWhite,
              surface: registerBackgroundColor,
              onSurface: registerCoffeeBrown,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  String _formatDateForApi(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$year-$month-$day';
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen doğum tarihini seç.'),
          backgroundColor: registerCoffeeBrown,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _formatDateForApi(_selectedDate!),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: registerCoffeeBrown,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: registerBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // LOGO
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 210,
                    height: 185,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 8),

                // SLOGAN
                const Text(
                  'Kahvenin en tatlı hali.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: registerCoffeeBrown,
                  ),
                ),

                const SizedBox(height: 38),

                // BAŞLIK
                const Text(
                  'Aramıza hoş geldin!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: registerCoffeeBrown,
                  ),
                ),

                const SizedBox(height: 8),

                // AÇIKLAMA
                const Text(
                  'CupClub ailesine katıl ve lezzetli bir deneyime ilk adımını at.',
                  style: TextStyle(
                    fontSize: 14,
                    color: registerCoffeeBrown,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // AD
                TextFormField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    'Ad',
                    Icons.person_outline_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Adını gir.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // SOYAD
                TextFormField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    'Soyad',
                    Icons.person_outline_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Soyadını gir.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // E-POSTA
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    'E-posta adresi',
                    Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'E-posta adresini gir.';
                    }

                    final email = value.trim();

                    if (!email.contains('@') || !email.contains('.')) {
                      return 'Geçerli bir e-posta adresi gir.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // DOĞUM TARİHİ
                FormField<DateTime>(
                  validator: (_) {
                    if (_selectedDate == null) {
                      return 'Doğum tarihini seç.';
                    }
                    return null;
                  },
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () async {
                            await _selectDate();
                            field.didChange(_selectedDate);
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: InputDecorator(
                            decoration:
                                _inputDecoration(
                                  'Doğum tarihi',
                                  Icons.calendar_month_outlined,
                                ).copyWith(
                                  errorText: field.errorText,
                                  suffixIcon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: registerCoffeeBrown,
                                  ),
                                ),
                            child: Text(
                              _selectedDate == null
                                  ? 'GG/AA/YYYY'
                                  : _formatDate(_selectedDate!),
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedDate == null
                                    ? registerCoffeeBrown.withValues(
                                        alpha: 0.65,
                                      )
                                    : registerCoffeeBrown,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ŞİFRE
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration:
                      _inputDecoration(
                        'Şifre',
                        Icons.lock_outline_rounded,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: registerCoffeeBrown,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre oluştur.';
                    }

                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalı.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ŞİFRE TEKRARI
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration:
                      _inputDecoration(
                        'Şifre tekrar',
                        Icons.lock_outline_rounded,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: registerCoffeeBrown,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifreni tekrar gir.';
                    }

                    if (value != _passwordController.text) {
                      return 'Şifreler eşleşmiyor.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // KAYIT OL BUTONU
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: registerCoffeeBrown,
                      foregroundColor: registerWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: registerWhite)
                        : const Text(
                            'Kayıt Ol',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // GİRİŞ EKRANINA DÖN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Zaten hesabın var mı?',
                      style: TextStyle(
                        fontSize: 14,
                        color: registerCoffeeBrown,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Giriş yap',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: registerCoffeeBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: registerCoffeeBrown, fontSize: 14),
      prefixIcon: Icon(icon, color: registerCoffeeBrown, size: 21),
      filled: true,
      fillColor: registerWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE8DCCF), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: registerCoffeeBrown, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
