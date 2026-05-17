import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/table_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/table_remote_datasource.dart';
import '../../data/repositories/table_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/table_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/get_selected_table.dart';
import '../../domain/usecases/get_tables.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/reserve_table.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/watch_tables.dart';

class AppDependencies {
  AppDependencies() {
    _authLocalDataSource = AuthLocalDataSource();
    _authRemoteDataSource = AuthRemoteDataSource();
    _tableLocalDataSource = TableLocalDataSource();
    _tableRemoteDataSource = TableRemoteDataSource();
    _userRepository = UserRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      localDataSource: _authLocalDataSource,
    );
    _tableRepository = TableRepositoryImpl(
      remoteDataSource: _tableRemoteDataSource,
      localDataSource: _tableLocalDataSource,
    );
  }

  late final AuthLocalDataSource _authLocalDataSource;
  late final AuthRemoteDataSource _authRemoteDataSource;
  late final TableLocalDataSource _tableLocalDataSource;
  late final TableRemoteDataSource _tableRemoteDataSource;
  late final UserRepository _userRepository;
  late final TableRepository _tableRepository;

  AuthLocalDataSource get authLocalDataSource => _authLocalDataSource;

  AuthRemoteDataSource get authRemoteDataSource => _authRemoteDataSource;

  TableLocalDataSource get tableLocalDataSource => _tableLocalDataSource;

  TableRemoteDataSource get tableRemoteDataSource => _tableRemoteDataSource;

  UserRepository get userRepository => _userRepository;

  TableRepository get tableRepository => _tableRepository;

  LoginUser get loginUser => LoginUser(_userRepository);

  RegisterUser get registerUser => RegisterUser(_userRepository);

  GetCurrentUser get getCurrentUser => GetCurrentUser(_userRepository);

  LogoutUser get logoutUser => LogoutUser(_userRepository);

  UpdateUserProfile get updateUserProfile => UpdateUserProfile(_userRepository);

  GetTables get getTables => GetTables(_tableRepository);

  WatchTables get watchTables => WatchTables(_tableRepository);

  ReserveTable get reserveTable => ReserveTable(_tableRepository);

  GetSelectedTable get getSelectedTable => GetSelectedTable(_tableRepository);
}
