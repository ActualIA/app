import 'dart:developer';
import 'package:actualia/models/news_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final List<String>? selectedItems;

  const SelectorWithInstruction(
      this.onSelectionDone, this.instr, this.items, this.selectorTitle,
      {this.selectedItems = const [], super.key});

  @override
  State<StatefulWidget> createState() => _SelectorWithInstruction();
}

class _SelectorWithInstruction extends State<SelectorWithInstruction> {
  late List<String> _items;
  late List<String> _selectedItems = [];
  late List<String> _validItems;

  @override
  Widget build(BuildContext context) {
    _items = widget.items!;
    _items.sort();
    _selectedItems = widget.selectedItems!;
    _selectedItems.sort();

    NewsSettings ns = NewsSettings.defaults();

    switch (widget.selectorTitle) {
      case 'City':
        _validItems = ns.predefinedCities;
        break;
      case 'Country':
        _validItems = ns.predefinedCountries;
        break;
      case 'Interests':
        _validItems = ns.predefinedInterests;
        break;
    }

    for (String e in widget.selectedItems!) {
      if (_validItems.contains(e)) {
        _items.remove(e);
      } else {
        print('Error : item <$e> does not exist');
        _selectedItems.remove(e);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.instr!,
          style: const TextStyle(
              fontFamily: 'EB Garamond',
              fontWeight: FontWeight.w500,
              color: Colors.black),
          textScaler: const TextScaler.linear(1.5),
        ),
        const SizedBox(height: 10),
        CustomSingleSelectField(
            items: _items,
            title: widget.selectorTitle!,
            onSelectionDone: (val) {
              setState(() {
                _selectedItems.add(val);
                _items.remove(val);
              });
              widget.onSelectionDone(_selectedItems);
            }),
        DisplayList(
          _selectedItems,
          (val) {
            setState(() {
              _selectedItems.remove(val);
              _items.add(val);
              _items.sort();
            });
          },
        )
      ],
    );
  }
}

class WizardNavigationBottomBar extends StatelessWidget {
  final bool showLeft;
  final bool showRight;
  final String rText;
  final String lText;
  final void Function()? rOnPressed;
  final void Function()? lOnPressed;

  const WizardNavigationBottomBar(
      {this.showLeft = true,
      this.showRight = true,
      this.rText = "right button",
      this.lText = "left button",
      this.rOnPressed,
      this.lOnPressed,
      super.key});

  @override
  Widget build(BuildContext context) {
    Widget right = const SizedBox();
    Widget left = const SizedBox();
    if (showRight) {
      right = WizardNavigationButton(
        text: rText,
        onPressed: rOnPressed,
      );
    }
    if (showLeft) {
      left = WizardNavigationButton(
        text: lText,
        onPressed: lOnPressed,
      );
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [left, right]);
  }
}

class WizardNavigationButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const WizardNavigationButton({this.text = "", this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: SizedBox(
        height: 60.0,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(width: 3.5, color: Colors.lightBlueAccent),
            foregroundColor: Colors.lightBlueAccent,
          ),
          child: Text(
            text,
            textScaler: const TextScaler.linear(1.75),
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'Fira Code',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/*
 * Displays a scrollable list of strings as a row of bordered text widgets with a delete option
 * @items: the list to display
 */
class DisplayList extends StatelessWidget {
  final ValueChanged<String> onClick;
  final List<String> items;

  const DisplayList(this.items, this.onClick, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 45.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3.0),
                decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.lightBlueAccent, width: 1.5),
                    borderRadius:
                        const BorderRadius.all(Radius.circular(20.0))),
                child: Row(
                  children: [
                    Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    width: 0.75,
                                    color: Colors.lightBlueAccent))),
                        padding: const EdgeInsets.fromLTRB(4.0, 1.0, 3.0, 1.0),
                        child: Center(
                            child: Text(
                          items[index],
                          style: const TextStyle(fontFamily: 'Fira Code'),
                          textScaler: const TextScaler.linear(1.0),
                        ))),
                    Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                left: BorderSide(
                          color: Colors.lightBlueAccent,
                          width: 0.75,
                        ))),
                        child: Center(
                          child: InkWell(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20.0)),
                              highlightColor: Colors.lightBlueAccent,
                              onTap: () {
                                onClick(items[index]);
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    1.0, 1.0, 3.0, 1.0),
                                child: const Icon(Icons.delete,
                                    color: Colors.lightBlueAccent),
                              )),
                        ))
                  ],
                ));
          },
        ));
  }
}
