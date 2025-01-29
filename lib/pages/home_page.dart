// filepath: /c:/Users/OOTSO/snapbin/lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:orkut/pages/feed_page.dart';
import 'package:orkut/pages/profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this line
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:orkut/services/supabase_service.dart';
import 'package:supabase/supabase.dart' hide User;
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart';
class Home_Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _homePageState();
  }
}

class _homePageState extends State<Home_Page> {
  int _currentPage = 0;
  bool _isUploading = false;
  final SupabaseService _supabaseService = GetIt.instance.get<SupabaseService>();
  final List<Widget> _pages = [
    FeedPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    // Listen for authentication state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final session = data.session;
    final user = session?.user;
    print("Auth state changed: $user");
      // You can update the UI based on auth changes, like checking for a logged-in user.
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SnapBin",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (_isUploading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          if (!_isUploading)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: _postImage,
                child: Icon(Icons.add_a_photo),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'login');
              },
              child: Icon(Icons.logout),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(),
      body: _pages[_currentPage],
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentPage,
      onTap: (_index) {
        setState(() {
          _currentPage = _index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          label: 'Feed',
          icon: Icon(Icons.feed),
        ),
        BottomNavigationBarItem(
          label: 'Home',
          icon: Icon(Icons.home),
        ),
      ],
    );
  }

Future<void> _postImage() async {
  try {
    // Get the current user from Firebase Auth
    final User? user = FirebaseAuth.instance.currentUser;

    print("User: $user"); // Debug: print user information

    // If the user is null, navigate to the login page
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not logged in. Please login first.')),
      );
      Navigator.pushNamed(context, 'login');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
      return;
    }

    // Read image bytes
    final Uint8List imageBytes = await image.readAsBytes();

    // Create unique filename
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';

    // Upload to Supabase (this part remains unchanged)
    final String? imageUrl = await _supabaseService.uploadImage(
      imageBytes,
      fileName,
    );

    if (imageUrl == null) {
      throw Exception('Failed to upload image');
    }

    // Store in Firestore
    await FirebaseFirestore.instance.collection('posts').add({
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'fileName': fileName,
      'user_id': user.uid, // Use user.uid from Firebase Auth
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image uploaded successfully!')),
    );

    // Refresh the feed
    setState(() {
      _currentPage = 0;
    });

  } catch (e) {
    print('Error in _postImage: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: ${e.toString()}')),
    );
  } finally {
    setState(() {
      _isUploading = false;
    });
  }
}

}