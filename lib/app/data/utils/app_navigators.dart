import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

void pageBack() => Navigator.of(Get.context!).pop();
void pageBackWithResult(dynamic result) =>
    Navigator.of(Get.context!).pop(result);

void pageOpen(Widget page) => Navigator.push(
      Get.context!,
      MaterialPageRoute(builder: (context) => page),
    );

Future<dynamic> pageOpenWithResult(Widget page) async {
  return await Navigator.push(
    Get.context!,
    MaterialPageRoute(builder: (context) => page),
  );
}

void pageOpenAndRemovePrevious(Widget page) => Navigator.pushAndRemoveUntil(
      Get.context!,
      MaterialPageRoute(builder: (context) => page),
      ModalRoute.withName(''),
    );

String formatDate(String format, {String? date}) =>
    DateFormat(format).format(DateTime.tryParse(date ?? "") ?? DateTime.now());

List<int> generateUniqueRandomNumbers(int count, int min, int max) {
  if (max < count) {
    return [];
  } else {
    Random random = Random();
    List<int> randomNumbers = [];

    while (randomNumbers.length < count) {
      int randomNumber = min + random.nextInt((max - 1) - min + 1);
      if (!randomNumbers.contains(randomNumber)) {
        randomNumbers.add(randomNumber);
      }
    }

    return randomNumbers;
  }
}
