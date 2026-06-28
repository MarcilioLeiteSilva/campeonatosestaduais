part of 'widgets.dart';

class HomeNavBottom extends StatelessWidget {
  const HomeNavBottom({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: context.width,
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: AppColor.background.withOpacity(.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HomeTabBottomNavItem(
                onTap: () {
                  context.read<SettingCubit>().updateHomeIndex(0);
                },
                selected: index == 0,
                label: 'Home',
                icon: Assets.homeLine,
                solidIcon: Assets.homeSolid,
              ),
              HomeTabBottomNavItem(
                onTap: () {
                  context.read<SettingCubit>().updateHomeIndex(1);
                },
                selected: index == 1,
                label: 'Favorites',
                icon: Assets.star,
                solidIcon: Assets.starSolid,
              ),
              HomeTabBottomNavItem(
                onTap: () {
                  context.read<SettingCubit>().updateHomeIndex(2);
                },
                selected: index == 2,
                label: 'News',
                icon: Assets.newsLine,
                solidIcon: Assets.newsSolid,
              ),
              HomeTabBottomNavItem(
                onTap: () {
                  context.read<SettingCubit>().updateHomeIndex(3);
                },
                selected: index == 3,
                label: 'Watch',
                icon: Assets.watchLine,
                solidIcon: Assets.watchSolid,
              ),
              HomeTabBottomNavItem(
                onTap: () {
                  context.read<SettingCubit>().updateHomeIndex(4);
                },
                selected: index == 4,
                label: 'Account',
                icon: Assets.accountLine,
                solidIcon: Assets.accountSolid,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTabBottomNavItem extends StatelessWidget {
  const HomeTabBottomNavItem(
      {super.key,
      required this.selected,
      required this.label,
      required this.icon,
      required this.onTap,
      required this.solidIcon});
  final bool selected;
  final String label, icon, solidIcon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SvgPicture.asset(
            selected ? solidIcon : icon,
            color: selected ? AppColor.primary : AppColor.hint,
          ),
          Text(
            label,
            style: context.textTheme.labelSmall!.copyWith(
              color: selected ? AppColor.primary : AppColor.hint,
            ),
          ),
        ],
      ),
    );
  }
}
