class Contact {
  int? id;
  final String name;
  final String phone;
  final String email;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  // Converte um objeto Contact para um Map (para o banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }

  // Cria um objeto Contact a partir de um Map (do banco de dados)
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
    );
  }

  // Método copyWith para criar uma cópia com novos valores
  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
  }) {
    return Contact(
      id: id ?? this.id,         // Se 'id' for passado, usa o novo; se não, usa o existente
      name: name ?? this.name,   // O mesmo vale para os outros campos
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}
