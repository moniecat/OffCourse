class Course {
  final String id;
  final String title;
  final String? description;
  final int order;

  const Course({
    required this.id,
    required this.title,
    this.description,
    required this.order,
  });

  factory Course.fromMap(String id, Map<String, dynamic> data) {
    return Course(
      id: id,
      title: data['title'] as String? ?? 'Untitled',
      description: data['description'] as String?,
      order: data['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'order': order,
  };
}