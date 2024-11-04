import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? color; // Background color
  final Color? textColor; // Text and icon color

  const CustomButton({
    Key? key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.color,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null
          ? Icon(icon, color: textColor ?? Colors.white)
          : const SizedBox.shrink(),
      label: Text(
        label,
        style: TextStyle(color: textColor ?? Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        foregroundColor: textColor, // Optional: apply to both icon and label
      ),
    );
  }
}
