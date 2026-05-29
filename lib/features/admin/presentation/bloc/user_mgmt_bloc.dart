import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/admin_repository.dart';
import '../../domain/usecases/ban_user.dart' as ban;
import '../../domain/usecases/change_user_role.dart';
import '../../domain/usecases/get_admin_users.dart';
import '../../domain/usecases/unban_user.dart';
import 'user_mgmt_event.dart';
import 'user_mgmt_state.dart';

class UserMgmtBloc extends Bloc<UserMgmtEvent, UserMgmtState> {
  final GetAdminUsers _getUsers;
  final ban.BanUser _banUser;
  final UnbanUser _unbanUser;
  final ChangeUserRole _changeRole;

  UserMgmtBloc({
    required GetAdminUsers getUsers,
    required ban.BanUser banUser,
    required UnbanUser unbanUser,
    required ChangeUserRole changeRole,
  })  : _getUsers = getUsers,
        _banUser = banUser,
        _unbanUser = unbanUser,
        _changeRole = changeRole,
        super(const UserMgmtInitial()) {
    on<LoadAdminUsers>(_onLoad);
    on<BanUserEvent>(_onBan);
    on<UnbanUserEvent>(_onUnban);
    on<ChangeUserRoleEvent>(_onChangeRole);
  }

  UserMgmtLoaded? get _currentLoaded =>
      state is UserMgmtLoaded ? state as UserMgmtLoaded : null;

  Future<void> _onLoad(
      LoadAdminUsers event, Emitter<UserMgmtState> emit) async {
    emit(const UserMgmtLoading());
    final result = await _getUsers(GetAdminUsersParams(
      query: event.query,
      role: event.role,
      isActive: event.isActive,
    ));
    result.fold(
      (f) => emit(UserMgmtError(f)),
      (p) => emit(UserMgmtLoaded(
        users: p.items,
        hasMore: p.hasMore,
        currentPage: p.page,
      )),
    );
  }

  Future<void> _onBan(BanUserEvent event, Emitter<UserMgmtState> emit) async {
    final current = _currentLoaded;
    emit(Banning(current?.users ?? []));
    final result = await _banUser(
        ban.BanUserParams(userId: event.userId, reason: event.reason));
    result.fold(
      (f) => emit(UserMgmtError(f)),
      (updated) {
        final updated2 = (current?.users ?? [])
            .map((u) => u.id == updated.id ? updated : u)
            .toList();
        emit(Banned(
          users: updated2,
          hasMore: current?.hasMore ?? false,
          currentPage: current?.currentPage ?? 1,
        ));
      },
    );
  }

  Future<void> _onUnban(
      UnbanUserEvent event, Emitter<UserMgmtState> emit) async {
    final current = _currentLoaded;
    emit(Banning(current?.users ?? []));
    final result = await _unbanUser(UnbanUserParams(userId: event.userId));
    result.fold(
      (f) => emit(UserMgmtError(f)),
      (updated) {
        final updated2 = (current?.users ?? [])
            .map((u) => u.id == updated.id ? updated : u)
            .toList();
        emit(Banned(
          users: updated2,
          hasMore: current?.hasMore ?? false,
          currentPage: current?.currentPage ?? 1,
        ));
      },
    );
  }

  Future<void> _onChangeRole(
      ChangeUserRoleEvent event, Emitter<UserMgmtState> emit) async {
    final current = _currentLoaded;
    emit(ChangingRole(current?.users ?? []));
    final result = await _changeRole(
        ChangeUserRoleParams(userId: event.userId, newRole: event.newRole));
    result.fold(
      (f) => emit(UserMgmtError(f)),
      (updated) {
        final updated2 = (current?.users ?? [])
            .map((u) => u.id == updated.id ? updated : u)
            .toList();
        emit(RoleChanged(
          users: updated2,
          hasMore: current?.hasMore ?? false,
          currentPage: current?.currentPage ?? 1,
        ));
      },
    );
  }
}
