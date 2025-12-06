import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _confirmPasswordReset() {
    // UI only validation
    if (_newPasswordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifreler eşleşmiyor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show success message and navigate to login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Şifreniz başarıyla güncellendi!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to login screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Şifre Oluştur'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  height: 100,
                  width: 100,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: AppTheme.foreground,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.vpn_key,
                    size: 50,
                    color: AppTheme.background,
                  ),
                ),

                // Title
                const Text(
                  'Yeni Şifre Oluştur',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.foreground,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Hesabınız için yeni bir şifre belirleyin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.foreground.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                // New Password Field
                CustomTextField(
                  label: 'Yeni Şifre',
                  controller: _newPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                CustomTextField(
                  label: 'Yeni Şifre Tekrar',
                  controller: _confirmPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // Confirm Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _confirmPasswordReset,
                    child: const Text('Onayla'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
