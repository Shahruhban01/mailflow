import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/glass_card.dart';
import '../providers/compose_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key});
  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _senderName,
      _senderEmail,
      _to,
      _cc,
      _bcc,
      _subject,
      _message;

  String _priority = 'normal';
  bool _showCc = false;
  bool _showBcc = false;
  bool _isHtml = false;
  DateTime? _scheduleDate;
  List<PlatformFile> _attachments = [];

  @override
  void initState() {
    super.initState();
    final user = (ref.read(authProvider) as AuthSuccess?)?.user;
    _senderName = TextEditingController(text: user?.name ?? '');
    _senderEmail = TextEditingController(text: user?.email ?? '');
    _to = TextEditingController();
    _cc = TextEditingController();
    _bcc = TextEditingController();
    _subject = TextEditingController();

    // ── Auto-append signature if set ──
    final sig = user?.signature ?? '';
    _message = TextEditingController(
      text: sig.isNotEmpty ? '\n\n──────────\n$sig' : '',
    );

    // Position cursor at top so user types above signature
    if (sig.isNotEmpty) {
      _message.selection = TextSelection.collapsed(offset: 0);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _applyPrefill());
  }

  void _applyPrefill() {
    final p = ref.read(prefillProvider);
    if (p == null) return;

    if (p.subject != null) _subject.text = p.subject!;
    if (p.to != null) _to.text = p.to!;

    if (p.body != null) {
      final user = (ref.read(authProvider) as AuthSuccess?)?.user;
      final sig = user?.signature ?? '';
      // Inject template body above existing signature
      _message.text =
          sig.isNotEmpty ? '${p.body!}\n\n──────────\n$sig' : p.body!;
      _message.selection = TextSelection.collapsed(offset: 0);
    }

    ref.read(prefillProvider.notifier).state = null;
  }

  @override
  void dispose() {
    for (final c in [
      _senderName,
      _senderEmail,
      _to,
      _cc,
      _bcc,
      _subject,
      _message
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final r = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (r != null) setState(() => _attachments = r.files);
  }

  Future<void> _pickScheduleDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) return;
    setState(() {
      _scheduleDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit(String action) {
    if (!_form.currentState!.validate()) return;
    final scheduledAt =
        _scheduleDate != null ? _scheduleDate!.toIso8601String() : null;

    ref.read(composeProvider.notifier).send(
          senderName: _senderName.text.trim(),
          senderEmail: _senderEmail.text.trim(),
          to: _to.text.trim(),
          cc: _cc.text.trim().isEmpty ? null : _cc.text.trim(),
          bcc: _bcc.text.trim().isEmpty ? null : _bcc.text.trim(),
          subject: _subject.text.trim(),
          message: _message.text.trim(),
          isHtml: _isHtml,
          priority: _priority,
          action: action,
          scheduledAt: scheduledAt,
          attachmentPaths: _attachments.map((f) => f.path!).toList(),
        );
  }

  void _reset() {
    _subject.clear();
    _to.clear();
    _cc.clear();
    _bcc.clear();

    // ── Re-attach signature on reset ──
    final user = (ref.read(authProvider) as AuthSuccess?)?.user;
    final sig = user?.signature ?? '';
    _message.text = sig.isNotEmpty ? '\n\n──────────\n$sig' : '';
    if (sig.isNotEmpty) {
      _message.selection = TextSelection.collapsed(offset: 0);
    }

    setState(() {
      _attachments = [];
      _priority = 'normal';
      _scheduleDate = null;
      _isHtml = false;
    });
    ref.read(composeProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(composeProvider);
    final isLoading = state is ComposeLoading;

    ref.listen(composeProvider, (_, next) {
      switch (next) {
        case ComposeSent():
          _showSnack('Email sent successfully! ✓', AppColors.success);
          _reset();
        case ComposeDraft():
          _showSnack('Draft saved.', AppColors.warning);
          _reset();
        case ComposeScheduled(at: final at):
          _showSnack('Email scheduled for $at', AppColors.info);
          _reset();
        case ComposeFailed(msg: final msg):
          _showSnack(msg, AppColors.danger);
        default:
          break;
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header().animate().fadeIn().slideY(begin: -0.1),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl4,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Form(
                    key: _form,
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // From
                          _SectionLabel('From'),
                          const SizedBox(height: AppSpacing.sm),
                          Row(children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Name',
                                hint: 'Sender name',
                                controller: _senderName,
                                textInputAction: TextInputAction.next,
                                validator: Validators.name,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppTextField(
                                label: 'Email',
                                hint: 'sender@example.com',
                                controller: _senderEmail,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: Validators.email,
                              ),
                            ),
                          ]),

                          const SizedBox(height: AppSpacing.lg),
                          const Divider(),
                          const SizedBox(height: AppSpacing.lg),

                          // To
                          _InlineField(
                            label: 'To',
                            controller: _to,
                            hint: 'recipient@example.com',
                            validator: Validators.email,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ChipToggle(
                                  label: 'CC',
                                  active: _showCc,
                                  onTap: () => setState(
                                    () => _showCc = !_showCc,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                _ChipToggle(
                                  label: 'BCC',
                                  active: _showBcc,
                                  onTap: () => setState(
                                    () => _showBcc = !_showBcc,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (_showCc) ...[
                            const Divider(height: 1),
                            _InlineField(
                              label: 'CC',
                              controller: _cc,
                              hint: 'cc@example.com',
                            ),
                          ],
                          if (_showBcc) ...[
                            const Divider(height: 1),
                            _InlineField(
                              label: 'BCC',
                              controller: _bcc,
                              hint: 'bcc@example.com',
                            ),
                          ],
                          const Divider(height: 1),
                          _InlineField(
                            label: 'Sub',
                            controller: _subject,
                            hint: 'Email subject…',
                            validator: (v) => Validators.required(v, 'Subject'),
                          ),

                          const SizedBox(height: AppSpacing.lg),
                          const Divider(),
                          const SizedBox(height: AppSpacing.md),

                          AppTextField(
                            label: 'Message',
                            hint: 'Write your message…',
                            controller: _message,
                            maxLines: 8,
                            validator: (v) => Validators.required(v, 'Message'),
                          ),

                          const SizedBox(height: AppSpacing.lg),
                          const Divider(),
                          const SizedBox(height: AppSpacing.lg),

                          // HTML toggle
                          Row(children: [
                            _SectionLabel('HTML Mode'),
                            const Spacer(),
                            Switch.adaptive(
                              value: _isHtml,
                              activeColor: AppColors.primary,
                              onChanged: (v) => setState(() => _isHtml = v),
                            ),
                          ]),

                          const SizedBox(height: AppSpacing.lg),

                          // Priority
                          _SectionLabel('Priority'),
                          const SizedBox(height: AppSpacing.sm),
                          _PrioritySelector(
                            value: _priority,
                            onChanged: (v) => setState(() => _priority = v),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Schedule
                          _SectionLabel('Schedule Send'),
                          const SizedBox(height: AppSpacing.sm),
                          GestureDetector(
                            onTap: _pickScheduleDate,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: _scheduleDate != null
                                    ? AppColors.primaryLight
                                    : AppColors.bg,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                                border: Border.all(
                                  color: _scheduleDate != null
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 18,
                                  color: _scheduleDate != null
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    _scheduleDate != null
                                        ? _formatSchedule(_scheduleDate!)
                                        : 'Tap to schedule (optional)',
                                    style: AppTypography.bodyMd.copyWith(
                                      color: _scheduleDate != null
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                if (_scheduleDate != null)
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => _scheduleDate = null,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                              ]),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Attachments
                          _SectionLabel('Attachments'),
                          const SizedBox(height: AppSpacing.sm),
                          _AttachmentArea(
                            files: _attachments,
                            onAdd: _pickFiles,
                            onRemove: (i) => setState(
                              () => _attachments = List.from(_attachments)
                                ..removeAt(i),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Action buttons
                          Row(children: [
                            Expanded(
                              child: AppButton(
                                label: 'Save Draft',
                                variant: AppButtonVariant.secondary,
                                isLoading: isLoading,
                                onPressed:
                                    isLoading ? null : () => _submit('draft'),
                                icon: const Icon(
                                  Icons.save_outlined,
                                  size: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              flex: 2,
                              child: AppButton(
                                label: _scheduleDate != null
                                    ? 'Schedule'
                                    : 'Send Email',
                                isLoading: isLoading,
                                onPressed:
                                    isLoading ? null : () => _submit('send'),
                                icon: Icon(
                                  _scheduleDate != null
                                      ? Icons.schedule_send_rounded
                                      : Icons.send_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSchedule(DateTime d) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} at $h:$m';
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ));
  }
}

// ── Header ──
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.gradientAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.mail_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('MailFlow', style: AppTypography.headingMd),
          ]),
          const SizedBox(height: AppSpacing.xl),
          Text('Compose Email', style: AppTypography.displayMd),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Send professional emails instantly',
            style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
          ),
        ]),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppTypography.labelSm);
}

class _InlineField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? trailing;

  const _InlineField({
    required this.label,
    required this.controller,
    required this.hint,
    this.validator,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            width: 42,
            child: Text(
              label,
              style: AppTypography.labelLg.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: TextInputType.emailAddress,
              style: AppTypography.bodyMd,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ]),
      );
}

class _ChipToggle extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ChipToggle(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryLight : AppColors.bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: active ? AppColors.primary : AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ),
      );
}

class _PrioritySelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _PrioritySelector({required this.value, required this.onChanged});

  static const _opts = [
    ('low', '🟢 Low', AppColors.success),
    ('normal', '🔵 Normal', AppColors.primary),
    ('high', '🔴 High', AppColors.danger),
  ];

  @override
  Widget build(BuildContext context) => Row(
        children: _opts.map((o) {
          final (val, label, color) = o;
          final sel = value == val;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(val),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: sel ? color.withOpacity(0.1) : AppColors.bg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: sel ? color : AppColors.border,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSm.copyWith(
                    color: sel ? color : AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
}

class _AttachmentArea extends StatelessWidget {
  final List<PlatformFile> files;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  const _AttachmentArea(
      {required this.files, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.attach_file_rounded,
                    size: 18, color: AppColors.textMuted),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Tap to attach files',
                  style:
                      AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                ),
              ]),
            ),
          ),
          if (files.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ...files.asMap().entries.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.insert_drive_file_outlined,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: Text(e.value.name,
                            style: AppTypography.bodySm,
                            overflow: TextOverflow.ellipsis)),
                    Text('${(e.value.size / 1024).toStringAsFixed(0)}KB',
                        style: AppTypography.caption),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: () => onRemove(e.key),
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: AppColors.textMuted),
                    ),
                  ]),
                )),
          ],
        ],
      );
}
