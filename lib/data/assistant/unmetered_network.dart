import 'package:connectivity_plus/connectivity_plus.dart';

/// True on Wi-Fi or Ethernet. Cellular and an unknown network are false,
/// so a model download does not start on a metered connection.
Future<bool> isUnmeteredNetwork([Connectivity? connectivity]) async {
  final results = await (connectivity ?? Connectivity()).checkConnectivity();
  return results.contains(ConnectivityResult.wifi) ||
      results.contains(ConnectivityResult.ethernet);
}
