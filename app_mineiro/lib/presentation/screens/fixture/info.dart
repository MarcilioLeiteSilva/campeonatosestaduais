part of '../screens.dart';

class InfoFixPage extends StatelessWidget {
  const InfoFixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      children: [
        const CardBasicInfo(),
        const Gap(15),
        Text(
          'Form',
          style: context.textTheme.headlineSmall!.copyWith(
            fontSize: 18,
          ),
        ),
        const Gap(15),
        const CardFormInfoFixture(),
      ],
    );
  }
}
