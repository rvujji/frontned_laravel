import 'package:flutter/material.dart';

import '../../shared/responsive_layout.dart';
import '../dashboard/widgets/dashboard_shell.dart';
import 'certificate_card.dart';
import 'certificate_models.dart';
import 'certificate_service.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  final _service = CertificateService();

  bool _loading = true;

  List<CertificateModel> certificates = [];

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
      certificates = await _service.fetchCertificates();
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
      title: 'Certificates',

      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(24),

              itemCount: certificates.length,

              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveLayout.gridCount(width),

                crossAxisSpacing: 20,

                mainAxisSpacing: 20,

                mainAxisExtent: 320,
              ),

              itemBuilder: (context, index) {
                return CertificateCard(certificate: certificates[index]);
              },
            ),
    );
  }
}
