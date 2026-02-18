import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchWhatsApp() async {
    final phone = '+593997962747';
    final url = 'https://wa.me/$phone';
    await _launchUrl(url);
  }

  Future<void> _launchTelegram() async {
    await _launchUrl('https://t.me/TST_Ecuador');
  }

  Future<void> _launchEmail() async {
    final uri = Uri(scheme: 'mailto', path: 'negocios@tstsolutions.com.ec');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de - TST Solutions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.business, size: 64, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'COBRANZA PRO',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BY TST SOLUTIONS',
                      style: TextStyle(color: Colors.grey[600], letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    const Text('Control Profesional de Deudas y Cobros', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Informacion de Contacto - TST Solutions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Quito - Ecuador'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('WhatsApp'),
                    subtitle: const Text('+593 99 796 2747'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: _launchWhatsApp,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.send),
                    title: const Text('Telegram'),
                    subtitle: const Text('@TST_Ecuador'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: _launchTelegram,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: const Text('negocios@tstsolutions.com.ec'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: _launchEmail,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Web'),
                    subtitle: const Text('https://tst-solutions.netlify.app/'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl('https://tst-solutions.netlify.app/'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.facebook),
                    title: const Text('Facebook'),
                    subtitle: const Text('tstsolutionsecuador'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl('https://www.facebook.com/tstsolutionsecuador/'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.alternate_email),
                    title: const Text('Twitter/X'),
                    subtitle: const Text('@SolutionsT95698'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl('https://x.com/SolutionsT95698'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Technology that works. Solutions that scale.',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'TST Solutions - Te Solucionamos Todo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
