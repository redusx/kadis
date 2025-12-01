import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RequestsListScreen extends StatelessWidget {
  const RequestsListScreen({super.key});

  void _showEditRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _EditRequestDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taleplerim'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildRequestCard(
            context,
            patientName: 'Mehmet Yılmaz',
            bloodType: 'A+',
            hospital: 'Şişli Etfal Hastanesi',
            status: 'Aktif — Donör bekleniyor',
            isActive: true,
          ),
          _buildRequestCard(
            context,
            patientName: 'Ayşe Demir',
            bloodType: '0-',
            hospital: 'Bakırköy Dr. Sadi Konuk EAH',
            status: 'Askıya alındı — Donör bulundu',
            isActive: false,
            donorInfo: 'Ahmet K. - 0532 123 45 67',
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context, {
    required String patientName,
    required String bloodType,
    required String hospital,
    required String status,
    required bool isActive,
    String? donorInfo,
  }) {
    return Card(
      child: InkWell(
        onTap: () => _showEditRequestDialog(context),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patientName,
                style: const TextStyle(
                  color: AppTheme.foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                'Kan Grubu: $bloodType',
                style: const TextStyle(
                  color: AppTheme.foreground,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                hospital,
                style: const TextStyle(
                  color: AppTheme.foreground,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? Colors.green : Colors.orange,
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (donorInfo != null) ...[
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  'Donör: $donorInfo',
                  style: const TextStyle(
                    color: AppTheme.foreground,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EditRequestDialog extends StatefulWidget {
  @override
  State<_EditRequestDialog> createState() => _EditRequestDialogState();
}

class _EditRequestDialogState extends State<_EditRequestDialog> {
  final _patientNameController = TextEditingController(text: 'Mehmet Yılmaz');
  final _hospitalController = TextEditingController(text: 'Şişli Etfal Hastanesi');
  final _noteController = TextEditingController(text: 'Acil kan ihtiyacı');
  String? _selectedBloodType = 'A+';

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
    return Dialog(
      backgroundColor: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        side: const BorderSide(color: AppTheme.stroke),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Talebi Düzenle',
                style: TextStyle(
                  color: AppTheme.foreground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Patient Name
              TextField(
                controller: _patientNameController,
                style: const TextStyle(color: AppTheme.foreground),
                decoration: InputDecoration(
                  labelText: 'Hasta Adı',
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
              ),
              const SizedBox(height: 12),
              
              // Blood Type
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
              const SizedBox(height: 12),
              
              // Hospital
              TextField(
                controller: _hospitalController,
                style: const TextStyle(color: AppTheme.foreground),
                decoration: InputDecoration(
                  labelText: 'Kan Alınacak Merkez',
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
              ),
              const SizedBox(height: 12),
              
              // Note
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.foreground),
                decoration: InputDecoration(
                  labelText: 'Not',
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
              ),
              const SizedBox(height: 20),
              
              // Status indicator
              const Text(
                'Durum: Aktif — Donör bekleniyor',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Delete request
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Talebi Sil'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Talep güncellendi'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
