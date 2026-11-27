import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  bool _isGeneratingQr = false;

  int _totalPoints = 0;
  int _currentStamps = 0;

  String? _qrToken;
  DateTime? _qrExpiresAt;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLoyaltyAccount();
  }

  Future<void> _loadLoyaltyAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await _authService.getCurrentUserId();
      final result = await _apiService.getLoyaltyAccount(userId);

      final account = result['account'];

      if (account == null) {
        throw Exception('Sadakat hesabı bilgisi bulunamadı.');
      }

      final accountData = Map<String, dynamic>.from(account);

      if (!mounted) return;

      setState(() {
        _totalPoints =
            int.tryParse(accountData['total_points']?.toString() ?? '') ?? 0;

        _currentStamps =
            int.tryParse(accountData['current_stamps']?.toString() ?? '') ?? 0;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateRewardQr() async {
    if (_isGeneratingQr) return;

    setState(() {
      _isGeneratingQr = true;
      _qrToken = null;
      _qrExpiresAt = null;
    });

    try {
      final userId = await _authService.getCurrentUserId();

      final result = await _apiService.generateRewardQr(userId);

      final token =
          result['qr_code_token'] ?? result['qrToken'] ?? result['token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception('QR kod bilgisi sunucudan alınamadı.');
      }

      final expiryValue = result['expires_at'];
      final expiryDate = expiryValue != null
          ? DateTime.tryParse(expiryValue.toString())
          : null;

      if (!mounted) return;

      setState(() {
        _qrToken = token.toString();
        _qrExpiresAt = expiryDate;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'QR kod oluşturulamadı: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingQr = false;
        });
      }
    }
  }

  String _formatExpiry(DateTime expiry) {
    final localExpiry = expiry.toLocal();

    final day = localExpiry.day.toString().padLeft(2, '0');
    final month = localExpiry.month.toString().padLeft(2, '0');
    final hour = localExpiry.hour.toString().padLeft(2, '0');
    final minute = localExpiry.minute.toString().padLeft(2, '0');

    return '$day.$month.${localExpiry.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF68452F);
    const cream = Color(0xFFFFF9F2);
    const lightPink = Color(0xFFF8E8E8);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text('Sadakat Kulübüm'),
        backgroundColor: cream,
        foregroundColor: darkBrown,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 42, color: darkBrown),
                    const SizedBox(height: 12),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadLoyaltyAccount,
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadLoyaltyAccount,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: darkBrown,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.coffee, size: 48, color: Colors.white),
                        const SizedBox(height: 12),
                        const Text(
                          'CupClub Sadakat Programı',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _LoyaltyValue(
                                icon: Icons.stars,
                                title: 'Toplam Puan',
                                value: '$_totalPoints',
                              ),
                            ),
                            Container(
                              height: 55,
                              width: 1,
                              color: Colors.white30,
                            ),
                            Expanded(
                              child: _LoyaltyValue(
                                icon: Icons.local_cafe,
                                title: 'Damgalarım',
                                value: '$_currentStamps',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ödülünü Al',
                    style: TextStyle(
                      color: darkBrown,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ücretsiz kahve ödülün için QR kod oluşturabilirsin.',
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: lightPink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.card_giftcard,
                          size: 42,
                          color: darkBrown,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ücretsiz Kahve Ödülü',
                          style: TextStyle(
                            color: darkBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_qrToken != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: QrImageView(
                              data: _qrToken!,
                              version: QrVersions.auto,
                              size: 210,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ödülünü kullanmak için QR kodunu şube personeline göster.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: darkBrown),
                          ),
                          if (_qrExpiresAt != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Son kullanım: ${_formatExpiry(_qrExpiresAt!)}',
                              style: const TextStyle(
                                color: darkBrown,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ] else
                          const Text(
                            'Henüz bir ödül QR kodu oluşturmadın.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: darkBrown),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isGeneratingQr
                                ? null
                                : _generateRewardQr,
                            icon: _isGeneratingQr
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.qr_code),
                            label: Text(
                              _isGeneratingQr
                                  ? 'QR Oluşturuluyor...'
                                  : 'Ödül QR Kodu Oluştur',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkBrown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bilgi: Oluşturulan ödül QR kodu 15 dakika geçerlidir ve yalnızca bir kez kullanılabilir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }
}

class _LoyaltyValue extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _LoyaltyValue({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 26),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
