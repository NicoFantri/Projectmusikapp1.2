import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ConcertExplorerPage extends StatefulWidget {
  @override
  _ConcertExplorerPageState createState() => _ConcertExplorerPageState();
}

class _ConcertExplorerPageState extends State<ConcertExplorerPage> {
  String location = "Temukan lokasi Anda";

  Future<void> _getLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        location = "${position.latitude}, ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        location = "Gagal menemukan lokasi";
      });
    }
  }

  final List<Map<String, dynamic>> concerts = [
    {
      "title": "BMTH 'Church of Genxsis' Concert",
      "location": "Manahan",
      "image": "assets/images/ilustrasi.png",
      "price": "45.00 USD",
      "distance": "259 Km",
      "date": "Nov 4-6",
      "description":
      "A fictional cult they've made up as part of the storyline in this album, which explores themes of control, faith, and the dark side of human nature."
    },
    {
      "title": "Anniversary Tour 30th of Dewa 19",
      "location": "Jakarta",
      "image": "assets/images/music_player.jpg",
      "price": "50.00 USD",
      "distance": "800 Km",
      "date": "Dec 10",
      "description":
      "Celebrate the 30th anniversary of Dewa 19 with Dhani, Once, and Ari Lasso reuniting for an unforgettable performance."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              child: Text(
                location,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.location_searching, color: Colors.blue),
              onPressed: _getLocation,
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: concerts.length,
          itemBuilder: (context, index) {
            final concert = concerts[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConcertDetailPage(concert: concert),
                  ),
                );
              },
              child: Card(
                elevation: 6,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: Image.asset(
                        concert["image"],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            concert["title"],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                concert["price"],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                concert["distance"],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                concert["date"],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ConcertDetailPage extends StatelessWidget {
  final Map<String, dynamic> concert;

  const ConcertDetailPage({Key? key, required this.concert}) : super(key: key);

  Future<void> _openGoogleMaps(String location) async {
    final query = Uri.encodeComponent(location);
    final googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$query";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch Google Maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          concert["title"],
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.asset(
                concert["image"],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concert["title"],
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    concert["description"],
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        concert["location"],
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openGoogleMaps(concert["location"]),
                    icon: const Icon(Icons.map),
                    label: const Text("View Location"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
