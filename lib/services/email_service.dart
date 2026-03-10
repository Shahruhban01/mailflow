import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/email_model.dart';
import '../models/template_model.dart';

class EmailService {
  final ApiClient _client;
  EmailService(this._client);

  Future<Map<String, dynamic>> sendEmail({
    required String senderName,
    required String senderEmail,
    required String to,
    String? cc,
    String? bcc,
    required String subject,
    required String message,
    bool isHtml = false,
    String priority = 'normal',
    String action = 'send',          // 'send' | 'draft'
    String? scheduledAt,
    List<String>? attachmentPaths,
  }) async {
    final formData = <String, dynamic>{
      'sender_name':  senderName,
      'sender_email': senderEmail,
      'to':           to,
      'cc':           cc ?? '',
      'bcc':          bcc ?? '',
      'subject':      subject,
      'message':      message,
      'is_html':      isHtml ? '1' : '0',
      'priority':     priority,
      'action':       action,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
    };

    if (attachmentPaths != null && attachmentPaths.isNotEmpty) {
      final files = <MultipartFile>[];
      for (final path in attachmentPaths) {
        files.add(await MultipartFile.fromFile(path));
      }
      formData['attachments[]'] = files;
    }

    final res = await _client.post(
      ApiEndpoints.sendEmail,
      data: formData,
      isFormData: true,
    );
    return res.data as Map<String, dynamic>;
  }

  Future<List<EmailModel>> getHistory({
    String filter = 'all',
    String? search,
    int page = 1,
  }) async {
    final res = await _client.get(ApiEndpoints.history, queryParams: {
      'filter': filter,
      if (search != null && search.isNotEmpty) 'q': search,
      'page': page,
    });
    final list = res.data['emails'] as List;
    return list.map((e) => EmailModel.fromJson(e)).toList();
  }

  Future<EmailModel> getEmail(int id) async {
    final res = await _client.get(ApiEndpoints.viewEmail, queryParams: {'id': id});
    return EmailModel.fromJson(res.data['email']);
  }

  Future<void> deleteEmail(int id) async {
    await _client.post(ApiEndpoints.deleteEmail, data: {'id': id});
  }

  // ── Templates ──
  Future<List<TemplateModel>> getTemplates() async {
    final res = await _client.get(ApiEndpoints.templates);
    final list = res.data['templates'] as List;
    return list.map((e) => TemplateModel.fromJson(e)).toList();
  }

  Future<TemplateModel> createTemplate({
    required String name,
    required String subject,
    required String body,
  }) async {
    final res = await _client.post(ApiEndpoints.createTemplate, data: {
      'name': name, 'subject': subject, 'body': body,
    });
    return TemplateModel.fromJson(res.data['template'] as Map<String, dynamic>);
  }

  Future<void> updateTemplate({
    required int id,
    required String name,
    required String subject,
    required String body,
  }) async {
    await _client.post(ApiEndpoints.updateTemplate, data: {
      'id': id, 'name': name, 'subject': subject, 'body': body,
    });
  }

  Future<void> deleteTemplate(int id) async {
    await _client.post(ApiEndpoints.deleteTemplate, data: {'id': id});
  }
}
