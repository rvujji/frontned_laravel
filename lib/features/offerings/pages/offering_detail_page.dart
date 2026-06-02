import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontned_laravel/shared/utility/string_extension.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/navigation/app_shell.dart';
import '../../auth/auth_provider.dart';
import '../providers/offering_enrollment_provider.dart';
import '../providers/offering_provider.dart';
import '../widgets/delivery_mode_badge.dart';
import '../widgets/session_timeline.dart';

class OfferingDetailPage extends ConsumerStatefulWidget {
  final String slug;

  const OfferingDetailPage({super.key, required this.slug});

  @override
  ConsumerState<OfferingDetailPage> createState() => _OfferingDetailPageState();
}

class _OfferingDetailPageState extends ConsumerState<OfferingDetailPage> {
  bool _isEnrolling = false;

  Future<void> _enroll(int offeringId) async {
    print('STEP 1 - Enroll clicked');
    final user = ref.read(authProvider).valueOrNull;
    print('STEP 2 - User loaded');
    if (user == null) {
      context.go('/login?redirect=/offerings/${widget.slug}');
      return;
    }
    print('STEP 4 - User exists');
    debugPrint('========== ENROLL DEBUG ==========');
    debugPrint('User ID: ${user.id}');
    debugPrint('Email: ${user.email}');
    debugPrint('emailVerified: ${user.emailVerified}');
    debugPrint('emailVerifiedAt: ${user.emailVerifiedAt}');
    debugPrint('=================================');

    if (!user.emailVerified) {
      // throw Exception('STOP HERE');
      context.push('/verification-required');
      return;
    }

    setState(() {
      _isEnrolling = true;
    });

    try {
      await ref.read(offeringEnrollmentProvider.notifier).enroll(offeringId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Enrollment successful')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEnrolling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final offeringAsync = ref.watch(offeringDetailProvider(widget.slug));

    return AppShell(
      child: offeringAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        error: (error, stackTrace) {
          return Center(child: Text(error.toString()));
        },

        data: (offering) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),

                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(28),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      DeliveryModeBadge(mode: offering.deliveryMode),

                      const SizedBox(height: 20),

                      Text(
                        offering.title,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        offering.workshop?.title ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Wrap(
                        spacing: 16,
                        runSpacing: 16,

                        children: [
                          Chip(label: Text(offering.status.name)),

                          Chip(
                            label: Text('${offering.sessions.length} Sessions'),
                          ),

                          if (offering.certificateEnabled)
                            const Chip(label: Text('Certificate Included')),
                        ],
                      ),

                      const SizedBox(height: 28),

                      ElevatedButton(
                        onPressed: _isEnrolling
                            ? null
                            : () => _enroll(offering.id),

                        child: _isEnrolling
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Text('Enroll Now'),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),

                    border: Border.all(color: Colors.grey.shade300),
                  ),

                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,

                    children: [
                      _InfoTile(
                        label: 'Sessions',
                        value: '${offering.sessions.length}',
                      ),

                      _InfoTile(
                        label: 'Enrollment Type',
                        value: offering.enrollmentType.name.displayLabel,
                      ),

                      _InfoTile(
                        label: 'Completion Rule',
                        value: offering.completionRule.name.displayLabel,
                      ),

                      _InfoTile(
                        label: 'Selection Rule',
                        value: offering.sessionSelectionRule.name.displayLabel,
                      ),

                      _InfoTile(
                        label: 'Capacity',
                        value: '${offering.capacity ?? '-'}',
                      ),

                      _InfoTile(label: 'Timezone', value: offering.timezone),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                const Text(
                  'Session Timeline',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 24),

                SessionTimeline(sessions: offering.sessions),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
