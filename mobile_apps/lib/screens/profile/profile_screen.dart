import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/dialogs/legal_text_dialog.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../services/token_storage.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  int _selectedIndex = 2;

  // Backend data state
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await UserService().getProfile();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _userProfile = response.data!;
        } else {
          _errorMessage = response.message ?? 'Profil yüklenemedi';
        }
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.createRequest);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await TokenStorage.clearAll();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          side: const BorderSide(color: AppTheme.stroke, width: AppTheme.strokeThin),
        ),
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(color: AppTheme.foreground),
        ),
        content: const Text(
          'Gerçekten çıkmak istiyor musunuz?',
          style: TextStyle(color: AppTheme.foreground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: AppTheme.foreground)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Evet, Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          side: BorderSide(color: Colors.red.withOpacity(0.5), width: AppTheme.strokeThin),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Hesabı Sil',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        content: const Text(
          'Hesabınız kalıcı olarak silinecektir. Bu işlem geri alınamaz. Emin misiniz?',
          style: TextStyle(color: AppTheme.foreground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: AppTheme.foreground)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text('Evet, Hesabı Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _isLoading = true);
    try {
      final response = await AuthService().deleteAccount();
      if (!mounted) return;
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hesabınız başarıyla silindi')),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Hesap silinemedi')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _showLogoutConfirmation,
            icon: const Icon(
              Icons.logout,
              color: AppTheme.foreground,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: AppTheme.background,
        selectedItemColor: AppTheme.foreground,
        unselectedItemColor: AppTheme.foreground.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Talep Oluştur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.foreground,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppTheme.foreground.withOpacity(0.5),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.foreground.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _userProfile!;
    final donor = profile.donorProfile;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: AppTheme.foreground,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profil Bilgileri
          _buildProfileField(
            'Ad Soyad',
            donor != null ? '${donor.firstName} ${donor.lastName}' : 'Belirtilmemiş',
            Icons.person_outline,
          ),
          _buildProfileField(
            'Kan Grubu',
            donor != null ? donor.bloodTypeDisplay : 'Belirtilmemiş',
            Icons.bloodtype_outlined,
          ),
          _buildProfileField(
            'Telefon',
            profile.phoneNumber,
            Icons.phone_outlined,
          ),
          _buildProfileField(
            'E-posta',
            profile.email ?? 'Belirtilmemiş',
            Icons.email_outlined,
          ),
          _buildProfileField(
            'Cinsiyet',
            donor != null ? donor.genderDisplay : 'Belirtilmemiş',
            Icons.wc_outlined,
          ),
          _buildProfileField(
            'Yaş',
            donor != null ? '${donor.age} yaşında' : 'Belirtilmemiş',
            Icons.cake_outlined,
          ),
          if (donor?.weight != null)
            _buildProfileField(
              'Kilo',
              '${donor!.weight} kg',
              Icons.monitor_weight_outlined,
            ),
          _buildProfileField(
            'Adres',
            donor != null ? donor.addressDisplay : 'Belirtilmemiş',
            Icons.location_on_outlined,
          ),
          _buildProfileField(
            'Toplam Bağış',
            donor != null ? '${donor.totalDonations} bağış' : '0 bağış',
            Icons.volunteer_activism_outlined,
          ),
          if (donor?.lastDonationDate != null)
            _buildProfileField(
              'Son Bağış Tarihi',
              _formatDate(donor!.lastDonationDate!),
              Icons.calendar_today_outlined,
            ),

          // DonorProfile yoksa uyarı
          if (donor == null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Profil bilgileriniz henüz tamamlanmamış. Kan bağışı yapabilmek için profil bilgilerinizi ekleyin.',
                      style: TextStyle(
                        color: AppTheme.foreground.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Taleplerim Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.requestsList);
              },
              child: const Text('Taleplerim'),
            ),
          ),
          const SizedBox(height: 20),

          // Notification Switch
          Container(
            decoration: BoxDecoration(
              color: AppTheme.foreground.withOpacity(0.05),
              border: Border.all(color: AppTheme.stroke.withOpacity(0.3), width: AppTheme.strokeThin),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.foreground.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_outlined, color: AppTheme.foreground),
              ),
              title: const Text(
                'Bildirimler',
                style: TextStyle(color: AppTheme.foreground, fontWeight: FontWeight.w600),
              ),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: AppTheme.foreground,
              activeTrackColor: AppTheme.foreground.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),

          // KVKK Link
          TextButton(
            onPressed: () {
              _showLegalDialog(context, 'KVKK Metni', """
Kişisel Verilerin Korunması Kanunu (KVKK) kapsamında, kişisel verileriniz...
(Buraya uzun KVKK metni gelecek)
...
""");
            },
            child: const Text(
              'KVKK Metni',
              style: TextStyle(
                color: AppTheme.foreground,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          // Aydınlatma Metni Link
          TextButton(
            onPressed: () {
              _showLegalDialog(context, 'Aydınlatma Metni', """
Aydınlatma Metni kapsamında, verilerinizin işlenme amaçları...
(Buraya uzun Aydınlatma metni gelecek)
...
""");
            },
            child: const Text(
              'Aydınlatma Metni',
              style: TextStyle(
                color: AppTheme.foreground,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Hesabı Sil Butonu
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _showDeleteConfirmation,
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text(
                'Hesabımı Sil',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _getRoleDisplay(String role) {
    final map = {
      'DONOR': 'Bağışçı',
      'HOSPITAL': 'Hastane',
      'ADMIN': 'Yönetici',
    };
    return map[role] ?? role;
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => LegalTextDialog(title: title, content: content),
    );
  }

  Widget _buildProfileField(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.foreground.withOpacity(0.05),
        border: Border.all(color: AppTheme.stroke.withOpacity(0.3), width: AppTheme.strokeThin),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.foreground.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.foreground, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.foreground.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
