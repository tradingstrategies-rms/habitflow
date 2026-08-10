import 'package:flutter/material.dart';

class RewardLoadingCard extends StatelessWidget {
  const RewardLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
