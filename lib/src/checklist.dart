import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:checklist/checklist.dart';
import 'package:checklist/src/checklist_item.dart';
import 'package:checklist/src/models/checklist_line.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class Checklist extends StatefulWidget {
  const Checklist({
    super.key,
    required this.lines,
    required this.onChange,
  });

  final List<ChecklistValue> lines;

  final void Function(List<ChecklistValue> values) onChange;

  @override
  State<Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  late final List<ChecklistItem> items;
  late final List<ChecklistValue> values;

  @override
  void initState() {
    super.initState();

    final lines = widget.lines.mapIndexed((index, line) {
      return ChecklistLine(
        index: index,
        text: line.text,
        toggled: line.toggled,
      );
    }).toList();

    // Initialize the list of checklist items with the data passed by the user
    items = lines.map((checklistLine) {
      return ChecklistItem(
        key: UniqueKey(),
        checklistLine: checklistLine,
        onToggle: onToggle,
        onRemove: onRemove,
      );
    }).toList();

    // Initialize the list of checklist values with the data passed by the user
    values = items.map((checklistItem) {
      return checklistItem.checklistLine.value;
    }).toList();
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      // Remove the checklist item from its current index, update its index and add it back at its new index
      final checklistItem = items.removeAt(oldIndex);
      checklistItem.checklistLine.index = newIndex;
      items.insert(newIndex, checklistItem);

      // Remove the checklist value from its current index and add it back at its new index
      final checklistValue = values.removeAt(oldIndex);
      values.insert(newIndex, checklistValue);
    });

    widget.onChange(values);
  }

  void onToggle(ChecklistItem checklistItem, bool toggled) {
    final index = items.indexOf(checklistItem);

    // Update the toggled value of the checklist value
    values[index] = (text: checklistItem.checklistLine.text, toggled: toggled);

    widget.onChange(values);
  }

  void onAdd() {
    setState(() {
      // Add the new checklist item at the end
      final index = items.length;
      final line = ChecklistLine(index: index, text: 'Line $index', toggled: false);
      final item = ChecklistItem(
        key: UniqueKey(),
        checklistLine: line,
        onToggle: onToggle,
        onRemove: onRemove,
      );
      items.add(item);

      // Add the new checklist value at the end
      values.add((text: line.text, toggled: false));
    });
  }

  void onRemove(ChecklistItem checklistItem) {
    setState(() {
      // Remove the checklist value
      final index = items.indexOf(checklistItem);
      values.removeAt(index);

      // Remove the checklist item
      items.remove(checklistItem);

      // Update the index of all the checklist items after the removed one
      for (int index = checklistItem.checklistLine.index; index < items.length; index++) {
        items[index].checklistLine.index = items[index].checklistLine.index - 1;
      }
    });

    widget.onChange(values);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AnimatedReorderableListView(
          items: items,
          itemBuilder: (context, index) {
            return items[index];
          },
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          onReorder: onReorder,
        ),
        ListTile(
          title: Text('New entry'),
          onTap: onAdd,
        ),
        //Spacer(),
      ],
    );
  }
}
