// import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/email_model.dart';
// import '../../../services/email_service.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/status_badge.dart';
import '../../compose/providers/compose_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../providers/history_provider.dart';

final _emailDetailProvider =
    FutureProvider.family<EmailModel, int>((ref, id) async {
  return ref.read(emailServiceProvider).getEmail(id);
});

class EmailDetailScreen extends ConsumerStatefulWidget {
  final int emailId;
  const EmailDetailScreen({super.key, required this.emailId});

  @override
  ConsumerState<EmailDetailScreen> createState() => _EmailDetailScreenState();
}

class _EmailDetailScreenState extends ConsumerState<EmailDetailScreen> {
  final Map<String, bool> _downloading = {};

  @override
  Widget build(BuildContext context) {
    final emailAsync = ref.watch(_emailDetailProvider(widget.emailId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Email Details'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: emailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (email) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject
              Text(email.subject, style: AppTypography.headingLg),
              const SizedBox(height: AppSpacing.md),

              // Meta card
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(children: [
                  _MetaRow(
                    icon: Icons.person_outline_rounded, label: 'From',
                    value: '${email.senderName} <${email.senderEmail}>',
                  ),
                  const Divider(height: AppSpacing.lg),
                  _MetaRow(
                    icon: Icons.send_rounded, label: 'To',
                    value: email.receiverEmail,
                  ),
                  if (email.cc != null && email.cc!.isNotEmpty) ...[
                    const Divider(height: AppSpacing.lg),
                    _MetaRow(
                      icon: Icons.people_outline_rounded, label: 'CC',
                      value: email.cc!,
                    ),
                  ],
                  const Divider(height: AppSpacing.lg),
                  _MetaRow(
                    icon: Icons.calendar_today_outlined, label: 'Date',
                    value: _formatDate(email.createdAt),
                  ),
                  const Divider(height: AppSpacing.lg),
                  Row(children: [
                    StatusBadge(status: email.status),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${email.priority[0].toUpperCase()}${email.priority.substring(1)} Priority',
                        style: AppTypography.caption,
                      ),
                    ),
                  ]),
                ]),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Message
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MESSAGE', style: AppTypography.labelSm),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      email.message.replaceAll(RegExp(r'<[^>]*>'), ''),
                      style: AppTypography.bodyMd.copyWith(height: 1.7),
                    ),
                  ],
                ),
              ),

              // Attachments
              if (email.attachments != null &&
                  email.attachments!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ATTACHMENTS', style: AppTypography.labelSm),
                      const SizedBox(height: AppSpacing.md),
                      ..._parseAttachments(email.attachments!).map(
                        (path) => _AttachmentTile(
                          filePath: path,
                          isDownloading: _downloading[path] ?? false,
                          onOpen: () => _openAttachment(path),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Draft send option
              if (email.status == 'draft') ...[
                const SizedBox(height: AppSpacing.lg),
                _ActionCard(
                  icon: Icons.send_rounded,
                  color: AppColors.primary,
                  title: 'Send this Draft',
                  subtitle: 'Send this saved draft now',
                  onTap: () => _sendDraft(context, ref, email),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Action buttons
              Row(children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.reply_rounded,
                    color: AppColors.primary,
                    title: 'Reply',
                    subtitle: 'Follow-up reply',
                    onTap: () => _reply(ref, email),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.forward_rounded,
                    color: AppColors.accent,
                    title: 'Forward',
                    subtitle: 'Forward to others',
                    onTap: () => _forward(ref, email),
                  ),
                ),
              ]),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _parseAttachments(String raw) {
    try {
      // JSON array format
      if (raw.startsWith('[')) {
        final decoded = raw
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        return decoded;
      }
      return [raw];
    } catch (_) { return [raw]; }
  }

  Future<void> _openAttachment(String serverPath) async {
    setState(() => _downloading[serverPath] = true);
    try {
      final fileName = serverPath.split('/').last;
      final dir      = await getTemporaryDirectory();
      final localPath = '${dir.path}/$fileName';

      // Build download URL
      final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api', '');
      final fileUrl = serverPath.startsWith('http')
          ? serverPath
          : '$baseUrl/uploads/$fileName';

      await Dio().download(fileUrl, localPath);
      await OpenFilex.open(localPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not open file: $e'),
          backgroundColor: AppColors.danger,
        ));
      }
    } finally {
      if (mounted) setState(() => _downloading[serverPath] = false);
    }
  }

  void _reply(WidgetRef ref, EmailModel email) {
    ref.read(prefillProvider.notifier).state = PrefillState(
      to:      email.senderEmail,
      subject: 'Re: ${email.subject}',
      body:    '\n\n\n--- Original Message ---\nFrom: ${email.senderName} <${email.senderEmail}>\nDate: ${email.createdAt}\n\n${email.message.replaceAll(RegExp(r'<[^>]*>'), '')}',
    );
    ref.read(dashboardTabProvider.notifier).state = 1;
    context.pop();
  }

  void _forward(WidgetRef ref, EmailModel email) {
    ref.read(prefillProvider.notifier).state = PrefillState(
      subject: 'Fwd: ${email.subject}',
      body:    '\n\n\n--- Forwarded Message ---\nFrom: ${email.senderName} <${email.senderEmail}>\nTo: ${email.receiverEmail}\nDate: ${email.createdAt}\n\n${email.message.replaceAll(RegExp(r'<[^>]*>'), '')}',
    );
    ref.read(dashboardTabProvider.notifier).state = 1;
    context.pop();
  }

  Future<void> _sendDraft(
    BuildContext context,
    WidgetRef ref,
    EmailModel email,
  ) async {
    try {
      await ref.read(emailServiceProvider).sendEmail(
        senderName:  email.senderName,
        senderEmail: email.senderEmail,
        to:          email.receiverEmail,
        cc:          email.cc,
        bcc:         email.bcc,
        subject:     email.subject,
        message:     email.message,
        isHtml:      email.isHtml,
        priority:    email.priority,
        action:      'send',
      );

      // Delete old draft
      await ref.read(emailServiceProvider).deleteEmail(email.id);
      ref.invalidate(historyProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Draft sent successfully!'),
          backgroundColor: AppColors.success,
        ));
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.danger,
        ));
      }
    }
  }

  String _formatDate(String dt) {
    try {
      final d = DateTime.parse(dt);
      final months = ['Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[d.month-1]} ${d.day}, ${d.year} at '
             '${d.hour}:${d.minute.toString().padLeft(2,'0')}';
    } catch (_) { return dt; }
  }
}

