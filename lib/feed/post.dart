import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostNewsFeedPage extends StatefulWidget {
  @override
  _PostNewsFeedPageState createState() => _PostNewsFeedPageState();
}

class _PostNewsFeedPageState extends State<PostNewsFeedPage> {
  final TextEditingController _postController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _postNewsFeed() async {
    setState(() {
      _isLoading = true;
    });

    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user!.uid;
    final String username = user.displayName ?? 'Anonymous'; // Use a default name if display name is null

    String? imageUrl; // Initialize imageUrl as nullable

    // Check if there is an image selected
    if (_image != null) {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('news_feed_images').child(userId).child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => {});
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    // Add news feed post to Firestore
    await FirebaseFirestore.instance.collection('feedItems').add({
      'userId': userId,
      'username': username,
      'timestamp': FieldValue.serverTimestamp(),
      'postImageUrl': imageUrl ?? '', // Use empty string if imageUrl is null
      'postText': _postController.text,
      'likeCount': 0, // Initialize like count
      'isLiked': false,
      'isBookmarked': false,
      'comments': [], // Initialize comments array
    });

    // Clear the inputs
    _postController.clear();
    setState(() {
      _image = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post News Feed'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4267B2), Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _postController,
              maxLines: null, // Allow multiline input
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(16.0),
              ),
            ),
            SizedBox(height: 16),
            _image == null
                ? SizedBox.shrink()
                : Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.file(
                          _image!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _image = null;
                          });
                        },
                      ),
                    ],
                  ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo_library),
              label: Text('Select Image'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _postNewsFeed,
                    child: Text('Post'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
