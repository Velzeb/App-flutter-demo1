import 'package:flutter/material.dart';

class LongText extends StatefulWidget {
  final String text;
  final int trimLines;
  const LongText({
    super.key,
    required this.text,
    this.trimLines = 2,
  });

  @override
  State<LongText> createState() => _LongTextState();
}

class _LongTextState extends State<LongText> {
  bool _readMore = false;

  @override
  Widget build(BuildContext context) {
    final span = TextSpan(text: widget.text);
    final tp = TextPainter(
      text: span,
      maxLines: widget.trimLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width);

    final isOverflow = tp.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _readMore ? null : widget.trimLines,
          overflow: _readMore ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (isOverflow)
          InkWell(
            onTap: () => setState(() => _readMore = !_readMore),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _readMore ? 'Ver menos' : 'Ver más',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