// ── Attachment tile ──
class _AttachmentTile extends StatelessWidget {
  final String filePath;
  final bool isDownloading;
  final VoidCallback onOpen;
  const _AttachmentTile({
    required this.filePath,
    required this.isDownloading,
    required this.onOpen,
  });

  IconData _iconFor(String name) {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'pdf'                     => Icons.picture_as_pdf_rounded,
      'doc' || 'docx'           => Icons.description_outlined,
      'xls' || 'xlsx' || 'csv'  => Icons.table_chart_outlined,
      'png' || 'jpg' || 'jpeg'
        || 'gif'                => Icons.image_outlined,
      'zip'                     => Icons.folder_zip_outlined,
      'txt'                     => Icons.text_snippet_outlined,
      _                         => Icons.attach_file_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final name = filePath.split('/').last;
    return GestureDetector(
      onTap: isDownloading ? null : onOpen,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(_iconFor(name),
              size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(name,
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          )),
          isDownloading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary,
                  ),
                )
              : const Icon(Icons.open_in_new_rounded,
                  size: 16, color: AppColors.textMuted),
        ]),
      ),
    );
  }
}

// ── Action card ──
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon, required this.color,
    required this.title, required this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.headingSm.copyWith(color: color)),
            Text(subtitle, style: AppTypography.caption),
          ],
        )),
      ]),
    ),
  );
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _MetaRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: AppColors.textMuted),
      const SizedBox(width: AppSpacing.sm),
      SizedBox(width: 44,
        child: Text(label,
          style: AppTypography.labelLg.copyWith(color: AppColors.textMuted),
        ),
      ),
      Expanded(child: Text(value, style: AppTypography.bodyMd)),
    ],
  );
}
