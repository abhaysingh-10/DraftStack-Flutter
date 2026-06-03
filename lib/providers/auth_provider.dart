import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/services/api_services.dart';

// 1. The Notifier Provider

class AuthNotifier extends Notifier<AuthState>{

  @override
  AuthState build(){
    return AuthState.initial();
  }

 //login action

 Future<void> login(String username,String password) async{
  state = AuthState.loading();

  final apiService = ref.watch(apiServiceProvider);
  final success = await apiService.login(username, password);

  if(success){
    state = AuthState.authenticated();
  }else{
    state = AuthState.error("Invalid Username and Password");
  }
 }

// logout  action

Future<void> logout() async{
  await ref.read(apiServiceProvider).logout();
  state = AuthState.unauthenticated();
}
}





enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated() =>
      AuthState(status: AuthStatus.authenticated);
  factory AuthState.unauthenticated() =>
      AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, errorMessage: message);
}
