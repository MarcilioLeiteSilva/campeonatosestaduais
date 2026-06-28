part of 'widgets.dart';

class CardIndicatorThreeH2H extends StatelessWidget {
  const CardIndicatorThreeH2H({super.key, this.hideMid = false});
  final bool hideMid;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 15,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        if (!hideMid) ...[
          const Gap(10),
          Expanded(
            child: Container(
              height: 15,
              decoration: BoxDecoration(
                color: AppColor.info,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
        const Gap(10),
        Expanded(
          flex: 2,
          child: Container(
            height: 15,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    );
  }
}

class CardIndicatorEvent extends StatelessWidget {
  const CardIndicatorEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                height: 15,
                decoration: const BoxDecoration(
                  color: AppColor.info,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
              ),
              Container(
                height: 15,
                width: context.width * .2,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(10),
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 15,
                decoration: const BoxDecoration(
                  color: AppColor.info,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
              ),
              Container(
                height: 15,
                width: context.width * .3,
                decoration: const BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CardEventMatch extends StatelessWidget {
  const CardEventMatch({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: const Column(
        children: [
          EventCardsRight(),
          Divider(height: 25),
          EventGoalLeft(),
          Divider(height: 25),
          EventSubstituteRight(),
          Divider(height: 25),
          EventGoalRight(),
          Divider(height: 25),
          EventMatchStatus(status: 'HT'),
          Divider(height: 25),
          EventCardsLeft(isRed: true),
          Divider(height: 25),
          EventSubstituteLeft(),
        ],
      ),
    );
  }
}

///Substitute
class EventSubstituteRight extends StatelessWidget {
  const EventSubstituteRight({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                "30'",
                style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    Assets.subIn,
                    width: 18,
                  ),
                  const Gap(5),
                  Flexible(
                    child: Text(
                      "Azul, Mou",
                      maxLines: 1,
                      style:
                          context.textTheme.bodySmall!.copyWith(fontSize: 15),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    Assets.subOut,
                    width: 18,
                  ),
                  const Gap(5),
                  Flexible(
                    child: Text(
                      "L. Messi",
                      maxLines: 1,
                      style:
                          context.textTheme.bodySmall!.copyWith(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EventSubstituteLeft extends StatelessWidget {
  const EventSubstituteLeft({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                "48'",
                style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          Assets.subIn,
                          width: 18,
                        ),
                        const Gap(5),
                        Flexible(
                          child: Text(
                            "Azul, Mou",
                            maxLines: 1,
                            style: context.textTheme.bodySmall!
                                .copyWith(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          Assets.subOut,
                          width: 18,
                        ),
                        const Gap(5),
                        Flexible(
                          child: Text(
                            "L. Messi",
                            maxLines: 1,
                            style: context.textTheme.bodySmall!
                                .copyWith(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Align(
            alignment: Alignment.centerRight,
          ),
        ),
      ],
    );
  }
}

///Status Match

class EventMatchStatus extends StatelessWidget {
  const EventMatchStatus({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$status'",
          style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
        ),
        Text(
          "1 - 1",
          style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}

///Goals
class EventGoalLeft extends StatelessWidget {
  const EventGoalLeft({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                "45'",
                style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
              ),
              const Gap(10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        "L.Soccer",
                        maxLines: 1,
                        style:
                            context.textTheme.bodySmall!.copyWith(fontSize: 15),
                      ),
                    ),
                    const Gap(5),
                    SvgPicture.asset(
                      Assets.soccer,
                      width: 18,
                    ),
                  ],
                ),
              ),
              Text(
                "0 - 1",
                style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Align(
            alignment: Alignment.centerRight,
          ),
        ),
      ],
    );
  }
}

class EventGoalRight extends StatelessWidget {
  const EventGoalRight({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                "45'",
                style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
              ),
              const Gap(10),
              const Expanded(
                child: SizedBox.shrink(),
              ),
              Text(
                "1 - 1",
                style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SvgPicture.asset(
                Assets.soccer,
                width: 18,
              ),
              const Gap(5),
              Flexible(
                child: Text(
                  "Z. Soufiane",
                  maxLines: 1,
                  style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

///Cards Yellow or Red
class EventCardsLeft extends StatelessWidget {
  const EventCardsLeft({super.key, this.isRed = false});
  final bool isRed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                "27'",
                style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  "P. Aubomeya Zizi",
                  maxLines: 1,
                  style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
                ),
              ),
              SvgPicture.asset(
                Assets.yellowCard,
                width: 14,
                color: isRed ? Colors.redAccent : null,
              ),
            ],
          ),
        ),
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}

class EventCardsRight extends StatelessWidget {
  const EventCardsRight({super.key, this.isRed = false});
  final bool isRed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "27'",
            style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
          ),
        ),
        Row(
          children: [
            SvgPicture.asset(
              Assets.yellowCard,
              width: 14,
              color: isRed ? Colors.redAccent : null,
            ),
            const Gap(10),
            Text(
              "Z. Mouàd",
              maxLines: 1,
              style: context.textTheme.bodySmall!.copyWith(fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }
}

class CardEventPossession extends StatelessWidget {
  const CardEventPossession({super.key, required this.icon});
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: AppColor.cardDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColor.info,
              width: 1,
            )),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "1",
              style: context.textTheme.bodyMedium!.copyWith(fontSize: 18),
            ),
            SvgPicture.asset(icon),
            Text(
              "1",
              style: context.textTheme.bodyMedium!.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
