import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RequestPopupDialog extends StatefulWidget {
  final String patientName;
  final String bloodType;
  final String hospital;
  final String? note;
  final bool isAccepted;
  final String? donorContactInfo;

  const RequestPopupDialog({
    super.key,
    required this.patientName,
    required this.bloodType,
    required this.hospital,
    this.note,
    this.isAccepted = false,
    this.donorContactInfo,
  });

  @override
  State<RequestPopupDialog> createState() => _RequestPopupDialogState();
}

class _RequestPopupDialogState extends State<RequestPopupDialog> {
  late bool _isAccepted;

  @override
  void initState() {
    super.initState();
    _isAccepted = widget.isAccepted;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        side: const BorderSide(color: AppTheme.stroke, width: AppTheme.strokeThin),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: _isAccepted ? _buildAcceptedView() : _buildInitialView(),
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Hasta Adı:', widget.patientName),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildInfoRow('Kan Grubu:', widget.bloodType),
        const SizedBox(height: AppTheme.spacingMedium),
        if (widget.note != null && widget.note!.isNotEmpty) ...[
          _buildInfoRow('Not:', widget.note!),
          const SizedBox(height: AppTheme.spacingMedium),
        ],
        _buildInfoRow('Kan Alınacak Merkez:', widget.hospital),
        const SizedBox(height: AppTheme.spacingLarge),
        
        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Reddet'),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isAccepted = true;
                  });
                },
                child: const Text('Talebi Kabul Et'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcceptedView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İşlem alındı. Talep bekleme/askıya alındı. İletişim bilgileriniz hasta yakınına bildirildi. Bağış için en kısa sürede kan alma merkezinde bekleniyorsunuz. Aksi takdirde talebi reddediniz.',
          style: TextStyle(
            color: AppTheme.foreground,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),
        
        _buildInfoRow('Hasta Yakını İletişim:', widget.donorContactInfo ?? 'Bilgi bekleniyor...'),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildInfoRow('Kan Alınacak Merkez:', widget.hospital),
        const SizedBox(height: AppTheme.spacingLarge),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Bağışı Reddet'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.foreground,
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.foreground,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
