import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_contributions.dart';
import '../../domain/usecases/submit_contribution.dart';
import '../../domain/usecases/withdraw_contribution.dart';
import 'contribution_event.dart';
import 'contribution_state.dart';

class ContributionBloc extends Bloc<ContributionEvent, ContributionState> {
  final SubmitContribution _submit;
  final GetContributions _getContributions;
  final WithdrawContribution _withdraw;
  static const _perPage = 20;

  ContributionBloc({
    required SubmitContribution submit,
    required GetContributions getContributions,
    required WithdrawContribution withdraw,
  })  : _submit = submit,
        _getContributions = getContributions,
        _withdraw = withdraw,
        super(const ContributionInitial()) {
    on<LoadContributions>(_onLoadContributions);
    on<LoadMoreContributions>(_onLoadMore);
    on<SubmitContributionEvent>(_onSubmit);
    on<WithdrawContributionEvent>(_onWithdraw);
  }

  ContributionLoaded? get _currentLoaded =>
      state is ContributionLoaded ? state as ContributionLoaded : null;

  Future<void> _onLoadContributions(
    LoadContributions event,
    Emitter<ContributionState> emit,
  ) async {
    emit(const ContributionLoading());
    final result = await _getContributions(
      GetContributionsParams(status: event.filterStatus),
    );
    result.fold(
      (failure) => emit(ContributionError(failure)),
      (paginated) => emit(ContributionLoaded(
        contributions: paginated.items,
        hasMore: paginated.hasMore,
        currentPage: paginated.page,
        filterStatus: event.filterStatus,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreContributions event,
    Emitter<ContributionState> emit,
  ) async {
    final current = _currentLoaded;
    if (current == null || !current.hasMore) return;

    final result = await _getContributions(GetContributionsParams(
      status: current.filterStatus,
      page: current.currentPage + 1,
      perPage: _perPage,
    ));
    result.fold(
      (failure) => emit(ContributionError(failure)),
      (paginated) => emit(ContributionLoaded(
        contributions: [...current.contributions, ...paginated.items],
        hasMore: paginated.hasMore,
        currentPage: paginated.page,
        filterStatus: current.filterStatus,
      )),
    );
  }

  Future<void> _onSubmit(
    SubmitContributionEvent event,
    Emitter<ContributionState> emit,
  ) async {
    emit(const ContributionSubmitting());
    final result = await _submit(SubmitContributionParams(
      type: event.type,
      targetWordId: event.targetWordId,
      payload: event.payload,
    ));
    result.fold(
      (failure) => emit(ContributionError(failure)),
      (contribution) => emit(ContributionSubmitted(contribution)),
    );
  }

  Future<void> _onWithdraw(
    WithdrawContributionEvent event,
    Emitter<ContributionState> emit,
  ) async {
    final current = _currentLoaded;
    final currentList = current?.contributions ?? [];
    emit(ContributionWithdrawing(currentList));

    final result = await _withdraw(WithdrawContributionParams(
      contributionId: event.contributionId,
      currentStatus: event.currentStatus,
    ));

    result.fold(
      (failure) => emit(ContributionError(failure)),
      (_) => emit(ContributionWithdrawn(
        contributions: currentList
            .where((c) => c.id != event.contributionId)
            .toList(),
        withdrawnId: event.contributionId,
      )),
    );
  }
}
