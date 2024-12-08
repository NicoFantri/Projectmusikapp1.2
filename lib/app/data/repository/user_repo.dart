import 'dart:convert';
import 'dart:developer';

import 'package:musicapp/app/data//model/chat_room.dart';
import 'package:musicapp/app/data//utils/constants.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class UserRepo {
  static Future<GenerativeModel?> generateModel(
      {GenerationConfig? generationConfig}) async {
    try {
      final model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
          generationConfig: generationConfig);

      return model;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> generateContent({String? text}) async {
    try {
      final model = await generateModel();

      if (model == null) {
        return null;
      }

      final content = [Content.text(text ?? "")];
      final response = await model.generateContent(content);

      return response.text;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> sendText(
      {String? text, List<Messages>? history}) async {
    try {
      final model = await generateModel();

      if (model == null) {
        return null;
      }

      List<Content>? listContent = history
          ?.map((e) => e.sender?.id == 0
              ? Content.text(e.content ?? "")
              : Content.model([TextPart(e.content ?? "")]))
          .toList();

      log("listContent: ${jsonEncode(listContent)}");

      final chat = model.startChat(history: listContent);
      var content = Content.text(text ?? "");
      var response = await chat.sendMessage(content);

      return response.text;
    } on GenerativeAIException catch (e) {
      print('error $e');
      return e.message;
    }
  }

  static List<String> extractDataIds(String response) {
    List<String> dataIds = [];

    RegExp regex = RegExp(r'data-id="([^"]*)"');

    Iterable<Match> matches = regex.allMatches(response);

    for (Match match in matches) {
      if (match.groupCount >= 1) {
        dataIds.add(match.group(1)!);
      }
    }

    return dataIds;
  }
}
