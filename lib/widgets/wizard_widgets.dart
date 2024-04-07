import 'dart:developer';
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
  final ValueChanged<List<String>> onSelectionDone;
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
  late List<String> _items;
  final List<String> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    setState(() { _items = widget.items!; });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.instr!,
          textScaler: const TextScaler.linear(1.5),
        ),
        const SizedBox(height: 10),
        CustomSingleSelectField(
          items: _items,
          title: widget.selectorTitle!,
          onSelectionDone: (val) {
            log("val : $val\n ######## _selectedItems : $_selectedItems");
            setState(() {
              _selectedItems.add(val);
              _items.remove(val);
            });
            log("_items : $_items | _selectedItems : $_selectedItems");
            widget.onSelectionDone(_selectedItems);
          }
        ),
        DisplayList(
          _selectedItems,
          (val) { setState(() {
            _selectedItems.remove(val);
            _items.add(val);
          }); },
        )
      ],
    );
  }
}

/*
 * Displays a list of strings as a row of bordered text widgets
 * @items: the list to display
 */
class DisplayList extends StatelessWidget {
  final ValueChanged<String> onClick;
  final List<String> items;
  
  const DisplayList(this.items, this.onClick, {super.key});
  
  @override
  Widget build(BuildContext context) {
    
    return Wrap(
      children: items.map((it) =>
        InkWell(
          onTap: () { onClick(it); },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3.0),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.deepOrangeAccent, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(20.0))
            ),
            child: Text(
              it,
              textScaler: const TextScaler.linear(0.75),
            ),
          ),
        )
      ).toList(),
    );
  }
  
}

// class DisplayList extends StatefulWidget {
//  
//   @override
//   State<DisplayList> createState() => _DisplayList();
// }
//
// class _DisplayList extends State<DisplayList> {
//  
// }

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
          onChanged: (String val) { //TODO security check
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