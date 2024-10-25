import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewsFeedPage extends StatelessWidget {
  const NewsFeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Feed'),
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('feedItems').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot feedItem = snapshot.data!.docs[index];
              return FeedCard(feedItem: feedItem);
            },
          );
        },
      ),
    );
  }
}

class FeedCard extends StatefulWidget {
  final DocumentSnapshot feedItem;

  FeedCard({required this.feedItem});

  @override
  _FeedCardState createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  bool isLiked = false; // Local state to track like status
  bool isBookmarked = false; // Local state to track bookmark status
  int likeCount = 0; // Local state to track like count
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize like status and count from feedItem data
    isLiked = widget.feedItem['isLiked'] ?? false;
    likeCount = widget.feedItem['likeCount'] ?? 0;
    isBookmarked = widget.feedItem['isBookmarked'] ?? false;
  }

  void _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        likeCount++;
      } else {
        likeCount--;
      }
    });

    // Update like status and count in Firestore
    await FirebaseFirestore.instance.collection('feedItems').doc(widget.feedItem.id).update({
      'isLiked': isLiked,
      'likeCount': likeCount,
    });
  }

  void _toggleBookmark() async {
    setState(() {
      isBookmarked = !isBookmarked;
    });

    // Update bookmark status in Firestore
    await FirebaseFirestore.instance.collection('feedItems').doc(widget.feedItem.id).update({
      'isBookmarked': isBookmarked,
    });
  }

  void _addComment(String commentText) async {
    final User? user = FirebaseAuth.instance.currentUser;

    // Add comment with user info if authenticated, else add anonymously
    try {
      final commentData = {
        'userId': user?.uid ?? null,
        'username': user?.displayName ?? 'Anonymous',
        'commentText': commentText,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('feedItems')
          .doc(widget.feedItem.id)
          .collection('comments')
          .add(commentData);

      // Optionally, update UI or perform any additional actions after adding a comment
      _commentController.clear();
    } catch (e) {
      print('Error adding comment: $e');
      // Handle error if necessary
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                widget.feedItem['username'] ?? 'Anonymous',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                widget.feedItem['timestamp']?.toDate().toString() ?? '',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          widget.feedItem['postImageUrl'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                  child: Image.network(
                    widget.feedItem['postImageUrl'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.feedItem['postText'] ?? '',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                      color: Colors.red, // Customized heart icon color to red
                      onPressed: _toggleLike,
                    ),
                    Text(
                      '$likeCount',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.comment_sharp),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Add a Comment'),
                          content: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Type your comment here...',
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _commentController.clear();
                              },
                            ),
                            TextButton(
                              child: Text('Post'),
                              onPressed: () {
                                _addComment(_commentController.text);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                  color: Colors.blue, // Customized bookmark icon color to blue
                  onPressed: _toggleBookmark,
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          Divider(height: 0.0, thickness: 1.0),
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('feedItems')
                .doc(widget.feedItem.id)
                .collection('comments')
                .orderBy('timestamp')
                .get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.docs.map((commentDoc) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
                    child: Text('${commentDoc['username']}: ${commentDoc['commentText']}'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
