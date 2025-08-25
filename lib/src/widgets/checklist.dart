import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_checklist/checklist.dart';
import 'package:flutter_checklist/l10n/checklist_localizations/checklist_localizations_en.g.dart';
import 'package:flutter_checklist/src/utils/constants.dart';
import 'package:flutter_checklist/src/widgets/item_tile.dart';
import 'package:flutter_checklist/src/widgets/keep_keyboard_on_screen.dart';
import 'package:flutter_checklist/src/widgets/new_item_button.dart';

/// Controller for a [Checklist] widget to perform imperative actions.
class ChecklistController {
  _ChecklistState? _state;

  /// Whether this controller is currently attached to a [Checklist].
  bool get isAttached => _state != null;

  /// Current lines of the attached checklist.
  /// Returns an unmodifiable copy. If not attached, returns an empty list.
  List<ChecklistLine> get lines =>
      List.unmodifiable(_state?.values ?? const <ChecklistLine>[]);

  void _attach(_ChecklistState state) {
    _state = state;
  }

  void _detach(_ChecklistState state) {
    if (_state == state) {
      _state = null;
    }
  }

  /// Add a new item at [index]. If null, adds at the end.
  /// Optionally set its initial [text] and [toggled] status.
  void addItem({int? index, String text = '', bool toggled = false}) {
    final state = _state;
    if (state == null) return;
    final targetIndex = index ?? state.values.length;
    state._addItemAt(targetIndex, text: text, toggled: toggled);
  }

  /// Sort the checklist by status.
  /// If [uncheckedFirst] is true, unchecked items are placed before checked ones.
  void sortByStatus({bool uncheckedFirst = true}) {
    final state = _state;
    if (state == null) return;
    state._sortByStatus(uncheckedFirst: uncheckedFirst);
  }

  /// Ensure any in-progress edits are saved and notify listeners.
  /// This will unfocus any focused input and re-emit the current lines.
  void saveUnsubmitted() {
    final state = _state;
    if (state == null) return;
    state._saveUnsubmitted();
  }
}

/// Checklist widget.
class Checklist extends StatefulWidget {
  /// A checklist with a list of [lines].
  ///
  /// The [lines] correspond to the entries in the checklist, with a text and whether they are toggled.
  ///
  /// On each change in the checklist (a line is added, removed, toggled or its text is changed),
  /// the [onChanged] callback is fired with the new list of lines.
  ///
  /// Set [enabled] to false to disable editing and toggling of the lines.
  ///
  /// Set [checkedReadOnly] to make checked lines read only.
  ///
  /// Set [autofocusFirstLine] to automatically focus the first line
  /// (useful when creating the checklist for the first time with an empty line).
  ///
  /// Override [localizations] to provide your own.
  const Checklist({
    super.key,
    required this.lines,
    this.enabled = true,
    this.checkedReadOnly = false,
    this.autofocusFirstLine = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.none,
    this.textCapitalization = TextCapitalization.none,
    required this.onChanged,
    this.localizations,
    this.controller,
  });

  /// The list of entries to display in the checklist, with a text and whether they are toggled.
  final List<ChecklistLine> lines;

  /// Whether this checklist is enabled and allow editing its items.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// Whether the checked items should be read only.
  final bool checkedReadOnly;

  /// Whether to automatically focus the first line when the checklist is created.
  final bool autofocusFirstLine;

  /// The `TextInputType` of the checklist items `TextField`.
  final TextInputType keyboardType;

  /// The `TextInputAction` of the checklist items `TextField`.
  final TextInputAction textInputAction;

  /// The `TextCapitalization` of the checklist items `TextField`.
  final TextCapitalization textCapitalization;

  /// Custom implementation of [ChecklistLocalizations] to replace the default ones or provide unavailable ones.
  ///
  /// For an example on how to implement this class, look at any generated implementation for the already supported
  /// languages: <https://github.com/maelchiotti/flutter_checklist/tree/main/lib/l10n/checklist_localizations>.
  final ChecklistLocalizations? localizations;

  /// Called when a line in the checklist is added, removed, toggled or its text is changed with the new list of lines.
  final void Function(List<ChecklistLine>) onChanged;

  /// Focus node of the placeholder `TextField` that keeps the keyboard on screen when adding a new item.
  static final keepKeyboardFocusNode =
      FocusNode(debugLabel: 'Keep keyboard on screen');

