import 'package:flutter/material.dart';

class ImageSelectionPage extends StatelessWidget {
  final List<String> imageNames; 
  final Function(String) onImageSelected;

  ImageSelectionPage({required this.imageNames, required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Profile Picture'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: imageNames.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onImageSelected(imageNames[index]),
            child: Container(
              width: 20, 
              height: 20, 
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 237, 232, 255), 
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/${imageNames[index]}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
