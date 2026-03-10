import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/email_model.dart';
import '../../../services/email_service.dart';
import '../../compose/providers/compose_provider.dart';

class HistoryState {
  final List<EmailModel> emails;
  final bool isLoading;
  final String? error;
  final String filter;
  final String search;

  const HistoryState({
    this.emails = const [],
    this.isLoading = false,
    this.error,
    this.filter = 'all',
    this.search = '',
  });

  HistoryState copyWith({
    List<EmailModel>? emails,
    bool? isLoading,
    String? error,
    String? filter,
    String? search,
  }) => HistoryState(
    emails:    emails    ?? this.emails,
    isLoading: isLoading ?? this.isLoading,
    error:     error,
    filter:    filter    ?? this.filter,
    search:    search    ?? this.search,
  );
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final EmailService _service;
  HistoryNotifier(this._service) : super(const HistoryState()) {
    load();
  }

  Future<void> load({String? filter, String? search}) async {
    state = state.copyWith(
      isLoading: true,
      filter: filter ?? state.filter,
      search: search ?? state.search,
    );
    try {
      final emails = await _service.getHistory(
        filter: state.filter,
        search: state.search,
      );
      state = state.copyWith(emails: emails, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> delete(int id) async {
    await _service.deleteEmail(id);
    state = state.copyWith(
      emails: state.emails.where((e) => e.id != id).toList(),
    );
  }

  void setFilter(String f) => load(filter: f);
  void setSearch(String q) => load(search: q);
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref.read(emailServiceProvider));
});
