part of 'widgets.dart';

class CardSlideLeagueHome extends StatelessWidget {
  const CardSlideLeagueHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingCubit, SettingState>(
      builder: (context, state) {
        return Container(
          width: context.width,
          height: 85,
          color: AppColor.background,
          child: Material(
            color: Colors.transparent,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return CheepLeagueItem(
                    league: LeaguesModels(id: -1, name: 'Todas', logo: ''),
                    isSelected: state.selectedLeagueId == -1,
                    onTap: () {
                      context.read<SettingCubit>().updateSelectedLeague(-1);
                    },
                  );
                }
                final league = LeaguesApi.lLeaguesList[i - 1];
                return CheepLeagueItem(
                  league: league,
                  isSelected: state.selectedLeagueId == league.id,
                  onTap: () {
                    context.read<SettingCubit>().updateSelectedLeague(league.id);
                  },
                );
              },
              separatorBuilder: (_, i) => const Gap(12),
              itemCount: LeaguesApi.lLeaguesList.length + 1,
            ),
          ),
        );
      },
    );
  }
}

class CheepLeagueItem extends StatelessWidget {
  const CheepLeagueItem({
    super.key,
    required this.league,
    required this.isSelected,
    required this.onTap,
  });

  final LeaguesModels league;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: league.id == -1 ? 90 : 180,
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : AppColor.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColor.primary : AppColor.info,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (league.id != -1) ...[
              SizedBox(
                width: 32,
                height: 32,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: (league.logo.startsWith('http'))
                      ? Image.network(
                          getImageUrl(league.logo),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.sports_soccer, size: 24, color: Colors.grey),
                        )
                      : const Icon(Icons.sports_soccer, size: 24, color: Colors.grey),
                ),
              ),
              const Gap(10),
            ] else ...[
              Icon(
                Icons.grid_view_rounded,
                size: 20,
                color: isSelected ? Colors.white : AppColor.hint,
              ),
              const Gap(6),
            ],
            Expanded(
              child: Text(
                league.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall!.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardCalendarHome extends StatelessWidget {
  const CardCalendarHome({super.key});

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    List<DateTime> dates = List.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day - 3 + index),
    ).toList();

    return BlocBuilder<SettingCubit, SettingState>(
      builder: (context, state) {
        final selectedDate = state.selectedDate;

        return SizedBox(
          width: context.width,
          height: 60,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                const CardLiveButton(),
                const Gap(8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: dates
                        .map(
                          (model) => CardCalendarItem(
                            select: model.day == selectedDate.day &&
                                selectedDate.month == model.month,
                            date: model,
                            onTap: () {
                              context
                                  .read<SettingCubit>()
                                  .updateCalendarDate(model);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                /* if (false)
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) {
                        var model = dates[i];

                        return CardCalendarItem(
                          select: model.day == selectedDate.day &&
                              selectedDate.month == model.month,
                          date: dates[i],
                          onTap: () {
                            context
                                .read<SettingCubit>()
                                .updateCalendarDate(model);
                          },
                        );
                      },
                      separatorBuilder: (_, i) => const Gap(5),
                      itemCount: dates.length,
                    ),
                  ),*/
                IconButton(
                  onPressed: () {
                    context.read<SettingCubit>().visibleCalendar();
                  },
                  icon: SvgPicture.asset(
                    Assets.calendar,
                    height: 25,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CardLiveButton extends StatelessWidget {
  const CardLiveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(screenLive),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColor.primary,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        child: Text(
          'Live',
          style: context.textTheme.bodySmall!.copyWith(
            fontSize: 16,
            color: AppColor.primary,
          ),
        ),
      ),
    );
  }
}

class CardCalendarItem extends StatelessWidget {
  const CardCalendarItem(
      {super.key,
      required this.date,
      required this.onTap,
      required this.select});
  final bool select;
  final DateTime date;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: select ? AppColor.primary : null,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getMonthName(date),
              style: context.textTheme.bodySmall!.copyWith(
                fontSize: 11,
              ),
            ),
            Text(
              '${date.day}',
              style: context.textTheme.bodyLarge!.copyWith(
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardGroupFixtureItem extends StatelessWidget {
  const CardGroupFixtureItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Ink(
      width: context.width,
      decoration: BoxDecoration(
        color: AppColor.card,
        border: Border.all(
          color: AppColor.info,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.only(
        left: 15,
        top: 15,
        bottom: 10,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CardNoImage(radius: 10),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'World Cup 2022',
                            maxLines: 1,
                            style: context.textTheme.bodySmall,
                          ),
                        ),

                        //If Favorite
                        /* if (false) ...[
                          const Gap(10),
                          SvgPicture.asset(
                            Assets.starSolid,
                            height: 15,
                          ),
                        ]*/
                      ],
                    ),
                    Text(
                      'Group C',
                      style: context.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  context.pushNamed(screenLeague);
                },
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
              ),
            ],
          ),
          const CardFixtureItem(),
          const CardFixtureItem(),
        ],
      ),
    );
  }
}

class CardFixtureItem extends StatelessWidget {
  const CardFixtureItem({super.key, this.showDivider = true});
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider) ...[
          const Gap(5),
          const Divider(endIndent: 20),
          const Gap(5),
        ],
        InkWell(
          onTap: () {
            context.pushNamed(screenFixtureDetails);
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'FT',
                  style: context.textTheme.bodySmall,
                ),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CardNoImage(radius: 10),
                        ),
                        const Gap(10),
                        Flexible(
                          child: Text(
                            'Poland',
                            style: context.textTheme.bodySmall,
                          ),
                        ),

                        ///If Favorite
                        ...[
                          const Gap(10),
                          SvgPicture.asset(
                            Assets.starSolid,
                            height: 13,
                          ),
                        ],
                      ],
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CardNoImage(radius: 10),
                        ),
                        const Gap(10),
                        Flexible(
                          child: Text(
                            'Poland',
                            style: context.textTheme.bodySmall,
                          ),
                        ),

                        /*   //If Favorite team
                        if (false) ...[
                          const Gap(10),
                          SvgPicture.asset(
                            Assets.starSolid,
                            height: 13,
                          ),
                        ],*/
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '2',
                    style: context.textTheme.bodySmall,
                  ),
                  const Gap(10),
                  Text(
                    '0',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: LikeButton(
                  size: 20,
                  circleColor: const CircleColor(
                    start: Colors.orange,
                    end: Colors.deepOrange,
                  ),
                  bubblesColor: const BubblesColor(
                    dotPrimaryColor: Colors.orange,
                    dotSecondaryColor: Colors.deepOrange,
                  ),
                  likeBuilder: (bool isLiked) {
                    return SvgPicture.asset(
                      isLiked ? Assets.starSolid : Assets.star,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CardGoalsBarRight extends StatelessWidget {
  const CardGoalsBarRight({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(Assets.soccer),
        const Gap(5),
        Text(
          'Magalhas',
          style: context.textTheme.bodySmall!.copyWith(
            fontSize: 15,
          ),
        ),
        const Gap(5),
        Text(
          "63'",
          style: context.textTheme.bodySmall!.copyWith(
            fontSize: 15,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}

class CardGoalsBarLeft extends StatelessWidget {
  const CardGoalsBarLeft({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "63'",
          style: context.textTheme.bodySmall!.copyWith(
            fontSize: 15,
            color: Colors.white60,
          ),
        ),
        const Gap(5),
        Text(
          'Magalhas',
          style: context.textTheme.bodySmall!.copyWith(
            fontSize: 15,
          ),
        ),
        const Gap(5),
        SvgPicture.asset(Assets.soccer),
      ],
    );
  }
}

class CardBasicInfo extends StatelessWidget {
  const CardBasicInfo({super.key});

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
      child: const Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 15,
        children: [
          CardInfoTileItem(
            icon: Assets.calendarLine,
            label: '20 Nov, 15:00',
          ),
          CardInfoTileItem(
            icon: Assets.userLine,
            label: 'Michael Oliver',
          ),
          CardInfoTileItem(
            icon: Assets.mapPinLine,
            label: 'Stamford Bridge',
          ),
          CardInfoTileItem(
            icon: Assets.usersLine,
            label: '44,200',
          ),
        ],
      ),
    );
  }
}

class CardInfoTileItem extends StatelessWidget {
  const CardInfoTileItem({super.key, required this.label, required this.icon});
  final String label, icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          width: 18,
        ),
        const Gap(10),
        Text(
          label,
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class CardFixtureDetail extends StatelessWidget {
  const CardFixtureDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      constraints: BoxConstraints(
        minHeight: context.height * .3,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'Premier League',
                style: context.textTheme.headlineSmall,
              ),
              Text(
                'England',
                style: context.textTheme.bodySmall!.copyWith(
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Gap(15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const SizedBox(
                    width: 70,
                    height: 70,
                    child: CardNoImage(radius: 5),
                  ),
                  const Gap(5),
                  Text(
                    'Chelsea',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '0 : 1',
                    style: context.textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 45,
                    ),
                  ),
                  const Gap(5),
                  Text(
                    'Full Time',
                    style: context.textTheme.bodySmall!.copyWith(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const SizedBox(
                    width: 70,
                    height: 70,
                    child: CardNoImage(radius: 5),
                  ),
                  const Gap(5),
                  Text(
                    'Chelsea',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const Gap(15),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    CardGoalsBarLeft(),
                  ],
                ),
              ),
              Gap(10),
              Expanded(
                child: Column(
                  children: [
                    CardGoalsBarRight(),
                    Gap(5),
                    CardGoalsBarRight(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CardFormInfoFixture extends StatelessWidget {
  const CardFormInfoFixture({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> forms = ['L', 'L', 'L', 'W', 'L'];
    return Container(
      width: context.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColor.card,
        border: Border.all(color: AppColor.info, width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(
                  'Chelsea',
                  style: context.textTheme.bodySmall!.copyWith(
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                for (var form in forms)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: form == 'L' ? Colors.red : Colors.green,
                      child: Text(
                        form,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(15),
          SizedBox(
            width: context.width,
            height: 45,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (_, i) {
                return const CardFormMatch();
              },
              separatorBuilder: (_, i) => const Gap(10),
            ),
          ),
          const Divider(
            height: 50,
            endIndent: 15,
            indent: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(
                  'Arsenal',
                  style: context.textTheme.bodySmall!.copyWith(
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                for (var form in forms)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: form == 'L' ? Colors.red : Colors.green,
                      child: Text(
                        form,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(15),
          SizedBox(
            width: context.width,
            height: 45,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (_, i) {
                return const CardFormMatch();
              },
              separatorBuilder: (_, i) => const Gap(10),
            ),
          ),
        ],
      ),
    );
  }
}

class CardFormMatch extends StatelessWidget {
  const CardFormMatch({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.info, width: 1),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 18,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 25,
            height: 25,
            child: CardNoImage(radius: 5),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '1-0',
              style: context.textTheme.bodySmall,
            ),
          ),
          const SizedBox(
            width: 25,
            height: 25,
            child: CardNoImage(radius: 5),
          ),
        ],
      ),
    );
  }
}

class CardFixtureItemReal extends StatelessWidget {
  const CardFixtureItemReal({super.key, required this.match});
  final EventsModel match;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Redireciona para detalhes da partida
        // context.pushNamed(screenFixtureDetails);
      },
      child: Ink(
        width: context.width,
        decoration: BoxDecoration(
          color: AppColor.card,
          border: Border.all(
            color: AppColor.info,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 45,
              alignment: Alignment.center,
              child: Text(
                match.timeMatch,
                style: context.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: match.timeMatch == 'FT' ? Colors.grey : AppColor.primary,
                ),
              ),
            ),
            const Gap(15),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: match.logoHome.startsWith('http')
                            ? Image.network(
                                getImageUrl(match.logoHome),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.sports_soccer, size: 20, color: Colors.grey),
                              )
                            : const CardNoImage(radius: 4),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          match.nameHome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                      if (match.scoreHome != null)
                        Text(
                          '${match.scoreHome}',
                          style: context.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: match.logoAway.startsWith('http')
                            ? Image.network(
                                getImageUrl(match.logoAway),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.sports_soccer, size: 20, color: Colors.grey),
                              )
                            : const CardNoImage(radius: 4),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          match.nameAway,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                      if (match.scoreAway != null)
                        Text(
                          '${match.scoreAway}',
                          style: context.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
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
    );
  }
}

