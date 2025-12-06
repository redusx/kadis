import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class VerificationCodeDialog extends StatefulWidget {
  final VoidCallback onCodeVerified;

  const VerificationCodeDialog({
    super.key,
    required this.onCodeVerified,
  });

  @override
  State<VerificationCodeDialog> createState() => _VerificationCodeDialogState();
}

class _VerificationCodeDialogState extends State<VerificationCodeDialog> {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto focus on the text field when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    // When 6 digits are entered, verify the code
    if (value.length == 6) {
      // Simulate verification (UI only)
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onCodeVerified();
      });
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: AppTheme.foreground,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 32,
                color: AppTheme.background,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Kod Gönderildi!',
              style: TextStyle(
                color: AppTheme.foreground,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'E-posta adresinize gönderilen 6 haneli doğrulama kodunu girin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.foreground.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Code Input Field
            TextField(
              controller: _codeController,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(
                color: AppTheme.foreground,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: '',
                hintText: '000000',
                hintStyle: TextStyle(
                  color: AppTheme.foreground.withOpacity(0.3),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  borderSide: const BorderSide(
                    color: AppTheme.stroke,
                    width: AppTheme.strokeThin,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  borderSide: const BorderSide(
                    color: AppTheme.foreground,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: _onCodeChanged,
            ),
            const SizedBox(height: 16),

            // Resend Code Text Button
            TextButton(
              onPressed: () {
                // UI only - would resend code in real implementation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Yeni kod gönderildi!'),
                    backgroundColor: AppTheme.foreground,
                  ),
                );
              },
              child: const Text('Kodu tekrar gönder'),
            ),
            const SizedBox(height: 8),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'İptal',
                style: TextStyle(
                  color: AppTheme.foreground.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
