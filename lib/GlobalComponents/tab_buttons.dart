import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TabButton extends StatelessWidget {
  const TabButton({
    required this.title,
    required this.text,
    required this.background,
    required this.press,
    super.key,
  });
  final Color background;
  final Color text;
  final String title;

  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      width: 100.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: background,
      ),
      child: Center(
        child: TextButton(
          onPressed: press,
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: text,
                ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class TabButtonSmall extends StatelessWidget {
  const TabButtonSmall({
    required this.title,
    required this.text,
    required this.background,
    required this.press,
    super.key,
  });
  final Color background;
  final Color text;
  final String title;

  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40.0,
      width: 90.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: background,
      ),
      child: Center(
        child: TextButton(
          onPressed: press,
          child: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: text,
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class TabButtonBig extends StatelessWidget {
  const TabButtonBig({
    required this.title,
    required this.text,
    required this.background,
    required this.press,
    super.key,
  });
  final Color background;
  final Color text;
  final String title;

  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: background,
      ),
      child: Center(
        child: TextButton(
          onPressed: press,
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: text,
            ),
          ),
        ),
      ),
    );
  }
}
