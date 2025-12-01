import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.foreground),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.foreground),
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
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.foreground),
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
      ),
      dropdownColor: AppTheme.background,
      style: const TextStyle(color: AppTheme.foreground),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class DatePickerField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;

  const DatePickerField({
    super.key,
    required this.label,
    this.controller,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      readOnly: true,
      style: const TextStyle(color: AppTheme.foreground),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: AppTheme.foreground),
        suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.foreground),
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
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark(),
              child: child!,
            );
          },
        );
        if (picked != null && widget.controller != null) {
          widget.controller!.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      },
    );
  }
}
