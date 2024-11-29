class Subject {
  final int? id;
  final String name;
  final int totalLectures;
  final int attendedLectures;

  Subject({
    this.id,
    required this.name,
    required this.totalLectures,
    required this.attendedLectures,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalLectures': totalLectures,
      'attendedLectures': attendedLectures,
    };
  }
}
