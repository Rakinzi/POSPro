import 'package:flutter/material.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class ReturnedTagWidget extends StatelessWidget {
  const ReturnedTagWidget({super.key, required this.show});

  final bool show;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: show,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.all(
              Radius.circular(2),
            ),
          ),
          child: Text(
            lang.S.of(context).returned,
            style: const TextStyle(color: Colors.orange),
          ),
        ),
      ),
    );
  }
}
