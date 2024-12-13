import 'package:checklist/src/extensions/color_extension.dart';
import 'package:checklist/src/models/checklist_line.dart';
import 'package:flutter/material.dart';

class ChecklistItem extends StatefulWidget {
  const ChecklistItem({
    super.key,
    required this.checklistLine,
    required this.onToggle,
    required this.onRemove,
  });

  final ChecklistLine checklistLine;

  final void Function(ChecklistItem checklistItem, bool toggled) onToggle;
  final void Function(ChecklistItem checklistItem) onRemove;

  @override
  State<ChecklistItem> createState() => _ChecklistItemState();
}

class _ChecklistItemState extends State<ChecklistItem> {
  late bool toggled;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();

    toggled = widget.checklistLine.toggled;
    textController = TextEditingController(text: widget.checklistLine.text);
  }

  void onToggle(bool? toggled) {
    if (toggled == null) {
      return;
    }

    setState(() {
      this.toggled = toggled;
    });

    widget.onToggle(widget, toggled);
  }

  @override
  Widget build(BuildContext context) {
    final bodyLarge = Theme.of(context).textTheme.bodyLarge;
    final subduedColor = bodyLarge?.color?.subdued;
    final bodyLargeLineThrough = bodyLarge?.copyWith(
      color: subduedColor,
      decoration: TextDecoration.lineThrough,
      decorationColor: subduedColor,
    );

    return Material(
      child: ListTile(
        visualDensity: VisualDensity.compact,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_indicator),
            Checkbox(
              value: toggled,
              visualDensity: VisualDensity.compact,
              onChanged: onToggle,
            ),
          ],
        ),
        title: TextField(
          controller: textController,
          readOnly: toggled,
          style: toggled ? bodyLargeLineThrough : bodyLarge,
          decoration: InputDecoration.collapsed(hintText: ''),
          maxLines: null,
        ),
        trailing: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => widget.onRemove(widget),
        ),
      ),
    );
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '${widget.checklistLine.index}';
  }
}
