import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musicapp/app/data/model/artist_album.dart';
import 'package:musicapp/app/data/repository/music_repo.dart';
import 'package:musicapp/app/data/model/track.dart';

class MusicView extends StatelessWidget {
  final String imageUrl;
  final String albumName;
  final String artistName;
  final String releaseDate;
  final String? artistId;

  const MusicView({
    Key? key,
    required this.imageUrl,
    required this.albumName,
    required this.artistName,
    required this.releaseDate,
    this.artistId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildOverlayContent(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Stack(
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          _buildAppBar(context),
          const SizedBox(height: 200),
          _buildAlbumDetails(),
          _buildTopTracks(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Get.back();
            },
          ),
          const Icon(Icons.favorite_border, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildAlbumDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            albumName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artistName,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Release Date: $releaseDate',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTracks() {
    return FutureBuilder<List<Tracks>>(
      future: artistId != null
          ? MusicRepo.getMultipleTopTrack([artistId!])
          : Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading tracks: ${snapshot.error}',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_off, color: Colors.white70, size: 48),
                const SizedBox(height: 16),
                Text(
                  artistId == null
                      ? 'Artist ID not available'
                      : 'No tracks available for this artist',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                if (artistId == null)
                  const Text(
                    'Please ensure the artist ID is provided',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
              ],
            ),
          );
        }

        final tracks = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Tracks',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ...tracks.map((track) => _buildTrackItem(track)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackItem(Tracks track) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(
          track.album?.images?.isNotEmpty == true
              ? track.album!.images!.first.url ??
              'https://via.placeholder.com/60'
              : 'https://via.placeholder.com/60',
        ),
      ),
      title: Text(
        track.name ?? 'Unknown Track',
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: Text(
        track.artists?.isNotEmpty == true
            ? track.artists!
            .map((artist) => artist.name ?? 'Unknown Artist')
            .join(', ')
            : 'Unknown Artist',
        style: const TextStyle(fontSize: 14, color: Colors.white70),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
        onPressed: () {
          // Handle play button press
        },
      ),
    );
  }
}