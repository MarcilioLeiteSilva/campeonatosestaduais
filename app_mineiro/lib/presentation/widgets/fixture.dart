part of 'widgets.dart';

class CardSlideLeagueHome extends StatelessWidget {
  const CardSlideLeagueHome({super.key});

  String _shortenLeagueName(String name) {
    if (name.contains('Módulo 1')) return 'Módulo 1';
    if (name.contains('Módulo 2')) return 'Módulo 2';
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingCubit, SettingState>(
      builder: (context, state) {
        return Container(
          width: context.width,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          color: AppColor.background,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColor.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.info, width: 1),
            ),
            child: Row(
              children: List.generate(LeaguesApi.lLeaguesList.length, (i) {
                final league = LeaguesApi.lLeaguesList[i];
                final isSelected = state.selectedLeagueId == league.id ||
                    (state.selectedLeagueId == -1 && i == 0);
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      context.read<SettingCubit>().updateSelectedLeague(league.id);
                    },
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColor.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (league.logo.isNotEmpty) ...[
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: league.logo.startsWith('http')
                                    ? Image.network(
                                        getImageUrl(league.logo),
                                        errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer, size: 14, color: Colors.grey),
                                      )
                                    : Image.asset(league.logo),
                              ),
                            ),
                            const Gap(8),
                          ],
                          Text(
                            _shortenLeagueName(league.name),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: dates
                          .map(
                            (model) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: CardCalendarItem(
                                select: model.day == selectedDate.day &&
                                    selectedDate.month == model.month,
                                date: model,
                                onTap: () {
                                  context
                                      .read<SettingCubit>()
                                      .updateCalendarDate(model);
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
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
    return BlocBuilder<SettingCubit, SettingState>(
      builder: (context, state) {
        final isActive = state.showLiveOnly;
        return InkWell(
          onTap: () => context.read<SettingCubit>().toggleLiveOnly(),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            decoration: BoxDecoration(
              color: isActive ? Colors.red : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isActive ? Colors.red : AppColor.primary,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isActive) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(6),
                ],
                Text(
                  'Live',
                  style: context.textTheme.bodySmall!.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AppColor.primary,
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
  const CardBasicInfo({super.key, required this.match});
  final EventsModel match;

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
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 15,
        children: [
          CardInfoTileItem(
            icon: Assets.calendarLine,
            label: match.dateMatch,
          ),
          CardInfoTileItem(
            icon: Assets.watchLine,
            label: 'Hora: ${match.timeMatch}',
          ),
          CardInfoTileItem(
            icon: Assets.mapPinLine,
            label: match.venueName.isNotEmpty
                ? '${match.venueName}, ${match.venueCity}'
                : 'Minas Gerais, Brasil',
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
  const CardFixtureDetail({super.key, this.match});
  final EventsModel? match;

  @override
  Widget build(BuildContext context) {
    final actualMatch = match ?? (EventsApi.eListEvents.isNotEmpty ? EventsApi.eListEvents.first : null);

    if (actualMatch == null) {
      return const SizedBox.shrink();
    }

    final league = LeaguesApi.lLeaguesList.firstWhere(
      (l) => l.id == actualMatch.leagueExternalId,
      orElse: () => LeaguesModels(id: -1, name: 'Campeonato Mineiro', logo: ''),
    );

    final String scoreText = (actualMatch.scoreHome != null && actualMatch.scoreAway != null)
        ? '${actualMatch.scoreHome} : ${actualMatch.scoreAway}'
        : 'VS';

    return Container(
      width: context.width,
      constraints: BoxConstraints(
        minHeight: context.height * 0.25,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                league.name,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              if (actualMatch.round.isNotEmpty) ...[
                const Gap(4),
                Text(
                  actualMatch.round,
                  style: context.textTheme.bodySmall!.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              const Gap(4),
              Text(
                'Minas Gerais, Brasil',
                style: context.textTheme.bodySmall!.copyWith(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                      screenTeam,
                      extra: {
                        'name': actualMatch.nameHome,
                        'logo': actualMatch.logoHome,
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 65,
                        height: 65,
                        child: actualMatch.logoHome.startsWith('http')
                            ? Image.network(
                                getImageUrl(actualMatch.logoHome),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.sports_soccer, size: 45, color: Colors.white70),
                              )
                            : const Icon(Icons.sports_soccer, size: 45, color: Colors.white70),
                      ),
                      const Gap(8),
                      Text(
                        actualMatch.nameHome,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      scoreText,
                      style: context.textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 38,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        actualMatch.timeMatch,
                        style: context.textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                      screenTeam,
                      extra: {
                        'name': actualMatch.nameAway,
                        'logo': actualMatch.logoAway,
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 65,
                        height: 65,
                        child: actualMatch.logoAway.startsWith('http')
                            ? Image.network(
                                getImageUrl(actualMatch.logoAway),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.sports_soccer, size: 45, color: Colors.white70),
                              )
                            : const Icon(Icons.sports_soccer, size: 45, color: Colors.white70),
                      ),
                      const Gap(8),
                      Text(
                        actualMatch.nameAway,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
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
    final status = formatMatchStatus(match.timeMatch);
    final isLive = status == 'Ao Vivo';
    final isFinished = status == 'Encerrado' || status == 'Pênaltis';

    // Determinar vencedor para negrito
    bool isWinnerHome = false;
    bool isWinnerAway = false;
    if (isFinished && match.scoreHome != null && match.scoreAway != null) {
      final sh = (match.scoreHome as num).toInt();
      final sa = (match.scoreAway as num).toInt();
      isWinnerHome = sh > sa;
      isWinnerAway = sa > sh;
    }

    return InkWell(
      onTap: () {
        context.pushNamed(
          screenFixtureDetails,
          extra: match,
        );
      },
      borderRadius: BorderRadius.circular(10),
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Date and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: Colors.grey,
                    ),
                    const Gap(6),
                    Text(
                      match.dateMatch,
                      style: context.textTheme.labelSmall!.copyWith(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isLive
                        ? Colors.red.withOpacity(0.15)
                        : (isFinished
                            ? Colors.grey.withOpacity(0.1)
                            : AppColor.primary.withOpacity(0.15)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isLive
                          ? Colors.red
                          : (isFinished ? Colors.grey.withOpacity(0.4) : AppColor.primary),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    status,
                    style: context.textTheme.labelSmall!.copyWith(
                      color: isLive ? Colors.red : (isFinished ? Colors.grey : AppColor.primary),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: AppColor.info),
            ),
            // Teams and scores
            Column(
              children: [
                // Home Team Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          context.pushNamed(
                            screenTeam,
                            extra: {
                              'name': match.nameHome,
                              'logo': match.logoHome,
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: match.logoHome.startsWith('http')
                                  ? Image.network(
                                      getImageUrl(match.logoHome),
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.sports_soccer, size: 18, color: Colors.grey),
                                    )
                                  : const CardNoImage(radius: 4),
                            ),
                            const Gap(10),
                            Expanded(
                              child: Text(
                                match.nameHome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall!.copyWith(
                                  fontWeight: isWinnerHome ? FontWeight.bold : FontWeight.normal,
                                  color: isWinnerHome ? Colors.white : Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(15),
                    if (match.scoreHome != null)
                      Text(
                        '${match.scoreHome}',
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isWinnerHome ? Colors.white : Colors.white70,
                        ),
                      ),
                  ],
                ),
                const Gap(8),
                // Away Team Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          context.pushNamed(
                            screenTeam,
                            extra: {
                              'name': match.nameAway,
                              'logo': match.logoAway,
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: match.logoAway.startsWith('http')
                                  ? Image.network(
                                      getImageUrl(match.logoAway),
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.sports_soccer, size: 18, color: Colors.grey),
                                    )
                                  : const CardNoImage(radius: 4),
                            ),
                            const Gap(10),
                            Expanded(
                              child: Text(
                                match.nameAway,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall!.copyWith(
                                  fontWeight: isWinnerAway ? FontWeight.bold : FontWeight.normal,
                                  color: isWinnerAway ? Colors.white : Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(15),
                    if (match.scoreAway != null)
                      Text(
                        '${match.scoreAway}',
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isWinnerAway ? Colors.white : Colors.white70,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

