import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:musicapp/app/data/model/artist.dart';
import 'package:musicapp/app/data/model/artist_album.dart';
import 'package:musicapp/app/data/model/track.dart';
import 'package:musicapp/app/data/repository/music_repo.dart';
import 'NotificationPage.dart';
import 'drawer_menu.dart';
import 'search_results_view.dart';
import 'playerview.dart';
import 'music_screen.dart';

class VoiceSearchButton extends StatefulWidget {
  final Function(String) onSearchComplete;

  const VoiceSearchButton({Key? key, required this.onSearchComplete}) : super(key: key);

  @override
  _VoiceSearchButtonState createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        _showErrorDialog(error.errorMsg);
      },
    );
    if (!available) {
      _showErrorDialog('Speech recognition not available on this device');
    }
  }

  Future<void> _listen() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _showErrorDialog('Microphone permission is required for voice search');
      return;
    }

    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              setState(() => _isListening = false);
              widget.onSearchComplete(result.recognizedWords);
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: false,
          localeId: 'en_US',
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isListening ? Icons.mic : Icons.mic_none,
        color: _isListening ? Colors.red : Colors.grey,
      ),
      onPressed: _listen,
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final TextEditingController _searchController = TextEditingController();
  String? _notificationMessage;
  List<Map<String, String>> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  void _initializeFirebaseMessaging() {
    _firebaseMessaging.getToken().then((token) {
      print("Device Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _notifications.add({
          "title": message.notification?.title ?? "Notifikasi",
          "body": message.notification?.body ?? "Isi pesan tidak tersedia",
          "time": DateTime.now().toString(),
        });
        _notificationMessage = message.notification?.body ?? 'No message body';
      });
      _showNotificationDialog(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      setState(() {
        _notificationMessage = message.notification?.body ?? 'No message body';
      });
    });
  }

  void _showNotificationDialog(RemoteMessage message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            title: Row(
              children: [
                Icon(Icons.music_note, color: Colors.blueGrey, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message.notification?.title ?? 'Notification',
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              message.notification?.body ?? 'No message body',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueGrey,
                ),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _performSearch(bool isFromVoice) {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      Get.to(() =>
          SearchResultsView(
            searchQuery: query,
            isFromVoice: isFromVoice,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      drawer: const DrawerMenu(),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _isLoading = true;
              });
              // Add your refresh logic here
              await Future.delayed(const Duration(seconds: 2));
              setState(() {
                _isLoading = false;
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(),
                  _buildSearchBar(),
                  _buildArtistSection(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: const Text(
        '',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotificationPage(notifications: _notifications),
              ),
            );
          },
          child: Stack(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.notifications,
                  color: Colors.black87,
                  size: 28,
                ),
              ),
              if (_notifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      _notifications.length > 9 ? '9+' : _notifications.length
                          .toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ],
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildGreetingSection() {
    final hour = DateTime
        .now()
        .hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'What do you want to hear today?',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for tracks',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[400],
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  ),
                VoiceSearchButton(
                  onSearchComplete: (String text) {
                    setState(() {
                      _searchController.text = text;
                    });
                    _performSearch(true);
                  },
                ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
          ),
          onSubmitted: (_) => _performSearch(false),
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }


  Widget _buildArtistSection() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        MusicRepo.getArtists(),
        MusicRepo.getArtistAlbums(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No artists or albums found'));
        }

        final artists = snapshot.data![0] as List<Artist>;
        final albums = snapshot.data![1] as List<Albums>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrendingMusicSection(albums),
            _buildTabSection(artists),
          ],
        );
      },
    );
  }

  Widget _buildTrendingMusicSection(List<Albums> albums) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Music Trending',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Show more',
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: albums.map((album) => _buildAlbumBox(album)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumBox(Albums album) {
    return GestureDetector(
      onTap: () async {
        Artist? artist = await _getArtistForAlbum(album);
        if (artist != null) {
          Get.to(() => MusicScreen(artist: artist));
        }
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                album.images?.firstOrNull?.url ??
                    'https://via.placeholder.com/150',
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album.name ?? 'Unknown Album',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              album.artists?.firstOrNull?.name ?? 'Unknown Artist',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Artist?> _getArtistForAlbum(Albums album) async {
    if (album.artists?.isNotEmpty ?? false) {
      String artistId = album.artists!.first.id!;
      List<Artist> artists = await MusicRepo.getArtists();
      return artists.firstWhereOrNull((artist) => artist.id == artistId);
    }
    return null;
  }


  Widget _buildTabSection(List<Artist> artists) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Recently'),
              Tab(text: 'Popular'),
              Tab(text: 'Similar'),
              Tab(text: 'Trending'),
            ],
            isScrollable: false,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.blueAccent,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 350,
            child: TabBarView(
              children: List.generate(4, (index) => _buildSongList(artists)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList(List<Artist> artists) {
    return FutureBuilder<List<Tracks>>(
      future: MusicRepo.getMultipleTopTrack(
          artists.map((e) => e.id!).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tracks found'));
        }

        final tracks = snapshot.data!;
        return ListView.builder(
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            return _buildSongItem(
              track.album?.images?.first.url ??
                  'https://via.placeholder.com/50',
              track.name ?? 'Unknown',
              track.artists?.map((a) => a.name).join(', ') ?? 'Unknown Artist',
              '${track.durationMs ?? 0 ~/ 60000}:${(track.durationMs ??
                  0 % 60000 ~/ 1000).toString().padLeft(2, '0')}',
              track.previewUrl,
            );
          },
        );
      },
    );
  }

  Widget _buildSongItem(String imageUrl, String title, String artist,
      String duration, String? previewUrl) {
    return GestureDetector(
      onTap: () {
        Get.to(() =>
            PlayerView(
              title: title,
              artist: artist,
              imageUrl: imageUrl,
              previewUrl: previewUrl,
            ));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              radius: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    artist,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: Colors.black54),
                Text(
                  duration,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
