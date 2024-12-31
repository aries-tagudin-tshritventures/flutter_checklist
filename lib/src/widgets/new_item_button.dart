import 'package:flutter/material.dart';
import 'package:flutter_checklist/l10n/checklist_localizations/checklist_localizations.g.dart';

/// New item button.
class NewItemButton extends StatelessWidget {
  /// A button to add a new item to the checklist.
  const NewItemButton({
    super.key,
    required this.onTap,
  });

  /// Called when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.add),
      title: Padding(
        padding: EdgeInsets.only(left: 8),
        child: Text(
          ChecklistLocalizations.of(context).new_entry,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: onTap,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.only(left: 24, right: 16),
    );
  }
}
