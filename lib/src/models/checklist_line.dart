import 'package:checklist/checklist.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ChecklistLine extends Equatable {
  int index;
  String text;
  bool toggled;

  ChecklistLine({
    required this.index,
    required this.text,
    required this.toggled,
  });

  ChecklistLine copyWithIndex(int index) {
    return ChecklistLine(index: index, text: text, toggled: toggled);
  }

  ChecklistValue get value {
    return (text: text, toggled: toggled);
  }

  @override
  List<Object?> get props => [index, toggled];

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '$index $toggled $text';
  }
}
