import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dialogs/legal_text_dialog.dart';
import '../../models/address_models.dart';
import '../../services/address_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _passwordController = TextEditingController();
  final MapController _mapController = MapController();

  // Form fields
  String? _selectedBloodType;
  bool _kvkkAccepted = false;
  bool _aydinlatmaAccepted = false;

  // Blood types
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'];

  // Address data
  List<CityModel> _cities = [];
  CityModel? _selectedCity;
  TownModel? _selectedTown;
  DistrictModel? _selectedDistrict;
  QuarterModel? _selectedQuarter;

  // Map location
  double _selectedLat = 41.0082; // Default: Istanbul
  double _selectedLong = 28.9784;
  bool _isLoadingLocation = true;
  bool _isLoadingCities = true;

  void _showLegalDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => LegalTextDialog(title: title, content: content),
    );
  }

  final String _kvkkText = """
Kişisel Verilerin Korunması Kanunu (KVKK) kapsamında, kişisel verileriniz...
(Buraya uzun KVKK metni gelecek)
...
""";

  final String _aydinlatmaText = """
Aydınlatma Metni kapsamında, verilerinizin işlenme amaçları...
(Buraya uzun Aydınlatma metni gelecek)
...
""";

  @override
  void initState() {
    super.initState();
    _loadCities();
    _getCurrentLocation();
  }

  Future<void> _loadCities() async {
    final cities = await AddressService.loadCities();
    setState(() {
      _cities = cities;
      _isLoadingCities = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setDefaultLocation();
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setDefaultLocation();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLat = position.latitude;
        _selectedLong = position.longitude;
        _isLoadingLocation = false;
      });

      // Move map to current location
      _mapController.move(LatLng(_selectedLat, _selectedLong), 15);
    } catch (e) {
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    setState(() {
      _selectedLat = 41.0082; // Istanbul
      _selectedLong = 28.9784;
      _isLoadingLocation = false;
    });
  }

  void _onCityChanged(CityModel? city) {
    setState(() {
      _selectedCity = city;
      _selectedTown = null;
      _selectedDistrict = null;
      _selectedQuarter = null;
    });
  }

  void _onTownChanged(TownModel? town) {
    setState(() {
      _selectedTown = town;
      _selectedDistrict = null;
      _selectedQuarter = null;
    });
  }

  void _onDistrictChanged(DistrictModel? district) {
    setState(() {
      _selectedDistrict = district;
      _selectedQuarter = null;
    });
  }

  void _onQuarterChanged(QuarterModel? quarter) {
    setState(() {
      _selectedQuarter = quarter;
    });
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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        borderSide: BorderSide(color: AppTheme.stroke.withOpacity(0.5)),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Name
              CustomTextField(
                label: 'Ad',
                controller: _firstNameController,
              ),
              const SizedBox(height: 10),

              // Last Name
              CustomTextField(
                label: 'Soyad',
                controller: _lastNameController,
              ),
              const SizedBox(height: 10),

              // Blood Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBloodType,
                decoration: _getDropdownDecoration('Kan Grubu'),
                dropdownColor: AppTheme.background,
                style: const TextStyle(color: AppTheme.foreground),
                items: _bloodTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _selectedBloodType = value),
              ),
              const SizedBox(height: 10),

              // Email
              CustomTextField(
                label: 'E-posta',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),

              // Birth Date
              DatePickerField(
                label: 'Doğum Tarihi',
                controller: _birthDateController,
              ),
              const SizedBox(height: 10),

              // Phone
              CustomTextField(
                label: 'Telefon Numarası',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // Address Section Header
              const Text(
                'Adres Bilgileri',
                style: TextStyle(
                  color: AppTheme.foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // City Dropdown (İl)
              _isLoadingCities
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<CityModel>(
                      value: _selectedCity,
                      decoration: _getDropdownDecoration('İl'),
                      dropdownColor: AppTheme.background,
                      style: const TextStyle(color: AppTheme.foreground),
                      isExpanded: true,
                      menuMaxHeight: 300,
                      items: _cities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city.name),
                        );
                      }).toList(),
                      onChanged: _onCityChanged,
                    ),
              const SizedBox(height: 10),

              // Town Dropdown (İlçe)
              DropdownButtonFormField<TownModel>(
                value: _selectedTown,
                decoration: _getDropdownDecoration('İlçe'),
                dropdownColor: AppTheme.background,
                style: const TextStyle(color: AppTheme.foreground),
                isExpanded: true,
                menuMaxHeight: 300,
                items: _selectedCity?.towns.map((town) {
                      return DropdownMenuItem(
                        value: town,
                        child: Text(town.name),
                      );
                    }).toList() ??
                    [],
                onChanged: _selectedCity != null ? _onTownChanged : null,
              ),
              const SizedBox(height: 10),

              // District Dropdown (Semt)
              DropdownButtonFormField<DistrictModel>(
                value: _selectedDistrict,
                decoration: _getDropdownDecoration('Semt'),
                dropdownColor: AppTheme.background,
                style: const TextStyle(color: AppTheme.foreground),
                isExpanded: true,
                menuMaxHeight: 300,
                items: _selectedTown?.districts.map((district) {
                      return DropdownMenuItem(
                        value: district,
                        child: Text(district.name),
                      );
                    }).toList() ??
                    [],
                onChanged: _selectedTown != null ? _onDistrictChanged : null,
              ),
              const SizedBox(height: 10),

              // Quarter Dropdown (Mahalle)
              DropdownButtonFormField<QuarterModel>(
                value: _selectedQuarter,
                decoration: _getDropdownDecoration('Mahalle'),
                dropdownColor: AppTheme.background,
                style: const TextStyle(color: AppTheme.foreground),
                isExpanded: true,
                menuMaxHeight: 300,
                items: _selectedDistrict?.quarters.map((quarter) {
                      return DropdownMenuItem(
                        value: quarter,
                        child: Text(quarter.name),
                      );
                    }).toList() ??
                    [],
                onChanged: _selectedDistrict != null ? _onQuarterChanged : null,
              ),
              const SizedBox(height: 10),

              // Street
              CustomTextField(
                label: 'Sokak / Cadde',
                controller: _streetController,
              ),
              const SizedBox(height: 20),

              // Map Section Header
              const Text(
                'Konumunuzu Haritadan İşaretleyin',
                style: TextStyle(
                  color: AppTheme.foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Haritayı sürükleyerek konumunuzu belirleyin',
                style: TextStyle(
                  color: AppTheme.foreground.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),

              // Map with fixed center pin
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: AppTheme.stroke),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    _isLoadingLocation
                        ? const Center(child: CircularProgressIndicator())
                        : FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(_selectedLat, _selectedLong),
                              initialZoom: 15,
                              onPositionChanged: (position, hasGesture) {
                                if (hasGesture) {
                                  setState(() {
                                    _selectedLat = position.center.latitude;
                                    _selectedLong = position.center.longitude;
                                  });
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.kabis',
                              ),
                            ],
                          ),
                    // Fixed center pin
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(
                          Icons.location_pin,
                          size: 50,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),

              // Coordinates display
              Text(
                'Seçilen Konum: ${_selectedLat.toStringAsFixed(6)}, ${_selectedLong.toStringAsFixed(6)}',
                style: TextStyle(
                  color: AppTheme.foreground.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),

              // Password
              CustomTextField(
                label: 'Şifre',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // KVKK Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _kvkkAccepted,
                    onChanged: (value) =>
                        setState(() => _kvkkAccepted = value ?? false),
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppTheme.foreground;
                      }
                      return Colors.transparent;
                    }),
                    checkColor: AppTheme.background,
                    side: const BorderSide(color: AppTheme.foreground),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showLegalDialog('KVKK Metni', _kvkkText),
                      child: const Text(
                        'KVKK Metnini Okudum ve Onaylıyorum',
                        style: TextStyle(
                          color: AppTheme.foreground,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Aydınlatma Metni Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _aydinlatmaAccepted,
                    onChanged: (value) =>
                        setState(() => _aydinlatmaAccepted = value ?? false),
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppTheme.foreground;
                      }
                      return Colors.transparent;
                    }),
                    checkColor: AppTheme.background,
                    side: const BorderSide(color: AppTheme.foreground),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          _showLegalDialog('Aydınlatma Metni', _aydinlatmaText),
                      child: const Text(
                        'Aydınlatma Metnini Okudum ve Onaylıyorum',
                        style: TextStyle(
                          color: AppTheme.foreground,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Register Button
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_kvkkAccepted && _aydinlatmaAccepted)
                      ? () {
                          // Here you would collect all form data including:
                          // - _selectedCity, _selectedTown, _selectedDistrict, _selectedQuarter
                          // - _selectedLat, _selectedLong
                          // And send to backend
                          Navigator.pushReplacementNamed(context, AppRoutes.home);
                        }
                      : null,
                  child: const Text('KAYIT OL'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DatePickerField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;

  const DatePickerField({
    super.key,
    required this.label,
    this.controller,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      readOnly: true,
      style: const TextStyle(color: AppTheme.foreground),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: AppTheme.foreground),
        suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.foreground),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          borderSide: const BorderSide(color: AppTheme.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          borderSide: const BorderSide(color: AppTheme.foreground, width: 2),
        ),
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark(),
              child: child!,
            );
          },
        );
        if (picked != null && widget.controller != null) {
          widget.controller!.text =
              "${picked.day}/${picked.month}/${picked.year}";
        }
      },
    );
  }
}
