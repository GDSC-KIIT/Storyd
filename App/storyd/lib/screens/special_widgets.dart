import 'package:flutter/material.dart';

class TextBubble extends StatefulWidget {
  TextBubble({this.text, this.color});

  final String text;
  final Color color;

  @override
  State<StatefulWidget> createState() {
    return _TextBubbleState();
  }
}

class _TextBubbleState extends State<TextBubble>
    with SingleTickerProviderStateMixin {
  bool active = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AnimatedContainer(
        height: 35,
        width: (16 * widget.text.length).toDouble(),
        margin: EdgeInsets.all(3),
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: active ? widget.color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        duration: Duration(milliseconds: 200),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
                fontSize: 16,
                fontFamily: "Quicksand",
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          active = !active;
        });
      },
    );
  }
}
