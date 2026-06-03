import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final completed = task.isCompleted;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 8, right: 16, top: 4, bottom: 4),
        leading: Checkbox(
          value: completed,
          onChanged: (_) => onToggle(),
          activeColor: const Color(0xFF6750A4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            task.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: completed
                  ? const Color(0xFF6B7280).withOpacity(0.5)
                  : const Color(0xFF1C1B1F),
              decoration: completed ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatTimestamp(task.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: completed
                      ? const Color(0xFF6B7280).withOpacity(0.4)
                      : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              _CategoryBadge(category: task.category, completed: completed),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(createdDate).inDays;

    String dayLabel;
    if (difference == 0) {
      dayLabel = 'Today';
    } else if (difference == 1) {
      dayLabel = 'Yesterday';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      dayLabel = '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$dayLabel • $hour:$minute';
  }
}

class _CategoryBadge extends StatelessWidget {
  final TaskCategory category;
  final bool completed;

  const _CategoryBadge({required this.category, required this.completed});

  @override
  Widget build(BuildContext context) {
    final opacity = completed ? 0.4 : 1.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: category.color.withOpacity(completed ? 0.05 : 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: category.color.withOpacity(opacity),
        ),
      ),
    );
  }
}
