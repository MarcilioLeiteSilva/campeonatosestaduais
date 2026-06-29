import 'dart:math';

class TeamSquads {
  static final Map<String, List<Map<String, String>>> _realSquads = {
    'Cruzeiro': [
      {'name': 'Cássio', 'position': 'Goleiro'},
      {'name': 'William', 'position': 'Defensor'},
      {'name': 'Zé Ivaldo', 'position': 'Defensor'},
      {'name': 'João Marcelo', 'position': 'Defensor'},
      {'name': 'Marlon', 'position': 'Defensor'},
      {'name': 'Lucas Romero', 'position': 'Meio-campista'},
      {'name': 'Lucas Silva', 'position': 'Meio-campista'},
      {'name': 'Matheus Pereira', 'position': 'Meio-campista'},
      {'name': 'Álvaro Barreal', 'position': 'Meio-campista'},
      {'name': 'Lautaro Díaz', 'position': 'Atacante'},
      {'name': 'Juan Dinenno', 'position': 'Atacante'},
      {'name': 'Kaio Jorge', 'position': 'Atacante'},
      {'name': 'Gabriel Veron', 'position': 'Atacante'},
    ],
    'Atletico-MG': [
      {'name': 'Everson', 'position': 'Goleiro'},
      {'name': 'Renzo Saravia', 'position': 'Defensor'},
      {'name': 'Rodrigo Battaglia', 'position': 'Defensor'},
      {'name': 'Junior Alonso', 'position': 'Defensor'},
      {'name': 'Guilherme Arana', 'position': 'Defensor'},
      {'name': 'Otávio', 'position': 'Meio-campista'},
      {'name': 'Alan Franco', 'position': 'Meio-campista'},
      {'name': 'Gustavo Scarpa', 'position': 'Meio-campista'},
      {'name': 'Bernard', 'position': 'Meio-campista'},
      {'name': 'Paulinho', 'position': 'Atacante'},
      {'name': 'Hulk', 'position': 'Atacante'},
      {'name': 'Deyverson', 'position': 'Atacante'},
      {'name': 'Eduardo Vargas', 'position': 'Atacante'},
    ],
    'America Mineiro': [
      {'name': 'Elias', 'position': 'Goleiro'},
      {'name': 'Mateus Henrique', 'position': 'Defensor'},
      {'name': 'Éder', 'position': 'Defensor'},
      {'name': 'Ricardo Silva', 'position': 'Defensor'},
      {'name': 'Marlon', 'position': 'Defensor'},
      {'name': 'Juninho', 'position': 'Meio-campista'},
      {'name': 'Alê', 'position': 'Meio-campista'},
      {'name': 'Martín Benítez', 'position': 'Meio-campista'},
      {'name': 'Moisés', 'position': 'Meio-campista'},
      {'name': 'Fabinho', 'position': 'Atacante'},
      {'name': 'Renato Marques', 'position': 'Atacante'},
      {'name': 'Brenner', 'position': 'Atacante'},
    ]
  };

  static List<Map<String, String>> getSquad(String teamName) {
    // Normalizar nome para busca
    final normalized = _realSquads.keys.firstWhere(
      (k) => teamName.toLowerCase().contains(k.toLowerCase()),
      orElse: () => '',
    );
    if (normalized.isNotEmpty) {
      return _realSquads[normalized]!;
    }
    
    // Gerar squad realista para outros times
    final firstNames = ['Matheus', 'Thiago', 'Lucas', 'Gabriel', 'Felipe', 'Rodrigo', 'Bruno', 'Diego', 'Gustavo', 'Rafael', 'Vinícius', 'Marcos', 'André', 'Eduardo'];
    final lastNames = ['Silva', 'Santos', 'Oliveira', 'Souza', 'Rodrigues', 'Ferreira', 'Alves', 'Pereira', 'Lima', 'Gomes', 'Costa', 'Ribeiro', 'Martins', 'Carvalho'];
    
    final List<Map<String, String>> mockSquad = [];
    final rand = Random(teamName.hashCode);
    
    mockSquad.add({'name': '${firstNames[rand.nextInt(firstNames.length)]} ${lastNames[rand.nextInt(lastNames.length)]}', 'position': 'Goleiro'});
    
    for (int i = 0; i < 4; i++) {
      mockSquad.add({'name': '${firstNames[rand.nextInt(firstNames.length)]} ${lastNames[rand.nextInt(lastNames.length)]}', 'position': 'Defensor'});
    }
    for (int i = 0; i < 4; i++) {
      mockSquad.add({'name': '${firstNames[rand.nextInt(firstNames.length)]} ${lastNames[rand.nextInt(lastNames.length)]}', 'position': 'Meio-campista'});
    }
    for (int i = 0; i < 4; i++) {
      mockSquad.add({'name': '${firstNames[rand.nextInt(firstNames.length)]} ${lastNames[rand.nextInt(lastNames.length)]}', 'position': 'Atacante'});
    }
    
    return mockSquad;
  }
}
