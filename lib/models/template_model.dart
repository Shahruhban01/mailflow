class TemplateModel {
  final int id;
  final String name;
  final String subject;
  final String body;

  const TemplateModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.body,
  });

factory TemplateModel.fromJson(Map<String, dynamic> json) => TemplateModel(
    id:      int.parse(json['id'].toString()),
    name:    json['name'] as String,
    subject: json['subject'] as String,
    body:    json['body'] as String,
  );

}
