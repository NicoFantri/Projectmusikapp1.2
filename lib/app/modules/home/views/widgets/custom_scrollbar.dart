import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget scrollBar(
    {Widget? child, double? thickness, bool? thumbVisibility, Radius? radius}) {
  return MediaQuery.removePadding(
      context: Get.context!,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Scrollbar(
          thumbVisibility: thumbVisibility,
          radius: radius,
          thickness: thickness,
          child: child ?? const SizedBox()));
}
