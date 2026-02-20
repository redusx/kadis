import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/blood_request_model.dart';
import '../../services/blood_request_service.dart';

class RequestPopupDialog extends StatefulWidget {
  final BloodRequest request;

  const RequestPopupDialog({
    super.key,
    required this.request,
  });

  @override
  State<RequestPopupDialog> createState() => _RequestPopupDialogState();
}

class _RequestPopupDialogState extends State<RequestPopupDialog> {
  bool _isAccepted = false;
  bool _isLoading = false;
  String? _instructions;
  String? _destination;
  String? _errorMessage;

  final BloodRequestService _requestService = BloodRequestService();

  Future<void> _acceptRequest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _requestService.acceptRequest(
        requestId: widget.request.id,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _isAccepted = true;
          _instructions = response.data!['instructions'] as String?;
          _destination = response.data!['destination'] as String?;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Talep kabul edilemedi';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Hata: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            : _isAccepted
                ? _buildAcceptedView()
                : _buildInitialView(),
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Urgency badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getUrgencyColor().withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.request.urgency.displayName,
            style: TextStyle(
              color: _getUrgencyColor(),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        _buildInfoRow('Kan Grubu:', widget.request.bloodType.displayName),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildInfoRow('Gerekli Ünite:', '${widget.request.unitsNeeded}'),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildInfoRow('Kan Alınacak Merkez:', widget.request.hospitalName),
        const SizedBox(height: AppTheme.spacingMedium),

        if (widget.request.description != null &&
            widget.request.description!.isNotEmpty) ...[
          _buildInfoRow('Not:', widget.request.description!),
          const SizedBox(height: AppTheme.spacingMedium),
        ],

        if (widget.request.distanceMeters != null) ...[
          _buildInfoRow('Mesafe:', widget.request.distanceDisplay),
          const SizedBox(height: AppTheme.spacingMedium),
        ],

        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
        ],

        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat'),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: ElevatedButton(
                onPressed: _acceptRequest,
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
        // Success icon
        const Center(
          child: Icon(Icons.check_circle, color: Colors.green, size: 48),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        const Center(
          child: Text(
            'Talep Kabul Edildi!',
            style: TextStyle(
              color: AppTheme.foreground,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),

        if (_instructions != null) ...[
          Text(
            _instructions!,
            style: const TextStyle(
              color: AppTheme.foreground,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
        ],

        if (_destination != null) ...[
          _buildInfoRow('Hedef:', _destination!),
          const SizedBox(height: AppTheme.spacingMedium),
        ],

        _buildInfoRow('Kan Grubu:', widget.request.bloodType.displayName),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildInfoRow('Merkez:', widget.request.hospitalName),
        const SizedBox(height: AppTheme.spacingLarge),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tamam'),
          ),
        ),
      ],
    );
  }

  Color _getUrgencyColor() {
    switch (widget.request.urgency) {
      case Urgency.critical:
        return Colors.red;
      case Urgency.high:
        return Colors.orange;
      case Urgency.medium:
        return Colors.amber;
      case Urgency.low:
        return Colors.green;
    }
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
