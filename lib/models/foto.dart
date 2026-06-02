class Foto {
  final int id;
  final int reporteId;
  final String url;
  final String tipo; // TipoFoto.INICIAL | TipoFoto.FINAL
  final String? descripcion;
  final String? fechaCarga;

  Foto({
    required this.id,
    required this.reporteId,
    required this.url,
    required this.tipo,
    this.descripcion,
    this.fechaCarga,
  });

  factory Foto.fromJson(Map<String, dynamic> json) => Foto(
        id: json['id'] as int,
        reporteId: json['reporteId'] as int,
        url: json['url'] as String,
        tipo: json['tipo'] as String,
        descripcion: json['descripcion'] as String?,
        fechaCarga: json['fechaCarga'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'reporteId': reporteId,
        'url': url,
        'tipo': tipo,
        'descripcion': descripcion,
        'fechaCarga': fechaCarga,
      };
}
