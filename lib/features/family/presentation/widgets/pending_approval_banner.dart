import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/parent_approval_provider.dart';

class PendingApprovalBanner extends ConsumerWidget {
  const PendingApprovalBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We pass empty string as dummy parentId since we currently fetch all family approvals
    final approvalsAsync = ref.watch(pendingApprovalsProvider(''));

    return approvalsAsync.when(
      data: (approvals) {
        if (approvals.isEmpty) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.amber.withAlpha(40),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withAlpha(80)),
          ),
          child: Row(
            children: [
              const Icon(Icons.pending_actions_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You have ${approvals.length} habit completion${approvals.length > 1 ? 's' : ''} waiting for parent approval.',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
