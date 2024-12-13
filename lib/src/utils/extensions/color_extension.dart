import 'package:flutter_checklist/src/utils/constants.dart';
import 'package:flutter/material.dart';

/// Extensions on the [Color] class.
extension ColorExtension on Color {
  /// Returns this color but subdued by setting its alpha channel to 150.
  Color get subdued {
    return withAlpha(subduedAlpha);
  }
}
