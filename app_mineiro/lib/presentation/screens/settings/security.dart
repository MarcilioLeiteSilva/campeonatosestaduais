part of '../screens.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
      ),
      body: BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) {
          final cubit = context.read<SettingCubit>();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              CardTileSwitch(
                label: 'Remember me',
                value: state.rememberMe,
                onChange: (value) => cubit.toggleSecuritySetting('remember_me', value),
              ),
              CardTileSwitch(
                label: 'Biometric ID',
                value: state.biometricId,
                onChange: (value) => cubit.toggleSecuritySetting('biometric_id', value),
              ),
              CardTileSwitch(
                label: 'Face ID',
                value: state.faceId,
                onChange: (value) => cubit.toggleSecuritySetting('face_id', value),
              ),
              const Divider(color: AppColor.info, height: 20),
              ListTile(
                title: Text(
                  'Two-Factor Authentication',
                  style: context.textTheme.bodyMedium,
                ),
                contentPadding: EdgeInsets.zero,
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  EasyLoading.showInfo('Autenticação de Dois Fatores disponível em breve.');
                },
              ),
              const Gap(20),
              CardLogin(
                label: 'Change Password',
                onTap: () {
                  EasyLoading.showInfo('Função disponível apenas para usuários autenticados.');
                },
                color: AppColor.info,
              ),
            ],
          );
        },
      ),
    );
  }
}
