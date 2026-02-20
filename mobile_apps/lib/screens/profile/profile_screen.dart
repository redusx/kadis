import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/dialogs/legal_text_dialog.dart';
import '../../services/user_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _logout,
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
          _buildProfileField(
            'Rol',
            _getRoleDisplay(profile.role),
            Icons.badge_outlined,
          ),
          _buildProfileField(
            'Üyelik Tarihi',
            _formatDate(profile.createdAt),
            Icons.access_time_outlined,
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
