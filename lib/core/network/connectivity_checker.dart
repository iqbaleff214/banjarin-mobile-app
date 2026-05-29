import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityChecker {
  Stream<bool> get onlineStatus;
  Future<bool> isOnline();
}

class ConnectivityCheckerImpl implements ConnectivityChecker {
  final Connectivity _connectivity;

  ConnectivityCheckerImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Stream<bool> get onlineStatus => _connectivity.onConnectivityChanged.map(
        (results) =>
            results.any((r) => r != ConnectivityResult.none),
      );

  @override
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
