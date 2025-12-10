import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => HospitalBottomSheet(hospital: hospital),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: AppTheme.stroke, width: 1),
          left: BorderSide(color: AppTheme.stroke, width: 1),
          right: BorderSide(color: AppTheme.stroke, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.foreground.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Hospital Image
            if (hospital.hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  hospital.imageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        color: Colors.red,
                        size: 60,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.red,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Hospital Name
            Text(
              hospital.name,
              style: const TextStyle(
                color: AppTheme.foreground,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Category
            if (hospital.category != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hospital.category!,
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Address
            if (hospital.address != null)
              _buildInfoRow(
                Icons.location_on_outlined,
                hospital.address!,
              ),
            
            // Phone
            if (hospital.phone != null)
              _buildInfoRow(
                Icons.phone_outlined,
                hospital.phone!,
                onTap: () => _launchUrl('tel:${hospital.phone}'),
              ),
            
            // Website
            if (hospital.website != null)
              _buildInfoRow(
                Icons.language_outlined,
                hospital.website!,
                onTap: () => _launchUrl(hospital.website!),
              ),

            const SizedBox(height: 20),

            // Google Maps Button
            if (hospital.hasGoogleMapsUrl)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(hospital.url!),
                  icon: const Icon(Icons.directions),
                  label: const Text('Google Maps\'te Aç'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {VoidCallback? onTap}) {
    Widget content = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                color: onTap != null 
                    ? Colors.blue.shade300 
                    : AppTheme.foreground.withOpacity(0.9),
                fontSize: 14,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
