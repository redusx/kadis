import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';

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
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: AppTheme.foreground),
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
          _buildProfileField('Ad Soyad', 'Ahmet Yılmaz'),
          const SizedBox(height: 12),
          _buildProfileField('Kan Grubu', 'A+'),
          const SizedBox(height: 12),
          _buildProfileField('E-posta', 'ahmet@example.com'),
          const SizedBox(height: 12),
          _buildProfileField('Telefon', '0532 123 45 67'),
          const SizedBox(height: 12),
          _buildProfileField('İl / İlçe', 'İstanbul / Kadıköy'),
          const SizedBox(height: 12),
          _buildProfileField('Adres', 'Sokak Adı, Mahalle'),
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
              border: Border.all(color: AppTheme.stroke, width: AppTheme.strokeThin),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: SwitchListTile(
              title: const Text(
                'Bildirimleri Aç/Kapat',
                style: TextStyle(color: AppTheme.foreground),
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
              // TODO: Show KVKK text
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
              // TODO: Show Aydınlatma metni
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

  Widget _buildProfileField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.stroke, width: AppTheme.strokeThin),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
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
            icon: const Icon(Icons.edit, color: AppTheme.foreground),
            onPressed: () {
              // TODO: Edit profile field
            },
          ),
        ],
      ),
    );
  }
}
