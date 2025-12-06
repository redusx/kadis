import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/hospital_model.dart';

/// Bottom sheet widget to display hospital details
class HospitalBottomSheet extends StatelessWidget {
  final Hospital hospital;

  const HospitalBottomSheet({
    super.key,
    required this.hospital,
  });

  /// Show the bottom sheet
  static void show(BuildContext context, Hospital hospital) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => HospitalBottomSheet(hospital: hospital),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: AppTheme.stroke, width: 1),
          left: BorderSide(color: AppTheme.stroke, width: 1),
          right: BorderSide(color: AppTheme.stroke, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.foreground.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Hospital icon and name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        color: AppTheme.foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hospital.hasEmergency) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.emergency,
                            color: Colors.red.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Acil Servis Mevcut',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Details
          if (hospital.city != null || hospital.district != null)
            _buildInfoRow(
              Icons.location_on_outlined,
              [hospital.city, hospital.district].whereType<String>().join(', '),
            ),
          
          if (hospital.phone != null)
            _buildInfoRow(Icons.phone_outlined, hospital.phone!),
          
          if (hospital.website != null)
            _buildInfoRow(Icons.language_outlined, hospital.website!),
          
          if (hospital.operator != null)
            _buildInfoRow(Icons.business_outlined, hospital.operator!),

          const SizedBox(height: 20),

          // Close button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.foreground.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.foreground.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
