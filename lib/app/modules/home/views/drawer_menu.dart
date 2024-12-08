import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Import necessary page classes
import 'package:musicapp/app/modules/home/web_view/web_view.dart';
import 'package:musicapp/app/modules/home/views/music_vidio_screen.dart';
import 'package:musicapp/app/modules/home/views/konser_musik.dart';


class DrawerMenu extends StatefulWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final user = FirebaseAuth.instance.currentUser;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  static const String _imagePathKey = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? imagePath = prefs.getString(_imagePathKey);
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          setState(() {
            _imageFile = file;
          });
        }
      }
    } catch (e) {
      print('Error loading saved image: $e');
    }
  }

  Future<void> _saveImagePath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_imagePathKey, path);
    } catch (e) {
      print('Error saving image path: $e');
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 500,
      );

      if (pickedFile != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
        final String permanentPath = '${appDir.path}/$fileName';

        final File permanentFile = await File(pickedFile.path).copy(permanentPath);
        await _saveImagePath(permanentPath);

        setState(() {
          _imageFile = permanentFile;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil gambar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(child: _buildMenuItems(context)),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildProfileImage(),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'Pengguna',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'email@contoh.com',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              image: _imageFile != null
                  ? DecorationImage(
                image: FileImage(_imageFile!),
                fit: BoxFit.cover,
              )
                  : const DecorationImage(
                image: AssetImage('assets/images/avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      {'icon': Icons.newspaper, 'title': 'Berita Musik', 'page': const MusicWebView()},
      {'icon': Icons.playlist_play, 'title': 'Playlist', 'page': null},
      {'icon': Icons.favorite, 'title': 'Favorit', 'page': null},
      {
        'icon': Icons.music_video,
        'title': 'Video Musik',
        'page': TikTokStyleVideoPlayer()
      },
      {
        'icon': Icons.event,
        'title': 'Konser Musik',
        'page': ConcertExplorerPage() // Updated to new Concert Explorer Page
      },
      {'icon': Icons.settings, 'title': 'Pengaturan', 'page': null},
      {'icon': Icons.help_outline, 'title': 'Bantuan', 'page': null},
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: menuItems.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return ListTile(
          leading: Icon(item['icon'] as IconData, color: const Color(0xFF333333)),
          title: Text(
            item['title'] as String,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          onTap: item['page'] != null
              ? () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item['page'] as Widget),
          )
              : null,
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () async {
          try {
            await FirebaseAuth.instance.signOut();
            // Navigate to the login or home screen
          } catch (e) {
            print('Gagal logout: $e');
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF333333),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Keluar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}