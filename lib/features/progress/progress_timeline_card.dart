import 'package:flutter/material.dart';

class ProgressTimelineCard extends StatelessWidget {
  final int attended;

  final int required;

  final int total;

  const ProgressTimelineCard({
    super.key,
    required this.attended,
    required this.required,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),

        side: BorderSide(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Learning Progress',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            _buildRow(label: 'Sessions Attended', value: '$attended / $total'),

            _buildRow(label: 'Required Sessions', value: '$required'),

            _buildRow(
              label: 'Remaining Sessions',

              value: '${required - attended}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(label),

          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
