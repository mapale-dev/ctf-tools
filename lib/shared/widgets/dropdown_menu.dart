import 'package:flutter/material.dart';

class MDropdownMenu extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String initialValue;
  final List<String> items;


  const MDropdownMenu({super.key, this.onChanged, required this.initialValue, required this.items});

  @override
  MDropdownMenuState createState() => MDropdownMenuState();
}

class MDropdownMenuState extends State<MDropdownMenu> {
  late String selected;
  late List<String> items = [];

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
    items = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF0F17AA),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Theme(
        data: Theme.of(context).copyWith(canvasColor: const Color(0xFF0F172A)),
        child: DropdownButton<String>(
          value: selected,
          elevation: 3,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          underline: Container(), // 移除下划线
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selected = value!;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value!); // 通知父组件选择发生了变化
            }
          },
        ),
      ),
    );
  }
}