import 'package:flutter/material.dart';

class DashboardTopbar extends StatelessWidget {
  const DashboardTopbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,

      padding: const EdgeInsets.symmetric(horizontal: 24),

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),

      child: Row(
        children: [
          const Text(
            'Dashboard',

            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          CircleAvatar(
            backgroundColor: Colors.indigo.shade100,

            child: const Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
