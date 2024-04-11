import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'editjournal.dart';
import '../../../model/model.dart'; 
class JournalItem extends StatefulWidget {

  final JournalEntry journalEntry;

  const JournalItem({
    Key? key,

    required this.journalEntry, 
  }) : super(key: key);

  @override
  _JournalItemState createState() => _JournalItemState();
}

class _JournalItemState extends State<JournalItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('MMMM dd yyyy');
final DateFormat parseFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateTime createDateParsed = parseFormat.parse(widget.journalEntry.createDate);
print("PARSED DATE $createDateParsed");
    return FadeTransition(
      opacity: _animation,
      child: GestureDetector(
        onTap: () {
         
  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditJournalPage(
      initialJournalEntry: widget.journalEntry,
    ),
  ),
).then((_) {
  // Refresh the page when navigation back
  setState(() {});
});
        },
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Colors.black.withOpacity(0.2), width: 0.0),
          ),
          color: _getColorFromMood(),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(_getIconFromMood(), color: Colors.black, size: 24),
                        SizedBox(width: 8),
                        Text(
                          widget.journalEntry.title,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                Text(
                  widget.journalEntry.content,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Date: ${dateFormat.format(createDateParsed)}',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorFromMood() {
    switch (widget.journalEntry.mood.toLowerCase()) {
      case 'happy':
        return Colors.amberAccent;
      case 'sad':
        return Colors.indigoAccent;
      case 'angry':
        return Colors.redAccent;
      case 'calm':
        return Colors.greenAccent;
      case 'scared':
        return Colors.deepPurpleAccent;
      case 'tired':
        return Colors.blueGrey;
      case 'energetic':
        return Colors.orangeAccent;
      case 'shy':
        return Colors.pinkAccent;
      case 'confident':
        return Colors.tealAccent;
      default:
        return Colors.white;
    }
  }

  IconData _getIconFromMood() {
    switch (widget.journalEntry.mood.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.mood_bad;
      case 'calm':
        return Icons.sentiment_satisfied;
      case 'scared':
        return Icons.sentiment_neutral;
      case 'tired':
        return Icons.bedtime;
      case 'energetic':
        return Icons.flash_on;
      case 'shy':
        return Icons.sentiment_very_dissatisfied;
      case 'confident':
        return Icons.star;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
