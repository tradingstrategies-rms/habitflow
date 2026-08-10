import 'package:flutter/material.dart';
import '../../../../shared/widgets/foundation/hf_loading_indicator.dart';

class GoalLoadingState extends StatelessWidget {
  const GoalLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HFLoadingIndicator(),
          SizedBox(height: 16),
          Text('Growing your goals...'),
        ],
      ),
    );
  }
}
