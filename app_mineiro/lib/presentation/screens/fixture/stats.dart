part of '../screens.dart';

class StatsFixPage extends StatelessWidget {
  const StatsFixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      children: [
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
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "1",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Shots off target",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "2",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "3",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Blocked shots",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "3",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "12",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Corner kicks",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "5",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "3",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Offsides",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "2",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "20",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Fools",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "17",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "16",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Throw-ins",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "13",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "2",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Yellow cards",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "1",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "0",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Red Cards",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "1",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "15",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Crosses",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "22",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "1",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Counter attacks",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "1",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "14",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Goal kicks",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "5",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "1",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "Treatments",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                  Text(
                    "1",
                    style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(15),
              const CardIndicatorEvent(),
              const Gap(15),
            ],
          ),
        ),
        const Gap(50),
      ],
    );
  }
}
