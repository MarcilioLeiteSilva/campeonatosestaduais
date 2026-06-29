part of '../screens.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingCubit, SettingState>(
      builder: (context, state) {
        final hasFavTeam = state.favoriteTeam != null && state.favoriteTeam!.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurações'),
            centerTitle: false,
          ),
          body: ListView(
            children: [
              const Gap(15),
              // Header de Perfil reativo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    SizedBox(
                      width: 65,
                      height: 65,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: hasFavTeam
                            ? Image.network(
                                getImageUrl(state.favoriteTeamLogo!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const CardNoImage(radius: 100),
                              )
                            : const CircleAvatar(
                                backgroundColor: AppColor.card,
                                child: Icon(Icons.person, size: 36, color: Colors.white60),
                              ),
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.userName,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            hasFavTeam ? 'Torcedor do ${state.favoriteTeam}' : 'Torcedor Visitante',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(10),
              const Divider(height: 30, endIndent: 15, indent: 15, color: AppColor.info),
              
              CardSettingItem(
                label: 'Personal Info',
                icon: Assets.accountSetting,
                color: Colors.orange.withOpacity(.2),
                onTap: () {
                  context.pushNamed(screenEditInfo);
                },
              ),
              CardSettingItem(
                label: 'Notification',
                icon: Assets.bellSetting,
                color: Colors.deepPurple.withOpacity(.2),
                onTap: () {
                  context.pushNamed(screenEditNotification);
                },
              ),
              CardSettingItem(
                label: 'General',
                icon: Assets.general,
                color: Colors.pinkAccent.withOpacity(.1),
                onTap: () {
                  context.pushNamed(screenGeneral);
                },
              ),
              CardSettingItem(
                label: 'Security',
                icon: Assets.securite,
                color: Colors.greenAccent.withOpacity(.1),
                onTap: () {
                  context.pushNamed(screenSecurity);
                },
              ),
              CardSettingItem(
                label: 'About ${AppText.appName}',
                icon: Assets.info,
                color: Colors.deepPurpleAccent.withOpacity(.1),
                onTap: () {
                  context.pushNamed(screenAbout);
                },
              ),
              if (state.userName != 'Visitante' || hasFavTeam)
                CardSettingItem(
                  label: 'Logout',
                  icon: Assets.logout,
                  color: AppColor.logout.withOpacity(.1),
                  fullColor: AppColor.logout,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (builder) => SheetLogOut(
                        onConfirm: () {
                          context.read<SettingCubit>().logoutLocal();
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
