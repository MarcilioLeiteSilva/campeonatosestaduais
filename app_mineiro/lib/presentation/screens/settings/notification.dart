part of '../screens.dart';

class EditNotifScreen extends StatelessWidget {
  const EditNotifScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        children: [
          CardTileSwitch(
            label: 'Match Alert',
            value: true,
            onChange: (value) {},
          ),
          CardTileSwitch(
            label: 'Featured News',
            value: false,
            onChange: (value) {},
          ),
          CardTileSwitch(
            label: 'Featured Video',
            value: true,
            onChange: (value) {},
          ),
          CardTileSwitch(
            label: 'Streaming',
            value: false,
            onChange: (value) {},
          ),
          CardTileSwitch(
            label: 'Promotions',
            value: true,
            onChange: (value) {},
          ),
          CardTileSwitch(
            label: 'App Updates',
            value: true,
            onChange: (value) {},
          ),
        ],
      ),
    );
  }
}
