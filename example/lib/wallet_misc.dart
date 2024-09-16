import 'package:hd_wallet_kit/hd_wallet_kit.dart';

class WalletUtil {
  const WalletUtil();

  static HDWallet createWallet([List<String>? mnemonic]) {
    mnemonic ??= Mnemonic.generate();
    final seed = Mnemonic.toSeed(mnemonic);
    return HDWallet.fromSeed(seed: seed);
  }
}

class TGNBill {
  final double value;
  final String owner;

  TGNBill(this.value, this.owner);
}

enum Coin {
  BTC(0),
  TGN(765);

  final int value;

  const Coin(this.value);
  int get coinType => value;
}
