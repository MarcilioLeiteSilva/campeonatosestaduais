part of '../screens.dart';

class EditInfoScreen extends StatefulWidget {
  const EditInfoScreen({super.key});

  @override
  State<EditInfoScreen> createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  late TextEditingController _nameController;
  String? _selectedTeam;
  final Map<String, String> _teamLogos = {};
  List<String> _teamNames = [];

  @override
  void initState() {
    super.initState();
    // Coletar todos os times e logos dinamicamente dos jogos do Pocketbase
    for (final e in EventsApi.eListEvents) {
      if (e.nameHome.isNotEmpty) {
        _teamLogos[e.nameHome] = e.logoHome;
      }
      if (e.nameAway.isNotEmpty) {
        _teamLogos[e.nameAway] = e.logoAway;
      }
    }
    _teamNames = _teamLogos.keys.toList()..sort();

    final settingCubit = context.read<SettingCubit>();
    _nameController = TextEditingController(text: settingCubit.state.userName);
    final currentFav = settingCubit.state.favoriteTeam;
    if (currentFav != null && currentFav.isNotEmpty && _teamNames.contains(currentFav)) {
      _selectedTeam = currentFav;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColor.card,
                    backgroundImage: _selectedTeam != null && _teamLogos[_selectedTeam] != null
                        ? NetworkImage(getImageUrl(_teamLogos[_selectedTeam]!))
                        : const NetworkImage(AppText.avatar),
                  ),
                ],
              ),
            ),
            const Gap(25),
            CardInput(
              hint: 'Nome do Usuário',
              controller: _nameController,
            ),
            const Gap(25),
            const Text(
              'Escolha seu Time Favorito',
              style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.info),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTeam,
                  hint: const Text('Nenhum selecionado', style: TextStyle(color: Colors.white60)),
                  dropdownColor: AppColor.card,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Nenhum selecionado', style: TextStyle(color: Colors.white70)),
                    ),
                    ..._teamNames.map((name) => DropdownMenuItem<String>(
                          value: name,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Image.network(
                                  getImageUrl(_teamLogos[name]!),
                                  errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer, size: 18),
                                ),
                              ),
                              const Gap(10),
                              Text(name, style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedTeam = (val == '') ? null : val;
                    });
                  },
                ),
              ),
            ),
            const Gap(40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) {
                    EasyLoading.showError('O nome não pode ser vazio!');
                    return;
                  }
                  final logo = _selectedTeam != null ? _teamLogos[_selectedTeam] : null;
                  context.read<SettingCubit>().loginLocal(
                        name: name,
                        favoriteTeam: _selectedTeam,
                        favoriteTeamLogo: logo,
                      );
                  EasyLoading.showSuccess('Perfil salvo com sucesso!');
                  Navigator.pop(context);
                },
                child: const Text('Salvar Perfil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
