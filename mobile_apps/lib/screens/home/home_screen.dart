import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/request_card.dart';
import '../../widgets/dialogs/request_popup_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 1) {
      // Navigate to Create Request
      Navigator.pushNamed(context, AppRoutes.createRequest);
    } else if (index == 2) {
      // Navigate to Profile
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  void _showRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => const RequestPopupDialog(
        patientName: 'Mehmet Yılmaz',
        bloodType: 'A+',
        hospital: 'Şişli Etfal Hastanesi',
        note: 'Acil kan ihtiyacı var',
        donorContactInfo: 'Tel: 0532 123 45 67',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text('KADİS'),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map Container
            Container(
              height: 280,
              width: double.infinity,
              margin: const EdgeInsets.all(AppTheme.defaultPadding),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.stroke,
                  width: AppTheme.strokeThin,
                ),
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      color: AppTheme.foreground,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'OPEN STREET MAP',
                      style: TextStyle(
                        color: AppTheme.foreground,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Taleplerim Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.defaultPadding),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.requestsList);
                  },
                  child: const Text('Taleplerim'),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Request Status Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.defaultPadding),
                  child: Text(
                    'Aktif Çağrılar',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: AppTheme.foreground,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                
                // Sample Request Cards
                RequestCard(
                  hospitalName: 'Şişli Etfal Hastanesi',
                  bloodType: 'A+',
                  patientName: 'Mehmet Yılmaz',
                  onTap: _showRequestDialog,
                ),
                RequestCard(
                  hospitalName: 'Bakırköy Dr. Sadi Konuk EAH',
                  bloodType: '0-',
                  patientName: 'Ayşe Demir',
                  onTap: _showRequestDialog,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
