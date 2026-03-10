import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/template_model.dart';
import '../../../services/email_service.dart';
import '../../compose/providers/compose_provider.dart';

class TemplatesState {
  final List<TemplateModel> templates;
  final bool isLoading;
  final String? error;

  const TemplatesState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
  });

  TemplatesState copyWith({
    List<TemplateModel>? templates,
    bool? isLoading,
    String? error,
  }) => TemplatesState(
    templates: templates ?? this.templates,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class TemplatesNotifier extends StateNotifier<TemplatesState> {
  final EmailService _service;
  TemplatesNotifier(this._service) : super(const TemplatesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _service.getTemplates();
      state = state.copyWith(templates: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> create({
    required String name,
    required String subject,
    required String body,
  }) async {
    final t = await _service.createTemplate(
      name: name, subject: subject, body: body,
    );
    state = state.copyWith(templates: [...state.templates, t]);
  }

  Future<void> update({
    required int id,
    required String name,
    required String subject,
    required String body,
  }) async {
    await _service.updateTemplate(
      id: id, name: name, subject: subject, body: body,
    );
    state = state.copyWith(
      templates: state.templates.map((t) => t.id == id
          ? TemplateModel(id: id, name: name, subject: subject, body: body)
          : t).toList(),
    );
  }

  Future<void> delete(int id) async {
    await _service.deleteTemplate(id);
    state = state.copyWith(
      templates: state.templates.where((t) => t.id != id).toList(),
    );
  }
}

final templatesProvider =
    StateNotifierProvider<TemplatesNotifier, TemplatesState>((ref) {
  return TemplatesNotifier(ref.read(emailServiceProvider));
});
