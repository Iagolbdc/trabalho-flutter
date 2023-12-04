class AlunoModel {
  final String nome;
  final String matricula;
  final int idade;
  final DateTime? horarioEntrada;
  final DateTime? horarioSaida;
  final String telefoneResponsavel;
  final bool liberado;
  final String qrcode;
  final String foto;
  final int advertencias;
  final int id;

  AlunoModel({
    required this.nome,
    required this.matricula,
    required this.idade,
    required this.horarioEntrada,
    required this.horarioSaida,
    required this.telefoneResponsavel,
    required this.liberado,
    required this.qrcode,
    required this.foto,
    required this.advertencias,
    required this.id,
  });

  factory AlunoModel.fromJson(Map<String, dynamic> json) {
    return AlunoModel(
      nome: json['nome'],
      matricula: json['matricula'],
      idade: json['idade'],
      horarioEntrada: json['horario_entrada'] != null
          ? DateTime.parse(json['horario_entrada'])
          : null,
      advertencias: json['advertencias'],
      foto: json['foto'],
      horarioSaida: json['horario_saida'] != null
          ? DateTime.parse(json['horario_saida'])
          : null,
      id: json['id'],
      liberado: json['liberado'],
      qrcode: json['qrcode'],
      telefoneResponsavel: json['telefone_responsavel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'matricula': matricula,
      'idade': idade,
      'horario_entrada': horarioEntrada?.toIso8601String(),
      'advertencias': advertencias,
      'foto': foto,
      'horario_saida': horarioSaida?.toIso8601String(),
      'liberado': liberado,
      'qrcode': qrcode,
      'telefone_responsavel': telefoneResponsavel,
    };
  }
}
