import 'package:flutter/material.dart';

import '../../shared/responsive_layout.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'schedule_models.dart';
import 'schedule_service.dart';
import 'schedule_session_card.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final _service = ScheduleService();

  bool _loading = true;

  List<ScheduledSession> sessions = [];

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      sessions = await _service.fetchSchedule();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return DashboardShell(
      title: 'My Schedule',

      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(24),

              itemCount: sessions.length,

              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveLayout.gridCount(width),

                crossAxisSpacing: 20,

                mainAxisSpacing: 20,

                mainAxisExtent: 320,
              ),

              itemBuilder: (context, index) {
                return ScheduleSessionCard(session: sessions[index]);
              },
            ),
    );
  }
}
