import 'package:flutter/material.dart';

class LearningStatsSection extends StatelessWidget {
  final int enrollmentsCount;

  final int sessionsCount;

  const LearningStatsSection({
    super.key,
    required this.enrollmentsCount,
    required this.sessionsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,

      children: [
        _StatCard(label: 'Enrollments', value: enrollmentsCount.toString()),

        _StatCard(label: 'Upcoming Sessions', value: sessionsCount.toString()),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;

  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.indigo.shade50,

        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),

          const SizedBox(height: 14),

          Text(
            value,

            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
