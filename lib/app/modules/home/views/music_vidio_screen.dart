import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TikTokStyleVideoPlayer extends StatefulWidget {
  @override
  _TikTokStyleVideoPlayerState createState() => _TikTokStyleVideoPlayerState();
}

class _TikTokStyleVideoPlayerState extends State<TikTokStyleVideoPlayer> {
  final List<Map<String, dynamic>> _videos = [];
  late PageController _pageController;
  VideoPlayerController? _currentController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadVideos();
  }

  @override
  void dispose() {
    _currentController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVideos = prefs.getString('videos');
    if (savedVideos != null) {
      final List<dynamic> videoList = jsonDecode(savedVideos);
      setState(() {
        _videos.addAll(videoList.map((e) => Map<String, dynamic>.from(e)));
      });
      if (_videos.isNotEmpty) {
        _initializeAndPlay(0);
      }
    }
  }

  Future<void> _saveVideos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('videos', jsonEncode(_videos));
  }

  Future<void> _initializeAndPlay(int index) async {
    if (_currentController != null) {
      await _currentController!.pause();
      _currentController!.dispose();
    }

    setState(() {
      _currentIndex = index;
    });

    _currentController = VideoPlayerController.file(File(_videos[index]['path']))
      ..initialize().then((_) {
        setState(() {});
        _currentController!.play();
      });
  }

  Future<void> _pickVideo({required ImageSource source}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: source);
    if (pickedFile != null) {
      final controller = TextEditingController();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Add Video Title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter video title"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _videos.add({
                    'path': pickedFile.path,
                    'title': controller.text.isEmpty ? "Untitled" : controller.text,
                  });
                });
                _saveVideos();
                Navigator.pop(context);
                if (_videos.length == 1) {
                  _initializeAndPlay(0);
                }
              },
              child: Text("Add"),
            ),
          ],
        ),
      );
    }
  }

  void _deleteVideo(int index) {
    setState(() {
      _videos.removeAt(index);
    });
    _saveVideos();
    if (_videos.isNotEmpty) {
      _initializeAndPlay(_currentIndex > 0 ? _currentIndex - 1 : 0);
    } else {
      _currentController?.dispose();
      _currentController = null;
    }
  }

  void _onPageChanged(int index) {
    _initializeAndPlay(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Video Music", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.video_library),
            onPressed: () => _pickVideo(source: ImageSource.gallery),
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () => _pickVideo(source: ImageSource.camera),
          ),
        ],
      ),
      body: _videos.isEmpty
          ? Center(
        child: Text(
          'No videos added. Use the buttons above to add videos.',
          style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )
          : PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return Stack(
            children: [
              Center(
                child: _currentIndex == index && _currentController?.value.isInitialized == true
                    ? AspectRatio(
                  aspectRatio: _currentController!.value.aspectRatio,
                  child: VideoPlayer(_currentController!),
                )
                    : CircularProgressIndicator(),
              ),
              Positioned(
                bottom: 80,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      video['title'],
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteVideo(index),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up_alt_outlined,
                          color: Colors.white),
                      onPressed: () {
                        // Like logic
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.comment_outlined,
                          color: Colors.white),
                      onPressed: () {
                        // Comment logic
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.share_outlined,
                          color: Colors.white),
                      onPressed: () {
                        // Share logic
                      },
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
