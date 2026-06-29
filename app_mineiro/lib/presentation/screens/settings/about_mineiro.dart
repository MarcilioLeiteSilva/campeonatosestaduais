part of '../screens.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        children: [
          Image.asset(
            Assets.mineiroLogo,
            width: 140,
            height: 140,
          ),
          const Gap(15),
          Center(
            child: Text(
              AppText.appName,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              'Versão 1.0.0',
              style: context.textTheme.labelSmall,
            ),
          ),
          const Gap(25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Acompanhe todas as rodadas, clubes, classificações e resultados em tempo real do Campeonato Mineiro diretamente no seu celular.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
          const Gap(30),
          const Divider(),
          ListTile(
            title: Text(
              'Privacy Policy',
              style: context.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(
              'Terms of Service',
              style: context.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(
              'Contact & Feedback',
              style: context.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
