class Page<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;
  final bool first;
  final bool last;

  Page({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
    required this.first,
    required this.last,
  });

  factory Page.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final list = (json['content'] as List<dynamic>)
        .map((e) => fromJsonT(e as Map<String, dynamic>))
        .toList();
    return Page<T>(
      content: list,
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? list.length,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? list.length,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
    );
  }
}
