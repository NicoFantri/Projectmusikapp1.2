import 'dart:convert';
import 'dart:math';

import 'package:musicapp/app/data/model/artist.dart';
import 'package:musicapp/app/data//utils/shared_helpers.dart';

class MusicStorage {
  static String baseUrl = "https://drive.usercontent.google.com/download?id=";
  static String exportUrl = "&export=download";

  static List<Artist> listMusic = [];
  static List<String> favouriteArtist = [];
  static List<CacheArtist> cacheArtist = [];
  static List<CacheArtist> cacheAlbum = [];

  static Artist get randomMusic =>
      listMusic[Random().nextInt(listMusic.length)];

  static Artist getMusicByIndex(int indexImage) {
    int index =
        indexImage < listMusic.length ? indexImage : (indexImage - indexImage);

    return listMusic[index];
  }

  static Future<void> addFavourite(String id) async {
    favouriteArtist.add(id);
    await saveStorage();
  }

  static Future<void> removeFavourite(String id) async {
    favouriteArtist.remove(id);
    await saveStorage();
  }

  static Future<void> addArtistAbout(CacheArtist data) async {
    if (!cacheArtist.any((e) => e.id == data.id)) {
      cacheArtist.add(data);
      await saveStorage();
    }
  }

  static Future<void> addAlbumAbout(CacheArtist data) async {
    if (!cacheAlbum.any((e) => e.id == data.id)) {
      cacheAlbum.add(data);
      await saveStorage();
    }
  }

  static Future<void> saveStorage() async {
    await setSharedListString("favouriteArtist", favouriteArtist);

    await setSharedString("cacheArtist", jsonEncode(cacheArtist));

    await setSharedString("cacheAlbum", jsonEncode(cacheAlbum));
  }

  static Future<void> loadStorage() async {
    favouriteArtist = await getSharedListString("favouriteArtist");

    String? savedCacheArtist = await getSharedString("cacheArtist");
    if (savedCacheArtist != null &&
        savedCacheArtist.isNotEmpty &&
        savedCacheArtist != "[]") {
      cacheArtist = CacheArtist.fromJsonToList(jsonDecode(savedCacheArtist));
    }

    String? savedCacheAlbum = await getSharedString("cacheAlbum");
    if (savedCacheAlbum != null &&
        savedCacheAlbum.isNotEmpty &&
        savedCacheAlbum != "[]") {
      cacheAlbum = CacheArtist.fromJsonToList(jsonDecode(savedCacheAlbum));
    }
  }
}

String formatMilliseconds(int milliseconds) {
  int seconds = (milliseconds / 1000).truncate();
  int minutes = (seconds / 60).truncate();
  seconds = seconds % 60;

  String minutesStr =
      (minutes % 60).toString().padLeft(2, '0').replaceAll("0", "");
  String secondsStr = seconds.toString().padLeft(2, '0').replaceAll("0", "");

  return "$minutesStr minutes $secondsStr seconds";
}