  /// Optional controller to control this checklist imperatively.
  final ChecklistController? controller;

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

    _maybeAttachController(widget.controller);
  }

  @override
  void dispose() {
    super.dispose();

    draggedItemKeyNotifier.value = null;
    addedItemKeyNotifier.value = null;

    _maybeDetachController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant Checklist oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _maybeDetachController(oldWidget.controller);
      _maybeAttachController(widget.controller);
    }
  }

  void _maybeAttachController(ChecklistController? controller) {
    controller?._attach(this);
  }

  void _maybeDetachController(ChecklistController? controller) {
    controller?._detach(this);
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

  void addItem(Key? key) {
    Checklist.keepKeyboardFocusNode.requestFocus();

    setState(() {
      final index = key != null ? keys.indexWhere((k) => k == key) + 1 : 0;
      final newKey = UniqueKey();
      final value = (text: '', toggled: false);

      keys.insert(index, newKey);
      values.insert(index, value);

      addedItemKeyNotifier.value = newKey;
    });

    widget.onChanged(values);
  }

  // Controller API: add a new item at the given index with optional initial values.
  void _addItemAt(int index, {String text = '', bool toggled = false}) {
    final clampedIndex =
        index < 0 ? 0 : (index > keys.length ? keys.length : index);

    setState(() {
      final newKey = UniqueKey();
      final value = (text: text, toggled: toggled);

      keys.insert(clampedIndex, newKey);
      values.insert(clampedIndex, value);

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

  // Controller API: sort items by toggled status, preserving relative order (stable sort).
  void _sortByStatus({bool uncheckedFirst = true}) {
    setState(() {
      final pairs = List.generate(
          keys.length, (i) => (key: keys[i], value: values[i], index: i));
      pairs.sort((a, b) {
        if (a.value.toggled == b.value.toggled) {
          // Keep original order for stability
          return a.index.compareTo(b.index);
        }
        // false < true when uncheckedFirst; reversed otherwise
        final aRank = a.value.toggled ? 1 : 0;
        final bRank = b.value.toggled ? 1 : 0;
        final delta = aRank - bRank;
        return uncheckedFirst ? delta : -delta;
      });

      keys
        ..clear()
        ..addAll(pairs.map((p) => p.key));
      values
        ..clear()
        ..addAll(pairs.map((p) => p.value));
    });

    widget.onChanged(values);
  }

  // Controller API: unfocus editors and re-emit current values.
  void _saveUnsubmitted() {
    FocusManager.instance.primaryFocus?.unfocus();
    Checklist.keepKeyboardFocusNode.unfocus();
    widget.onChanged(values);
  }

  @override
  Widget build(BuildContext context) {
    // Changing the duration is buggy in debug mode
    final duration = kReleaseMode ? Duration(milliseconds: 150) : null;

    // Use the custom user localizations, or else those for the current locale, or else those in english
    final localizations = widget.localizations ??
        ChecklistLocalizations.of(context) ??
        ChecklistLocalizationsEn();

    return widget.enabled
        ? ListView(
            children: [
              KeepKeyboardOnScreen(
                focusNode: Checklist.keepKeyboardFocusNode,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                textCapitalization: widget.textCapitalization,
              ),
              AnimatedReorderableListView(
                items: keys,
                itemBuilder: (context, index) {
                  return ItemTile(
                    key: keys[index],
                    value: values[index],
                    checkedReadOnly: widget.checkedReadOnly,
                    autofocus: widget.autofocusFirstLine && index == 0,
                    onChanged: updateText,
                    onToggled: updateToggled,
                    onSubmitted: addItem,
                    onRemove: removeItem,
                    localizations: localizations,
                  );
                },
                isSameItem: (Key key, Key otherKey) => key == otherKey,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                dragStartDelay: Duration(milliseconds: 250),
                onReorderStart: onReorderStart,
                onReorder: onReorder,
                onReorderEnd: onReorderEnd,
                insertDuration: duration,
                removeDuration: duration,
              ),
              NewItemButton(
                onTap: () => addItem(keys.lastOrNull),
                localizations: localizations,
              ),
            ],
          )
        : ListView.builder(
            itemCount: keys.length,
            itemBuilder: (context, index) {
              return ItemTile(
                key: keys[index],
                value: values[index],
                enabled: false,
                localizations: localizations,
              );
            },
          );
  }
}
