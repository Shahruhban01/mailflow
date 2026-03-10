import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
// import '../../../models/template_model.dart';
import '../../../services/email_service.dart';

final emailServiceProvider = Provider<EmailService>((ref) {
  return EmailService(ref.read(apiClientProvider));
});

class PrefillState {
  final String? subject;
  final String? body;
  final String? to;
  const PrefillState({this.subject, this.body, this.to});
}

final prefillProvider = StateProvider<PrefillState?>((ref) => null);

sealed class ComposeState {}
class ComposeIdle      extends ComposeState {}
class ComposeLoading   extends ComposeState {}
class ComposeSent      extends ComposeState {}
class ComposeDraft     extends ComposeState {}
class ComposeScheduled extends ComposeState { final String at; ComposeScheduled(this.at); }
class ComposeFailed    extends ComposeState { final String msg; ComposeFailed(this.msg); }

class ComposeNotifier extends StateNotifier<ComposeState> {
  final EmailService _service;
  ComposeNotifier(this._service) : super(ComposeIdle());

  Future<void> send({
    required String senderName,
    required String senderEmail,
    required String to,
    String? cc, String? bcc,
    required String subject,
    required String message,
    bool isHtml = false,
    String priority = 'normal',
    String action = 'send',
    String? scheduledAt,
    List<String>? attachmentPaths,
  }) async {
    state = ComposeLoading();
    try {
      final res = await _service.sendEmail(
        senderName: senderName, senderEmail: senderEmail,
        to: to, cc: cc, bcc: bcc, subject: subject, message: message,
        isHtml: isHtml, priority: priority, action: action,
        scheduledAt: scheduledAt, attachmentPaths: attachmentPaths,
      );
      final status = res['status'] as String? ?? 'failed';
      state = switch (status) {
        'sent'      => ComposeSent(),
        'draft'     => ComposeDraft(),
        'scheduled' => ComposeScheduled(scheduledAt ?? ''),
        _           => ComposeFailed('Failed to send.'),
      };
    } catch (e) {
      state = ComposeFailed(e.toString());
    }
  }

  void reset() => state = ComposeIdle();
}

final composeProvider =
    StateNotifierProvider<ComposeNotifier, ComposeState>((ref) {
  return ComposeNotifier(ref.read(emailServiceProvider));
});
