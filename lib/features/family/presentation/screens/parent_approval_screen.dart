import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/family/presentation/providers/parent_approval_provider.dart';
import 'package:habitflow/features/family/presentation/widgets/approval_card.dart';

class ParentApprovalScreen extends ConsumerWidget {
  const ParentApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvalsAsync = ref.watch(allPendingApprovalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Approvals')),
      body: approvalsAsync.when(
        data: (approvals) {
          if (approvals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all_rounded, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  const Text('All caught up! No pending approvals.'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: approvals.length,
            itemBuilder: (context, index) {
              final approval = approvals[index];
              return ApprovalCard(
                approval: approval,
                onApprove: () => ref.read(approvalNotifierProvider.notifier).approve(approval),
                onReject: () => ref.read(approvalNotifierProvider.notifier).reject(approval),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
