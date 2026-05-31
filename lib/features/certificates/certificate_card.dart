import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'certificate_models.dart';

class CertificateCard extends StatelessWidget {
  final CertificateModel certificate;

  const CertificateCard({super.key, required this.certificate});

  Future<void> _openCertificate() async {
    final uri = Uri.parse(certificate.certificateUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
            const Icon(Icons.workspace_premium, size: 48, color: Colors.amber),

            const SizedBox(height: 20),

            Text(
              certificate.offeringTitle,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            Text(certificate.learnerName),

            const SizedBox(height: 10),

            Text(certificate.issuedAt),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: certificate.downloadable ? _openCertificate : null,

                icon: const Icon(Icons.download),

                label: const Text('Download Certificate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
