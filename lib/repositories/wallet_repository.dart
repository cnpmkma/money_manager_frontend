import '../services/wallet_service.dart';

class WalletRepository {
  List<dynamic>? _cache;
  DateTime? _lastFetch;

  Future<List<dynamic>> getWallets({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cache != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < const Duration(minutes: 5)) {
      return _cache!;
    }

    final wallets = await WalletService.getWallets();
    _cache = wallets;
    _lastFetch = DateTime.now();
    return wallets;
  }
}
