// import 'package:flutter/material.dart';

// class AppTextField extends StatelessWidget {

//   const AppTextField({
//     required this.controller, required this.label, super.key,
//     this.icon,
//     this.obscure = false,
//     this.keyboardType = TextInputType.text,
//     this.maxLines = 1,
//     this.enabled = true,
//     this.suffix,
//   });
//   final TextEditingController controller;
//   final String label;
//   final IconData? icon;
//   final bool obscure;
//   final TextInputType keyboardType;
//   final int maxLines;
//   final bool enabled;
//   final Widget? suffix;

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       keyboardType: keyboardType,
//       maxLines: maxLines,
//       enabled: enabled,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: icon == null ? null : Icon(icon),
//         suffixIcon: suffix,
//       ),
//     );
//   }
// }
