// lib/models/person.dart

class Person {
  final int id;
  final String firstNames;
  final String lastNames;
  final String dni;
  final String phone;
  final String email;

  Person({
    required this.id,
    required this.firstNames,
    required this.lastNames,
    required this.dni,
    required this.phone,
    required this.email,
  });

  // Optional constructor (no ID)
  Person.create({
    required this.firstNames,
    required this.lastNames,
    required this.dni,
    required this.phone,
    required this.email,
  }) : id = 0;

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      firstNames: json['first_names'] as String,
      lastNames: json['last_names'] as String,
      dni: json['dni'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_names': firstNames,
      'last_names': lastNames,
      'dni': dni,
      'phone': phone,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'Person('
        'id: $id, '
        'firstNames: $firstNames, '
        'lastNames: $lastNames, '
        'dni: $dni, '
        'phone: $phone, '
        'email: $email'
        ')';
  }
}