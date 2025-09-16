import 'package:flutter/foundation.dart';
import '../repositories/wallet_repository.dart';

class WalletProvider with ChangeNotifier {
  final WalletRepository _repo;
  List<dynamic> _wallets = [];
  bool _loading = false;

  WalletProvider(this._repo);

  List<dynamic> get wallets => _wallets;
  bool get loading => _loading;

  Future<void> loadWallets({bool refresh = false}) async {
    _loading = true;
    notifyListeners();

    _wallets = await _repo.getWallets(forceRefresh: refresh);

    _loading = false;
    notifyListeners();
  }
}
