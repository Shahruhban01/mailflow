class EmailModel {
  final int id;
  final String senderName;
  final String senderEmail;
  final String receiverEmail;
  final String? cc;
  final String? bcc;
  final String subject;
  final String message;
  final bool isHtml;
  final String priority;
  final String? attachments;
  final String status;
  final String createdAt;

  const EmailModel({
    required this.id,
    required this.senderName,
    required this.senderEmail,
    required this.receiverEmail,
    this.cc,
    this.bcc,
    required this.subject,
    required this.message,
    required this.isHtml,
    required this.priority,
    this.attachments,
    required this.status,
    required this.createdAt,
  });

  factory EmailModel.fromJson(Map<String, dynamic> json) => EmailModel(
        id: int.parse(json['id'].toString()),
        senderName: json['sender_name'] as String,
        senderEmail: json['sender_email'] as String,
        receiverEmail: json['receiver_email'] as String,
        cc: json['cc'] as String?,
        bcc: json['bcc'] as String?,
        subject: json['subject'] as String,
        message: json['message'] as String,
        isHtml:
            json['is_html'].toString() == '1', // PDO returns "0"/"1" as string
        priority: json['priority'] as String,
        attachments: json['attachments'] as String?,
        status: json['status'] as String,
        createdAt: json['created_at'] as String,
      );
}
