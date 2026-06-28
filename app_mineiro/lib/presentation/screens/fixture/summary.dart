part of '../screens.dart';

class SummaryFixPage extends StatelessWidget {
  const SummaryFixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      children: [
        const Gap(20),
        const CardEventMatch(),
        const Gap(20),
        Container(
          width: context.width,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColor.card,
            border: Border.all(color: AppColor.info, width: 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "44",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Possession (%)",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "56",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CardEventPossession(icon: Assets.bara),
                  Gap(20),
                  CardEventPossession(icon: Assets.corner),
                  Gap(20),
                  CardEventPossession(icon: Assets.yellowCard),
                ],
              ),
            ],
          ),
        ),
        const Gap(50),
      ],
    );
  }
}
