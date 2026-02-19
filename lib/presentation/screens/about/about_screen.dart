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
    final url = 'https://wa.me/$phone?text=Hola%20TST%20Solutions,%20necesito%20información%20sobre%20CONTROL%20OBRA%20PRO';
    await _launchUrl(url);
  }

  Future<void> _launchTelegram() async {
    await _launchUrl('https://t.me/TST_Ecuador');
  }

  Future<void> _launchEmail() async {
    final uri = Uri(scheme: 'mailto', path: 'negocios@tstsolutions.com.ec', query: 'subject=Información%20CONTROL%20OBRA%20PRO');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('CONTROL OBRA PRO'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.construction,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'CONTROL OBRA PRO',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BY TST SOLUTIONS',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gestión Profesional de Obras y Construcciones',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Versión 1.0.0',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Contáctanos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ContactCard(
              icon: Icons.language,
              title: 'Web',
              subtitle: 'https://tst-solutions.netlify.app/',
              onTap: () => _launchUrl('https://tst-solutions.netlify.app/'),
              iconColor: Colors.blue,
            ),
            _ContactCard(
              icon: Icons.facebook,
              title: 'Facebook',
              subtitle: 'TST Solutions Ecuador',
              onTap: () => _launchUrl('https://www.facebook.com/tstsolutionsecuador/'),
              iconColor: Colors.blue[700]!,
            ),
            _ContactCard(
              icon: Icons.alternate_email,
              title: 'Twitter/X',
              subtitle: '@SolutionsT95698',
              onTap: () => _launchUrl('https://x.com/SolutionsT95698'),
              iconColor: Colors.black87,
            ),
            _ContactCard(
              icon: Icons.phone,
              title: 'WhatsApp',
              subtitle: '+593 99 796 2747',
              onTap: _launchWhatsApp,
              iconColor: Colors.green,
            ),
            _ContactCard(
              icon: Icons.send,
              title: 'Telegram',
              subtitle: '@TST_Ecuador',
              onTap: _launchTelegram,
              iconColor: Colors.lightBlue,
            ),
            _ContactCard(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'negocios@tstsolutions.com.ec',
              onTap: _launchEmail,
              iconColor: Colors.red[400]!,
            ),
            _ContactCard(
              icon: Icons.location_on,
              title: 'Ubicación',
              subtitle: 'Quito - Ecuador',
              onTap: null,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              '"Technology that works. Solutions that scale."',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'TST SOLUTIONS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Te Solucionamos Todo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color iconColor;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: onTap != null
            ? Icon(Icons.open_in_new, color: Theme.of(context).primaryColor)
            : null,
        onTap: onTap,
      ),
    );
  }
}
