part of '../screens.dart';

class EditNotifScreen extends StatelessWidget {
  const EditNotifScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
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
                  child: Row(
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
                ),
              ),
              CardTileSwitch(
                label: 'Match Alert',
                value: state.notifMatchAlert,
                onChange: (value) => cubit.toggleNotification('notif_match_alert', value),
              ),
              CardTileSwitch(
                label: 'Featured News',
                value: state.notifFeaturedNews,
                onChange: (value) => cubit.toggleNotification('notif_featured_news', value),
              ),
              CardTileSwitch(
                label: 'Featured Video',
                value: state.notifFeaturedVideo,
                onChange: (value) => cubit.toggleNotification('notif_featured_video', value),
              ),
              CardTileSwitch(
                label: 'Streaming',
                value: state.notifStreaming,
                onChange: (value) => cubit.toggleNotification('notif_streaming', value),
              ),
              CardTileSwitch(
                label: 'Promotions',
                value: state.notifPromotions,
                onChange: (value) => cubit.toggleNotification('notif_promotions', value),
              ),
              CardTileSwitch(
                label: 'App Updates',
                value: state.notifAppUpdates,
                onChange: (value) => cubit.toggleNotification('notif_app_updates', value),
              ),
            ],
          );
        },
      ),
    );
  }
}
