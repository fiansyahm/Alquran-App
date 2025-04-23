class City {
  final String id;
  final String lokasi;

  City({required this.id, required this.lokasi});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      lokasi: json['lokasi'],
    );
  }
}