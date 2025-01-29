import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Firebase auth import
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore import

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;  // FirebaseAuth instance
  String? profileImageUrl;
  List<String> userImages = [];

  @override
  void initState() {
    super.initState();
    fetchUserUploads(); // Fetch uploaded images when the page loads
  }

  // Fetch uploaded images for the logged-in user from Firestore
  Future<void> fetchUserUploads() async {
    final user = _auth.currentUser; // Get the current user (logged-in)
    if (user == null) {
      print('No user logged in');
      return;  // If no user is logged in, return
    }

    try {
      // Fetch posts from Firestore where the user_id matches the logged-in user
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')  // Your Firestore collection with posts
          .where('user_id', isEqualTo: user.uid)  // Get posts for the logged-in user
          .orderBy('timestamp', descending: true)  // Order posts by timestamp
          .get();

      if (snapshot.docs.isEmpty) {
        print('No posts found for this user');
      } else {
        print('Posts found: ${snapshot.docs.length}');
      }

      // Extract image URLs from Firestore documents and update state
      setState(() {
        userImages = snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
        print('User images: $userImages');  // Print images for debugging
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)  // Display profile image if available
                  : AssetImage('assets/default_profile.png') as ImageProvider, // Default image
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Your Uploads",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: userImages.isEmpty
                ? Center(child: Text("No uploads yet!"))  // If no uploads, show a message
                : GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,  // Display images in 3 columns
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: userImages.length,  // Total images to show
                    itemBuilder: (context, index) {
                      return Image.network(
                        userImages[index],  // Show image from Firestore URL
                        fit: BoxFit.cover,  // Make images fit well in the grid
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error); // Display an error icon if the image fails to load
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
