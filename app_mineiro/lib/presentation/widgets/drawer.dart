part of 'widgets.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.background,
      child: SafeArea(
        child: Column(
          children: [
            const Gap(20),
            // Cabeçalho de Perfil reativo
            BlocBuilder<SettingCubit, SettingState>(
              builder: (context, state) {
                final hasFavTeam = state.favoriteTeam != null && state.favoriteTeam!.isNotEmpty;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
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
                                  child: Icon(Icons.person, size: 30, color: Colors.white60),
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
                              ),
                            ),
                            const Gap(2),
                            Text(
                              hasFavTeam ? 'Torcedor do ${state.favoriteTeam}' : 'Torcedor Visitante',
                              style: context.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Gap(10),
            const Divider(height: 30, endIndent: 20, indent: 20, color: AppColor.info),
            // Itens de Navegação do App
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  DrawerMenuItem(
                    label: 'Competições',
                    iconPath: Assets.soccer,
                    color: Colors.blue.withOpacity(.15),
                    onTap: () {
                      Navigator.pop(context); // Fecha o drawer
                      context.read<SettingCubit>().updateHomeIndex(1); // Vai para Favoritos/Competições
                    },
                  ),
                  DrawerMenuItem(
                    label: 'Tabela',
                    iconData: Icons.leaderboard_outlined,
                    color: Colors.amber.withOpacity(.15),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<SettingCubit>().updateHomeIndex(4); // Tabela / Classificação
                    },
                  ),
                  DrawerMenuItem(
                    label: 'Configurações',
                    iconData: Icons.settings_outlined,
                    color: Colors.deepPurple.withOpacity(.15),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed(screenAccountSettings); // Tela de configurações à parte
                    },
                  ),
                  DrawerMenuItem(
                    label: 'Notícias',
                    iconPath: Assets.newsLine,
                    color: Colors.orange.withOpacity(.15),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<SettingCubit>().updateHomeIndex(2); // Aba de Notícias
                    },
                  ),
                  DrawerMenuItem(
                    label: 'Rodadas',
                    iconPath: Assets.calendar,
                    color: Colors.green.withOpacity(.15),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<SettingCubit>().updateHomeIndex(0); // Aba principal (Rodadas/Partidas)
                    },
                  ),
                  const Gap(15),
                  const Divider(endIndent: 10, indent: 10, color: AppColor.info),
                  const Gap(5),
                  DrawerMenuItem(
                    label: 'Sair',
                    iconPath: Assets.logout,
                    color: AppColor.logout.withOpacity(.15),
                    fullColor: AppColor.logout,
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        builder: (builder) => const SheetLogOut(),
                      );
                    },
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

class DrawerMenuItem extends StatelessWidget {
  const DrawerMenuItem({
    super.key,
    required this.label,
    this.iconPath,
    this.iconData,
    required this.color,
    this.fullColor,
    required this.onTap,
  });

  final String label;
  final String? iconPath;
  final IconData? iconData;
  final Color color;
  final Color? fullColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color,
              child: iconData != null
                  ? Icon(
                      iconData,
                      color: fullColor ?? Colors.white,
                      size: 18,
                    )
                  : SvgPicture.asset(
                      iconPath!,
                      color: fullColor ?? Colors.white,
                      height: 18,
                    ),
            ),
            const Gap(15),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: fullColor,
                ),
              ),
            ),
            if (fullColor == null)
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppColor.hint.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }
}
