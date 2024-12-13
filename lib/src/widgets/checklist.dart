import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_checklist/checklist.dart';
import 'package:flutter_checklist/src/utils/constants.dart';
import 'package:flutter_checklist/src/widgets/item_tile.dart';
import 'package:flutter_checklist/src/widgets/new_item_button.dart';

/// Checklist widget.
class Checklist extends StatefulWidget {
  /// A checklist with a list of [lines].
  ///
  /// The [lines] correspond to an entry in the checklist, with a text and whether they are toggled.
  ///
  /// On each change in the checklist (a line is added, removed, toggled or its text is changed),
  /// the [onChanged] callback is fired with the new list of lines.
  const Checklist({
    super.key,
    required this.lines,
    this.enabled = true,
    required this.onChanged,
  });

  /// The list of entries to display in the checklist, with a text and whether they are toggled.
  final List<ChecklistLine> lines;

  /// Whether this checklist is enabled and allow editing its items.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// Called when a line in the checklist is added, removed, toggled or its text is changed with the new list of lines.
  final void Function(List<ChecklistLine>) onChanged;

  @override
  State<Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  late final List<Key> keys;
  late final List<ChecklistLine> values;

  @override
  void initState() {
    super.initState();

    keys = List.generate(widget.lines.length, (_) => UniqueKey());
    values = List.from(widget.lines);
  }

  @override
  void dispose() {
    super.dispose();

    draggedItemKeyNotifier.value = null;
    addedItemKeyNotifier.value = null;
  }

  void onReorderStart(int index) {
    final key = keys[index];

    draggedItemKeyNotifier.value = key;
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = keys.removeAt(oldIndex);
      final value = values.removeAt(oldIndex);

      keys.insert(newIndex, item);
      values.insert(newIndex, value);
    });

    widget.onChanged(values);
  }

  void onReorderEnd(int index) {
    draggedItemKeyNotifier.value = null;
  }

  void updateToggled(Key key, bool toggled) {
    final index = keys.indexWhere((k) => k == key);
    final value = (text: values[index].text, toggled: toggled);

    values[index] = value;

    widget.onChanged(values);
  }

  void updateText(Key key, String text) {
    final index = keys.indexWhere((k) => k == key);
    final value = (text: text, toggled: values[index].toggled);

    values[index] = value;

    widget.onChanged(values);
  }

  void addItem(Key key) {
    setState(() {
      final index = keys.indexWhere((k) => k == key) + 1;
      final newKey = UniqueKey();
      final value = (text: '', toggled: false);

      keys.insert(index, newKey);
      values.insert(index, value);

      addedItemKeyNotifier.value = newKey;
    });

    widget.onChanged(values);
  }

  void removeItem(Key key) {
    setState(() {
      final index = keys.indexWhere((k) => k == key);

      keys.removeAt(index);
      values.removeAt(index);
    });

    widget.onChanged(values);
  }

  @override
  Widget build(BuildContext context) {
    // Changing the duration is buggy in debug mode
    final duration = kReleaseMode ? Duration(milliseconds: 150) : null;

    return widget.enabled
        ? ListView(
            children: [
              AnimatedReorderableListView(
                items: keys,
                itemBuilder: (context, index) {
                  return ItemTile(
                    key: keys[index],
                    value: values[index],
                    onChanged: updateText,
                    onToggled: updateToggled,
                    onSubmitted: addItem,
                    onRemove: removeItem,
                  );
                },
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                onReorderStart: onReorderStart,
                onReorder: onReorder,
                onReorderEnd: onReorderEnd,
                insertDuration: duration,
                removeDuration: duration,
              ),
              NewItemButton(
                onTap: () => addItem(keys.last),
              ),
              //Spacer(),
            ],
          )
        : ListView.builder(
            itemCount: keys.length,
            itemBuilder: (context, index) {
              return ItemTile(
                key: keys[index],
                value: values[index],
                enabled: false,
              );
            },
          );
  }
}
