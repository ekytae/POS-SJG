import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/history_service.dart';
import '../data/transaction_history_model.dart';

final historyServiceProvider = Provider((ref) => HistoryService());

class HistoryFilterState {
  final String search;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  HistoryFilterState({this.search = '', this.dateFrom, this.dateTo});

  HistoryFilterState copyWith({String? search, DateTime? dateFrom, DateTime? dateTo}) {
    return HistoryFilterState(
      search: search ?? this.search,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }
}

class HistoryFilterNotifier extends Notifier<HistoryFilterState> {
  @override
  HistoryFilterState build() => HistoryFilterState();

  void setSearch(String value) => state = state.copyWith(search: value);

  void setDateRange(DateTime? from, DateTime? to) {
    state = HistoryFilterState(search: state.search, dateFrom: from, dateTo: to);
  }

  void clearDateRange() {
    state = HistoryFilterState(search: state.search);
  }
}

final historyFilterProvider = NotifierProvider<HistoryFilterNotifier, HistoryFilterState>(
  HistoryFilterNotifier.new,
);

String? _formatDate(DateTime? date) {
  if (date == null) return null;
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

final transactionHistoryProvider = FutureProvider<List<TransactionListItem>>((ref) async {
  final filter = ref.watch(historyFilterProvider);
  final service = ref.watch(historyServiceProvider);

  return service.getTransactions(
    search: filter.search,
    dateFrom: _formatDate(filter.dateFrom),
    dateTo: _formatDate(filter.dateTo),
  );
});

final transactionDetailProvider = FutureProvider.family<TransactionDetailModel, int>((ref, id) async {
  final service = ref.watch(historyServiceProvider);
  return service.getDetail(id);
});