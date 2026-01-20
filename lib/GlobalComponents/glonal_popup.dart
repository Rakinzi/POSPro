import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalPopup extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalPopup({super.key, required this.child});

  @override
  GlobalPopupState createState() => GlobalPopupState();
}

class GlobalPopupState extends ConsumerState<GlobalPopup> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
