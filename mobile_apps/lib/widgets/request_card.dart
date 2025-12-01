import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class RequestCard extends StatelessWidget {
  final String hospitalName;
  final String bloodType;
  final String patientName;
  final VoidCallback? onTap;

  const RequestCard({
    super.key,
    required this.hospitalName,
    required this.bloodType,
    required this.patientName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. ADIM: Kartın sağ ve sol kenarlardan boşluk bırakılması için Padding widget'ı eklenir.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.startEndPadding), 
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 2, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            side: BorderSide(
              color: AppTheme.foreground.withOpacity(0.5), // Çerçeve rengi (Hafif gri/görünür)
              width: 1, // Çerçeve kalınlığı
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.defaultPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo at left
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.foreground.withOpacity(0.1), 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: AppTheme.spacingMedium),
                  
                  // Content at right
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hospital Name
                        Text(
                          hospitalName,
                          style: const TextStyle(
                            color: AppTheme.foreground,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        
                        // Blood Type
                        Text(
                          'Kan Grubu: $bloodType',
                          style: const TextStyle(
                            color: AppTheme.foreground, 
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        // Patient Name
                        Text(
                          'Hasta: $patientName',
                          style: TextStyle(
                            color: AppTheme.foreground.withOpacity(0.7), 
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}