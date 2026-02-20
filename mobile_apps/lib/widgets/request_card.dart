import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/blood_request_model.dart';

class RequestCard extends StatelessWidget {
  final BloodRequest request;
  final VoidCallback? onTap;

  const RequestCard({
    super.key,
    required this.request,
    this.onTap,
  });

  /// Aciliyet seviyesine göre renk
  Color _getUrgencyColor() {
    switch (request.urgency) {
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

  /// Durum rengini belirle
  Color _getStatusColor() {
    switch (request.status) {
      case RequestStatus.pending:
        return Colors.amber;
      case RequestStatus.active:
        return Colors.green;
      case RequestStatus.fulfilled:
        return Colors.blue;
      case RequestStatus.cancelled:
        return Colors.grey;
      case RequestStatus.expired:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.startEndPadding),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            side: BorderSide(
              color: AppTheme.foreground.withOpacity(0.5),
              width: 1,
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
                  // Urgency indicator
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: _getUrgencyColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getUrgencyColor().withOpacity(0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        request.bloodType.displayName,
                        style: TextStyle(
                          color: _getUrgencyColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppTheme.spacingMedium),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hospital Name
                        Text(
                          request.hospitalName,
                          style: const TextStyle(
                            color: AppTheme.foreground,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),

                        // Status + Urgency row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                request.status.displayName,
                                style: TextStyle(
                                  color: _getStatusColor(),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getUrgencyColor().withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                request.urgency.displayName,
                                style: TextStyle(
                                  color: _getUrgencyColor(),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Units + distance
                        Row(
                          children: [
                            Text(
                              '${request.unitsNeeded} ünite',
                              style: TextStyle(
                                color: AppTheme.foreground.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                            if (request.distanceMeters != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppTheme.foreground.withOpacity(0.5),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                request.distanceDisplay,
                                style: TextStyle(
                                  color: AppTheme.foreground.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.chevron_right,
                    color: AppTheme.foreground.withOpacity(0.5),
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