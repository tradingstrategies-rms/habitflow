import 'package:flutter/material.dart';

class HabitDateSelector extends StatelessWidget {
  const HabitDateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index]),
                Text('${12 + index}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
