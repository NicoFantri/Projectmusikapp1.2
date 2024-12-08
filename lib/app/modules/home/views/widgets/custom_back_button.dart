import 'package:musicapp/app/data/utils/app_navigators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomBackButton extends StatelessWidget {
  final bool? isEnable;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? pageCustom;

  const CustomBackButton({
    super.key,
    this.isEnable = true,
    this.color,
    this.padding,
    this.pageCustom,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: color,
          ),
          onPressed: isEnable!
              ? pageCustom ??
                  () {
                    HapticFeedback.lightImpact();
                    pageBack();
                  }
              : null),
    );
  }
}
