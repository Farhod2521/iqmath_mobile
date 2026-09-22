
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo{
  @override
  // TODO: implement isConnected
  Future<bool> get isConnected => Future.value(true);
  // final InternetConnectionCheckerPlus internetConnectionCheckerPlus;

  // NetworkInfoImpl(this.internetConnectionCheckerPlus);

  // @override
  // Future<bool> get isConnected => internetConnectionCheckerPlus.hasConnection;
}