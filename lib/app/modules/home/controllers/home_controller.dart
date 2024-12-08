import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:musicapp/app/data//services/network_service.dart';

class HomeController extends GetxController {
  var trendingMusic = [].obs;

  // Fetch Spotify trending music
  Future<void> fetchTrendingMusic() async {
    try {
      Dio dio = NetworkService.initDio();
      var response = await dio.get('playlists/{playlist_id}/tracks');

      if (response.statusCode == 200) {
        trendingMusic.value = response.data['items'];
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch trending music: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchTrendingMusic(); // Fetch music when the controller is initialized
  }
}
