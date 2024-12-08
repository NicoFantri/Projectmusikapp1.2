import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonWidget extends StatelessWidget {
  final String label;
  final Function onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? iconData;
  final Color? iconColor;
  final bool isLoading;
  final double width;
  final double height;
  final double fontSize;
  final double? radius;

  const ButtonWidget({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.iconData,
    this.iconColor,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 50,
    this.fontSize = 18,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size(width, height),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 15)),
          side: BorderSide(
            color: borderColor ?? Colors.deepPurple,
          ),
        ),
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      ),
      onPressed: isLoading
          ? null
          : () {
              onPressed();
            },
      child: isLoading
          ? CupertinoActivityIndicator(color: textColor ?? Colors.white)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconData != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Icon(
                      iconData,
                      size: fontSize + 3,
                      color: iconColor ?? Colors.deepPurple,
                    ),
                  ),
                Text(
                  label,
                  style: GoogleFonts.mulish(
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
    );
  }
}
