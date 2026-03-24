import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import '../models/support_model.dart';

class HotlinesScreen extends StatelessWidget {
  const HotlinesScreen({super.key});

  Future<void> _openWhatsApp(String number) async {
    final message = Uri.encodeComponent(
      'Hello! I need help with my betel leaf crop.',
    );
    final url = 'https://wa.me/$number?text=$message';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = SupportData.getContacts();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Government Hotlines',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── UI TEAM: Style main hotline button ──
            GestureDetector(
              onTap: () => _callNumber('1920'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      '1920',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            ...contacts.map(
              (contact) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...contact.phones.map(
                      (phone) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: GestureDetector(
                          onTap: () => _callNumber(
                            phone.replaceAll(' ', '').replaceAll('+', ''),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                color: AppColors.success,
                                size: 10,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Phone: $phone',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ...contact.emails.map(
                      (email) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              color: AppColors.success,
                              size: 10,
                            ),
                            const SizedBox(width: 8),
                            Text('Email: $email'),
                          ],
                        ),
                      ),
                    ),
                    if (contact.whatsappNumber != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _openWhatsApp(contact.whatsappNumber!),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              color: AppColors.success,
                              size: 10,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'WhatsApp: ',
                              style: TextStyle(color: AppColors.primary),
                            ),
                            Text(
                              contact.whatsappNumber!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (contact.websiteUrl != null) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(contact.websiteUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: AppColors.success,
                              size: 10,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Website',
                              style: TextStyle(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
