import 'package:flutter/material.dart';

class TagTextBubble extends StatefulWidget {
  TagTextBubble({this.text, this.color, this.tagPool, this.parent});

  final String text;
  final Color color;
  final tagPool;
  final parent;

  @override
  State<StatefulWidget> createState() {
    return _TagTextBubbleState();
  }
}

class _TagTextBubbleState extends State<TagTextBubble>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AnimatedContainer(
        height: 30,
        width: (14 * widget.text.length).toDouble(),
        margin: EdgeInsets.all(3),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        duration: Duration(milliseconds: 200),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 14,
              fontFamily: "Quicksand",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      onTap: () {
        widget.parent.setState(() {
          widget.tagPool.remove(widget.text);
        });
      },
    );
  }
}
