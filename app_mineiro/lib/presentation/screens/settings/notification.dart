part of '../screens.dart';

class EditNotifScreen extends StatelessWidget {
  const EditNotifScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) {
          final cubit = context.read<SettingCubit>();
          final isAuthorized = state.notificationPermission == 'authorized' ||
              state.notificationPermission == 'provisional';

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            children: [
              // Permissão do Sistema
              Card(
                color: AppColor.card,
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isAuthorized ? Icons.notifications_active : Icons.notifications_off,
                            color: isAuthorized ? Colors.green : Colors.redAccent,
                            size: 32,
                          ),
                          const Gap(15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'System Notifications',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Gap(4),
                                Text(
                                  isAuthorized ? 'Authorized and active' : 'Disabled in system settings',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (!isAuthorized)
                            ElevatedButton(
                              onPressed: () => cubit.requestNotificationPermission(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.info,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Enable'),
                            ),
                        ],
                      ),
                      if (isAuthorized) ...[
                        const Divider(height: 25, color: Colors.white10),
                        const Text(
                          'Nota: Para desativar as notificações do sistema por completo, por favor acesse as Configurações do seu aparelho.',
                          style: TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Gap(10),
              Text(
                'NOTIFICAÇÕES DE PARTIDAS',
                style: context.textTheme.labelLarge?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.white10, height: 15),
              CardTileSwitch(
                label: 'Início e Fim de Jogo (Placar)',
                value: state.notifPlacar,
                onChange: (value) => cubit.toggleNotification('notif_placar', value),
              ),
              CardTileSwitch(
                label: 'Gols',
                value: state.notifGols,
                onChange: (value) => cubit.toggleNotification('notif_gols', value),
              ),
              CardTileSwitch(
                label: 'Substituições',
                value: state.notifSubstituicoes,
                onChange: (value) => cubit.toggleNotification('notif_substituicoes', value),
              ),
              CardTileSwitch(
                label: 'Cartões Vermelhos',
                value: state.notifCartoes,
                onChange: (value) => cubit.toggleNotification('notif_cartoes', value),
              ),
            ],
          );
        },
      ),
    );
  }
}
