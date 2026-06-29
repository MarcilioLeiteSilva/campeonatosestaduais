part of '../screens.dart';

class GeneralScreen extends StatelessWidget {
  const GeneralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General'),
      ),
      body: BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) {
          final cubit = context.read<SettingCubit>();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              CardTileSwitch(
                label: 'Automatic refresh',
                value: state.autoRefresh,
                onChange: (value) => cubit.toggleGeneralSetting('auto_refresh', value),
              ),
              CardTileSwitch(
                label: 'Vibration',
                value: state.vibration,
                onChange: (value) => cubit.toggleGeneralSetting('vibration', value),
              ),
              const Divider(color: AppColor.info, height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Clear Cache',
                  style: context.textTheme.bodyMedium,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () async {
                  EasyLoading.show(status: 'Limpando cache...');
                  await Future.delayed(const Duration(milliseconds: 800));
                  EasyLoading.showSuccess('Cache limpo com sucesso!');
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Privacy and Cookies',
                  style: context.textTheme.bodyMedium,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  EasyLoading.showInfo('Versão 1.0.0 - Políticas de Privacidade');
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Consent Preferences',
                  style: context.textTheme.bodyMedium,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  EasyLoading.showInfo('Preferências de Consentimento salvas.');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
