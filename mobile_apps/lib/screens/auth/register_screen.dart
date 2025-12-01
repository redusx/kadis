import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';

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
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _selectedBloodType;
  String? _selectedCity;
  String? _selectedDistrict;
  bool _kvkkAccepted = false;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'];
  final List<String> _cities = ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya'];
  final List<String> _districts = ['Kadıköy', 'Beşiktaş', 'Üsküdar', 'Şişli'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _locationController.dispose();
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
                decoration: InputDecoration(
                  labelText: 'Kan Grubu',
                  labelStyle: const TextStyle(color: AppTheme.foreground),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    borderSide: const BorderSide(color: AppTheme.stroke),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    borderSide: const BorderSide(color: AppTheme.foreground, width: 2),
                  ),
                ),
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
              const SizedBox(height: 10),
              
              // City and District Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: InputDecoration(
                        labelText: 'İl',
                        labelStyle: const TextStyle(color: AppTheme.foreground),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          borderSide: const BorderSide(color: AppTheme.stroke),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          borderSide: const BorderSide(color: AppTheme.foreground, width: 2),
                        ),
                      ),
                      dropdownColor: AppTheme.background,
                      style: const TextStyle(color: AppTheme.foreground),
                      items: _cities.map((city) {
                        return DropdownMenuItem(value: city, child: Text(city));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCity = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      decoration: InputDecoration(
                        labelText: 'İlçe',
                        labelStyle: const TextStyle(color: AppTheme.foreground),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          borderSide: const BorderSide(color: AppTheme.stroke),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          borderSide: const BorderSide(color: AppTheme.foreground, width: 2),
                        ),
                      ),
                      dropdownColor: AppTheme.background,
                      style: const TextStyle(color: AppTheme.foreground),
                      items: _districts.map((district) {
                        return DropdownMenuItem(value: district, child: Text(district));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedDistrict = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Street
              CustomTextField(
                label: 'Sokak / Cadde',
                controller: _streetController,
              ),
              const SizedBox(height: 10),
              
              // Full Location
              CustomTextField(
                label: 'Tam Konum Bilgisi',
                controller: _locationController,
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
                    onChanged: (value) => setState(() => _kvkkAccepted = value ?? false),
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppTheme.foreground;
                      }
                      return Colors.transparent;
                    }),
                    checkColor: AppTheme.background,
                    side: const BorderSide(color: AppTheme.foreground),
                  ),
                  const Expanded(
                    child: Text(
                      'KVKK Metni ve Aydınlatma Metnini Onaylıyorum',
                      style: TextStyle(color: AppTheme.foreground, fontSize: 12),
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
                  onPressed: _kvkkAccepted
                      ? () {
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
          widget.controller!.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      },
    );
  }
}
