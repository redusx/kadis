import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:slider_button/slider_button.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/blood_request_model.dart';
import '../../services/blood_request_service.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _hospitalController = TextEditingController();
  final _noteController = TextEditingController();
  final _unitsNeededController = TextEditingController(text: '1');

  String? _selectedBloodType;
  Urgency _selectedUrgency = Urgency.high;
  bool _sharePhone = false;
  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  double? _latitude;
  double? _longitude;

  final BloodRequestService _requestService = BloodRequestService();

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _noteController.dispose();
    _unitsNeededController.dispose();
    super.dispose();
  }

  /// Kullanıcının konumunu al
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Konum servisi kapalı');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konum izni gerekli. Lütfen ayarlardan izin verin.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (e) {
      debugPrint('Konum alınamadı: $e');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  /// Kan grubu string → BloodType enum dönüşümü
  BloodType? _convertBloodType(String? bloodTypeStr) {
    if (bloodTypeStr == null) return null;
    final map = {
      'A+': BloodType.aRhPos,
      'A-': BloodType.aRhNeg,
      'B+': BloodType.bRhPos,
      'B-': BloodType.bRhNeg,
      'AB+': BloodType.abRhPos,
      'AB-': BloodType.abRhNeg,
      '0+': BloodType.oRhPos,
      '0-': BloodType.oRhNeg,
    };
    return map[bloodTypeStr];
  }

  /// Form doğrulama
  String? _validateForm() {
    if (_selectedBloodType == null) return 'Kan grubu seçiniz';
    if (_hospitalController.text.trim().isEmpty) return 'Hastane/merkez adı giriniz';
    if (_latitude == null || _longitude == null) return 'Konum bilgisi alınamadı';
    final units = int.tryParse(_unitsNeededController.text.trim());
    if (units == null || units < 1) return 'Geçerli bir ünite sayısı giriniz';
    return null;
  }

  /// Talep oluştur
  Future<bool> _submitRequest() async {
    final error = _validateForm();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.orange),
      );
      return false;
    }

    setState(() => _isSubmitting = true);

    try {
      final bloodType = _convertBloodType(_selectedBloodType)!;
      final units = int.parse(_unitsNeededController.text.trim());

      final response = await _requestService.createRequest(
        hospitalName: _hospitalController.text.trim(),
        bloodType: bloodType,
        unitsNeeded: units,
        latitude: _latitude!,
        longitude: _longitude!,
        urgency: _selectedUrgency,
        description: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
      );

      if (!mounted) return false;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kan talebi başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // true = refresh needed
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Talep oluşturulamadı'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _getDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.foreground),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        borderSide: const BorderSide(color: AppTheme.stroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        borderSide: const BorderSide(color: AppTheme.foreground, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talep Oluştur'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blood Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedBloodType,
              decoration: _getDropdownDecoration('Hasta Kan Grubu'),
              dropdownColor: AppTheme.background,
              style: const TextStyle(color: AppTheme.foreground),
              items: _bloodTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _selectedBloodType = value),
            ),
            const SizedBox(height: 12),

            // Hospital/Center
            CustomTextField(
              label: 'Kan Alınacak Merkez / Hastane',
              controller: _hospitalController,
            ),
            const SizedBox(height: 12),

            // Units Needed
            CustomTextField(
              label: 'Gerekli Ünite Sayısı',
              controller: _unitsNeededController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Urgency Dropdown
            DropdownButtonFormField<Urgency>(
              value: _selectedUrgency,
              decoration: _getDropdownDecoration('Aciliyet Seviyesi'),
              dropdownColor: AppTheme.background,
              style: const TextStyle(color: AppTheme.foreground),
              items: Urgency.values.map((u) {
                return DropdownMenuItem(value: u, child: Text(u.displayName));
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedUrgency = value);
              },
            ),
            const SizedBox(height: 12),

            // Note
            CustomTextField(
              label: 'Not (opsiyonel)',
              controller: _noteController,
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // Location status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_latitude != null)
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                border: Border.all(
                  color: (_latitude != null) ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  if (_isGettingLocation)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      (_latitude != null) ? Icons.location_on : Icons.location_off,
                      color: (_latitude != null) ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isGettingLocation
                          ? 'Konum alınıyor...'
                          : (_latitude != null)
                              ? 'Konum alındı ✓'
                              : 'Konum alınamadı',
                      style: TextStyle(
                        color: (_latitude != null) ? Colors.green : Colors.orange,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (_latitude == null && !_isGettingLocation)
                    TextButton(
                      onPressed: _getCurrentLocation,
                      child: const Text('Tekrar Dene'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Phone sharing switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Telefon bilgilerim paylaşılsın',
                  style: TextStyle(
                    color: AppTheme.foreground,
                    fontSize: 16,
                  ),
                ),
                Switch(
                  value: _sharePhone,
                  onChanged: (value) => setState(() => _sharePhone = value),
                  activeColor: AppTheme.foreground,
                  activeTrackColor: AppTheme.foreground.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 30),


            // Action Row: Vazgeç + Slider (Yan Yana)
            if (!_isSubmitting)
              LayoutBuilder(
                builder: (context, constraints) {
                  final halfWidth = (constraints.maxWidth - 12) / 2;
                  return Row(
                    children: [
                      // Vazgeç butonu
                      SizedBox(
                        width: halfWidth,
                        height: 60,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                            ),
                            side: const BorderSide(color: AppTheme.stroke),
                          ),
                          child: const Text('Vazgeç'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Slider Button — varsayılan tasarım
                      SliderButton(
                        width: halfWidth,
                        action: () async {
                          return await _submitRequest();
                        },
                        label: const Text(
                          "Kaydır",
                          style: TextStyle(
                            color: Color(0xff4a4a4a),
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        icon: const Center(
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
