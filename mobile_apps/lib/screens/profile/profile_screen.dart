import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/dialogs/legal_text_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  int _selectedIndex = 2;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Fields
          _buildProfileField('Ad Soyad', 'Ahmet Yılmaz', Icons.person_outline),
          _buildProfileField('Kan Grubu', 'A+', Icons.bloodtype_outlined),
          _buildProfileField('E-posta', 'ahmet@example.com', Icons.email_outlined),
          _buildProfileField('Telefon', '0532 123 45 67', Icons.phone_outlined),
          _buildProfileField('İl / İlçe', 'İstanbul / Kadıköy', Icons.location_city_outlined),
          _buildProfileField('Adres', 'Sokak Adı, Mahalle', Icons.home_outlined),
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
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.foreground),
            onPressed: () {
              // TODO: Edit profile field
            },
          ),
        ],
      ),
    );
  }
}
