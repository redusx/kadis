import 'package:flutter/material.dart';
import 'package:slider_button/slider_button.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _patientNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _noteController = TextEditingController();
  
  String? _selectedBloodType;
  bool _sharePhone = false;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'];

  @override
  void dispose() {
    _patientNameController.dispose();
    _hospitalController.dispose();
    _noteController.dispose();
    super.dispose();
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
            // Patient Name
            CustomTextField(
              label: 'Hasta Adı',
              controller: _patientNameController,
            ),
            const SizedBox(height: 12),
            
            // Blood Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedBloodType,
              decoration: InputDecoration(
                labelText: 'Hasta Kan Grubu',
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
            const SizedBox(height: 12),
            
            // Hospital/Center
            CustomTextField(
              label: 'Kan Alınacak Merkez',
              controller: _hospitalController,
            ),
            const SizedBox(height: 12),
            
            // Note
            CustomTextField(
              label: 'Not',
              controller: _noteController,
              maxLines: 3,
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
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Vazgeç'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Slider Button for Request Creation
            Center(
              child: SliderButton(
                action: () async {
                  // TODO: Submit request
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Talep oluşturuldu'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  return true;
                },
                label: const Text(
                  "Kaydırmayarak Talep Oluştur",
                  style: TextStyle(
                    color: Color(0xff4a4a4a),
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                ),
                icon: const Text(
                  "→",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 44,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
