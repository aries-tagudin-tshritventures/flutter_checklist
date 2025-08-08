import 'package:flutter/material.dart';

/// Invisible placeholder `TextField` to keep the keyboard on screen.
class KeepKeyboardOnScreen extends StatefulWidget {
  /// Invisible placeholder `TextField` with the [focusNode] to keep the keyboard on screen.
  const KeepKeyboardOnScreen({required this.focusNode, super.key});

  /// The focus node of the placeholder `TextField`.
  final FocusNode focusNode;

  @override
  State createState() => _KeepKeyboardOnScreenState();
}

class _KeepKeyboardOnScreenState extends State<KeepKeyboardOnScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0,
      child: ClipRect(child: TextField(focusNode: widget.focusNode)),
    );
  }
}
