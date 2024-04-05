//sjhuld create and use models for signup as well

class Post {
  final String id;
  final String caption;
  final String imageUrl;
  final String topicId;

  Post({
    required this.id,
    required this.caption,
    required this.imageUrl,
    required this.topicId,
  });
}

class Topic {
  final String id;
  final String name;
  final String description;
   final String icon;
  Topic({
    required this.id, 
    required this.name,
    required this.description,
      required this.icon,
  });
}