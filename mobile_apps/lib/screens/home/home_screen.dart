import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/request_card.dart';
import '../../widgets/dialogs/request_popup_dialog.dart';
import '../../widgets/hospital_bottom_sheet.dart';
import '../../models/hospital_model.dart';
import '../../services/hospital_service.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isMapExpanded = false;
  final MapController _mapController = MapController();
  
  // Hospital data
  List<Hospital> _hospitals = [];
  bool _isLoadingHospitals = true;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    final hospitals = await HospitalService.loadHospitals();
    if (mounted) {
      setState(() {
        _hospitals = hospitals;
        _isLoadingHospitals = false;
      });
    }
  }

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
      body: _isMapExpanded
          ? _buildMapWidget(isExpanded: true)
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Map Container
                  _buildMapWidget(isExpanded: false),
                  
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

  Widget _buildMapWidget({required bool isExpanded}) {
    return Container(
      height: isExpanded ? double.infinity : 280,
      width: double.infinity,
      margin: isExpanded ? EdgeInsets.zero : const EdgeInsets.all(AppTheme.defaultPadding),
      decoration: BoxDecoration(
        border: isExpanded ? null : Border.all(
          color: AppTheme.stroke,
          width: AppTheme.strokeThin,
        ),
        borderRadius: isExpanded ? null : BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: isExpanded ? BorderRadius.zero : BorderRadius.circular(AppTheme.borderRadius),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(39.0, 35.0), // Türkiye merkezi
                initialZoom: 6.0,
                minZoom: 4.8,
                maxZoom: 18.0,
                cameraConstraint: CameraConstraint.containCenter(
                  bounds: LatLngBounds(
                    const LatLng(36.0, 26.0),
                    const LatLng(42.1, 45.0),
                  ),
                ),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.kabis',
                ),
                // Hospital markers with clustering
                _isLoadingHospitals
                    ? const SizedBox.shrink()
                    : MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                          maxClusterRadius: 80,
                          size: const Size(50, 50),
                          markers: _hospitals.map((hospital) => Marker(
                            point: hospital.latLng,
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => HospitalBottomSheet.show(context, hospital),
                              child: const Icon(
                                Icons.local_hospital,
                                color: Colors.red,
                                size: 32,
                              ),
                            ),
                          )).toList(),
                          builder: (context, markers) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  markers.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
          // Loading indicator
          if (_isLoadingHospitals)
            const Positioned(
              top: 16,
              left: 16,
              child: CircularProgressIndicator(
                color: Colors.red,
                strokeWidth: 2,
              ),
            ),
          // Hospital count badge
          if (!_isLoadingHospitals)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.background.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.stroke),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_hospital, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_hospitals.length} Hastane',
                      style: const TextStyle(
                        color: AppTheme.foreground,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'map_toggle',
              backgroundColor: AppTheme.background,
              foregroundColor: AppTheme.foreground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppTheme.stroke),
              ),
              onPressed: () {
                setState(() {
                  _isMapExpanded = !_isMapExpanded;
                });
              },
              child: Icon(isExpanded ? Icons.fullscreen_exit : Icons.fullscreen),
            ),
          ),
        ],
      ),
    );
  }
}
