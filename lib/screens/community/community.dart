import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Topics.dart';
import '../../model/model.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late Future<List<Topic>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = fetchTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community'),
      ),
      body: FutureBuilder<List<Topic>>(
        future: _topicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          List<Topic> topics = snapshot.data ?? [];
          if (topics.isEmpty) {
            return Center(child: Text('No topics available'));
          }
      return ListView.builder(
  itemCount: topics.length,
  itemBuilder: (context, index) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; 

    final imageSize = isTablet ? 50.0 : 25.0; 
    final fontSizeName = isTablet ? 20.0 : 16.0; 
    final fontSizeDescription = isTablet ? 16.0 : 12.0;
    final iconSize = isTablet ? 30.0 : 20.0; 
      final spaceWidth = isTablet ? 20.0 : 0.0; 
       final containerHeight = isTablet ? screenHeight / 6 : screenHeight /6 ;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TopicPostsPage(topic: topics[index]),
          ),
        );
      },
      child: Container(
        height: containerHeight ,
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
      
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 20.0, spaceWidth, 20.0),
              child: CircleAvatar(
                radius: imageSize,
                backgroundImage: NetworkImage(topics[index].icon),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    topics[index].name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSizeName),
                  ),
                  SizedBox(height: 5),
        
                  Text(
                    topics[index].description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: fontSizeDescription),
                  ),
                ],
              ),
            ),
   
            Padding(
              padding: EdgeInsets.all(20.0), 
              child: Icon(Icons.arrow_forward_ios, size: iconSize),
            ),
          ],
        ),
      ),
    );
  },
);
        },
      ),
    );
  }
}

Future<List<Topic>> fetchTopics() async {
  List<Topic> topics = [];
  QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('topics').get();

  snapshot.docs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data();
    topics.add(Topic(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      icon: data['icon'], 
    ));
  });

  return topics;
}
