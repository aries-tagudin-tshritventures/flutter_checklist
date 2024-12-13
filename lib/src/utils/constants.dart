import 'package:flutter/material.dart';

/// Notifier of the currently dragged item's key.
///
/// It is null if not item is being dragged.
final ValueNotifier<Key?> draggedItemKeyNotifier = ValueNotifier(null);

/// Notifier of the last added item's key.
///
/// It is null if not item has been added.
final ValueNotifier<Key?> addedItemKeyNotifier = ValueNotifier(null);

/// The value to apply to the alpha channel to get a subdued color.
const subduedAlpha = 150;
