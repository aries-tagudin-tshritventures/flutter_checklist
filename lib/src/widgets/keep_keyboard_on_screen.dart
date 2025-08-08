import 'package:flutter/material.dart';

/// Invisible placeholder `TextField` to keep the keyboard on screen.
class KeepKeyboardOnScreen extends StatefulWidget {
  /// Invisible placeholder `TextField` with the [focusNode] to keep the keyboard on screen.
  const KeepKeyboardOnScreen({
    required this.focusNode,
    required this.keyboardType,
    required this.textInputAction,
    required this.textCapitalization,
    super.key,
  });

  /// The `FocusNode` of the placeholder `TextField`.
  final FocusNode focusNode;

  /// The `TextInputType` of the placeholder `TextField`.
  final TextInputType? keyboardType;

  /// The `TextInputAction` of the placeholder `TextField`.
  final TextInputAction? textInputAction;

  /// The `TextCapitalization` of the placeholder `TextField`.
  final TextCapitalization textCapitalization;

  @override
  State createState() => _KeepKeyboardOnScreenState();
}

class _KeepKeyboardOnScreenState extends State<KeepKeyboardOnScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0,
      child: ClipRect(
        child: TextField(
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
        ),
      ),
    );
  }
}
