import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LegalTextDialog extends StatelessWidget {
  final String title;
  final String content;

  const LegalTextDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        side: const BorderSide(color: AppTheme.stroke, width: AppTheme.strokeThin),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.foreground,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(color: AppTheme.stroke, height: 1),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                content,
                style: const TextStyle(
                  color: AppTheme.foreground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const Divider(color: AppTheme.stroke, height: 1),
          
          // Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Okudum'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
