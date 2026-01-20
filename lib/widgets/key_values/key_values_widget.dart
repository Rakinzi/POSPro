import 'package:flutter/material.dart';

class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.title,
    this.titleFlex = 1,
    this.titleStyle,
    this.titleMaxLines,
    this.titleOverflow,
    required this.description,
    this.descriptionFlex = 1,
    this.descriptionStyle,
    this.descriptionMaxLines,
    this.descriptionOverflow,
    this.centerSpace = 8,
    this.bottomSpace = 8,
  });

  final String title;
  final int titleFlex;
  final TextStyle? titleStyle;
  final int? titleMaxLines;
  final TextOverflow? titleOverflow;

  final String description;
  final int descriptionFlex;
  final TextStyle? descriptionStyle;
  final int? descriptionMaxLines;
  final TextOverflow? descriptionOverflow;

  final double centerSpace;
  final double bottomSpace;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _titleStyle = titleStyle ??
        _theme.textTheme.bodyMedium?.copyWith(
          color: Color(0xff4B5563),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        );

    final _descriptionStyle = descriptionStyle ??
        _titleStyle?.copyWith(
          color: Color(0xff121535),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpace),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: titleFlex,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: titleMaxLines,
                    overflow: titleOverflow,
                    style: _titleStyle,
                  ),
                ),
                Text(':', style: _titleStyle),
              ],
            ),
          ),
          SizedBox(width: centerSpace),
          Expanded(
            flex: descriptionFlex,
            child: Text(
              description,
              maxLines: descriptionMaxLines,
              overflow: descriptionOverflow,
              style: _descriptionStyle,
            ),
          )
        ],
      ),
    );
  }
}
