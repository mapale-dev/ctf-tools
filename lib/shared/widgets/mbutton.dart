import 'package:flutter/material.dart';

class MElevatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;
  final String text;
  final Color textColor;

  const MElevatedButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconColor = const Color(0xFF2B64D1),
    required this.text,
    this.textColor = const Color(0xFF2B64D1),
  });

  @override
  MElevatedButtonState createState() => MElevatedButtonState();
}

class MElevatedButtonState extends State<MElevatedButton> {
  late String text;
  late Color textColor;
  late Color iconColor;
  late IconData icon;
  late VoidCallback? onPressed;

  @override
  void initState() {
    super.initState();
    text = widget.text;
    textColor = widget.textColor;
    iconColor = widget.iconColor;
    icon = widget.icon;
    onPressed = widget.onPressed;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF122244),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          Text(text, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }
}
