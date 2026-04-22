import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';

class AppDependencies {
  AppDependencies() {
    _authLocalDataSource = AuthLocalDataSource();
    _authRemoteDataSource = AuthRemoteDataSource();
    _userRepository = UserRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      localDataSource: _authLocalDataSource,
    );
  }

  late final AuthLocalDataSource _authLocalDataSource;
  late final AuthRemoteDataSource _authRemoteDataSource;
  late final UserRepository _userRepository;

  AuthLocalDataSource get authLocalDataSource => _authLocalDataSource;

  AuthRemoteDataSource get authRemoteDataSource => _authRemoteDataSource;

  UserRepository get userRepository => _userRepository;

  LoginUser get loginUser => LoginUser(_userRepository);

  RegisterUser get registerUser => RegisterUser(_userRepository);

  GetCurrentUser get getCurrentUser => GetCurrentUser(_userRepository);

  LogoutUser get logoutUser => LogoutUser(_userRepository);
}
