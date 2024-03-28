import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_custom_selector/widget/flutter_single_select.dart';

/*
 * Create a selector from a given a list with instructions displayed above
 * @onSelectionDone: the callBack to execute when the user select a choice
 * @instr: the instructions to display
 * @items: the list of possible choice
 * @selectorTitle: the label to display when no choice is made
 */
class SelectorWithInstruction extends StatefulWidget {
  final ValueChanged<String> onSelectionDone;
  final String? instr;
  final List<String>? items;
  final String? selectorTitle;

  const SelectorWithInstruction(
      this.onSelectionDone,
      this.instr,
      this.items,
      this.selectorTitle,
      {super.key}
      );

  @override
  State<StatefulWidget> createState() => _SelectorWithInstruction();
}

class _SelectorWithInstruction extends State<SelectorWithInstruction> {
  String? _res;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.instr!,
          textScaler: const TextScaler.linear(1.5),
        ),
        const SizedBox(height: 10),
        CustomSingleSelectField(
            items: widget.items!,
            title: widget.selectorTitle!,
            onSelectionDone: (val) {
              setState(() {
                _res = val;
              });
              widget.onSelectionDone(_res!);
            }
        )
      ],
    );
  }
}

/*
 * Create a text field where user can input some value, and provide instruction on what the user
 * is expected to input above the text field
 * @onChanged: the callback to execute when the input is modified
 * @instr: the instructions to display above the text field widget
 * @title: the label to display on the text field when empty
 */
class TextFormFieldWithInstruction extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? instr;
  final String? title;

  const TextFormFieldWithInstruction(this.onChanged, this.instr, this.title, {super.key});

  @override
  State<TextFormFieldWithInstruction> createState() => _TextFormFieldWithInstructionState();
}

class _TextFormFieldWithInstructionState extends State<TextFormFieldWithInstruction> {
  String? _res;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.instr!,
          textScaler: const TextScaler.linear(1.5),
        ),
        const SizedBox(height: 10.0),
        TextFormField(
          decoration: InputDecoration(
            labelText: widget.title!,
          ),
          onChanged: (String val) {
            setState(() {
              _res = val;
            });
            widget.onChanged(_res!);
          },
          maxLength: 100,
        )
      ],
    );
  }
}