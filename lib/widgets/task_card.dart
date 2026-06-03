import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          padding: const EdgeInsets.only(top: 2, bottom: 4),
          child: Text(
            _formatTimestamp(task.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: completed
                  ? const Color(0xFF6B7280).withOpacity(0.4)
                  : const Color(0xFF6B7280),
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: const Color(0xFFD32F2F),
          onPressed: onDelete,
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
