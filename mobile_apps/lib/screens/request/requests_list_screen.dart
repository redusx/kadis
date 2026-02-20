import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/blood_request_model.dart';
import '../../services/blood_request_service.dart';
import '../../services/token_storage.dart';

class RequestsListScreen extends StatefulWidget {
  const RequestsListScreen({super.key});

  @override
  State<RequestsListScreen> createState() => _RequestsListScreenState();
}

class _RequestsListScreenState extends State<RequestsListScreen> {
  List<BloodRequest> _myRequests = [];
  bool _isLoading = true;
  String? _currentUserId;

  final BloodRequestService _requestService = BloodRequestService();

  @override
  void initState() {
    super.initState();
    _loadMyRequests();
  }

  Future<void> _loadMyRequests() async {
    setState(() => _isLoading = true);
    try {
      _currentUserId = await TokenStorage.getUserId();
      final response = await _requestService.getAllRequests();

      if (mounted && response.success && response.data != null) {
        setState(() {
          // Sadece bu kullanıcının taleplerini filtrele
          _myRequests = response.data!
              .where((r) => r.requesterId == _currentUserId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        });
      }
    } catch (e) {
      debugPrint('Talepler yüklenemedi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDonation(BloodRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text(
          'Bağışı Onayla',
          style: TextStyle(color: AppTheme.foreground),
        ),
        content: const Text(
          'Bu talep için yapılan bağışı onaylıyor musunuz?',
          style: TextStyle(color: AppTheme.foreground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await _requestService.confirmDonation(
        requestId: request.id,
      );

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bağış başarıyla onaylandı!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadMyRequests(); // Listeyi yenile
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Onaylama başarısız'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Durum rengini belirle
  Color _getStatusColor(RequestStatus status) {
    switch (status) {
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

  /// Durum ikonunu belirle
  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.hourglass_empty;
      case RequestStatus.active:
        return Icons.check_circle_outline;
      case RequestStatus.fulfilled:
        return Icons.verified;
      case RequestStatus.cancelled:
        return Icons.cancel_outlined;
      case RequestStatus.expired:
        return Icons.timer_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taleplerim'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: AppTheme.foreground.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz talep oluşturmadınız',
                        style: TextStyle(
                          color: AppTheme.foreground.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMyRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _myRequests.length,
                    itemBuilder: (context, index) {
                      final request = _myRequests[index];
                      return _buildRequestCard(request);
                    },
                  ),
                ),
    );
  }

  Widget _buildRequestCard(BloodRequest request) {
    final statusColor = _getStatusColor(request.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Hospital + Blood Type
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.hospitalName,
                    style: const TextStyle(
                      color: AppTheme.foreground,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    request.bloodType.displayName,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),

            // Units + Urgency
            Row(
              children: [
                Text(
                  '${request.unitsNeeded} ünite',
                  style: TextStyle(
                    color: AppTheme.foreground.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Aciliyet: ${request.urgency.displayName}',
                  style: TextStyle(
                    color: AppTheme.foreground.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(request.status),
                    color: statusColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    request.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),

            // Created date
            Text(
              'Oluşturulma: ${_formatDate(request.createdAt)}',
              style: TextStyle(
                color: AppTheme.foreground.withOpacity(0.5),
                fontSize: 12,
              ),
            ),

            // Confirm donation button (only for ACTIVE requests)
            if (request.status == RequestStatus.active) ...[
              const SizedBox(height: AppTheme.spacingMedium),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmDonation(request),
                  icon: const Icon(Icons.verified, size: 18),
                  label: const Text('Bağışı Onayla'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
