import 'package:flutter/material.dart';
import 'package:kostify/pages/landingTransaction.dart';
import 'package:kostify/service/apiService.dart';
import 'package:kostify/utility/constant.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';

class MidtransService {
  static final MidtransService _instance = MidtransService._internal();
  late MidtransSDK _midtrans;
  final ApiService apiService = ApiService();

  factory MidtransService() {
    return _instance;
  }

  MidtransService._internal();

  Future<void> initMidtrans(BuildContext context) async {
    try {
      _midtrans = await MidtransSDK.init(
        config: MidtransConfig(
          clientKey: midtransClientKey,
          merchantBaseUrl: midtransMerchantBaseUrl,
          colorTheme: ColorTheme(
            colorPrimary: Colors.blueAccent,
            colorPrimaryDark: Colors.blue,
            colorSecondary: Colors.lightBlueAccent,
          ),
        ),
      );
      _midtrans.setUIKitCustomSetting(skipCustomerDetailsPages: true);

      _midtrans.setTransactionFinishedCallback((result) async {
        print(result.toJson());

        // ✅ Perbarui data user di SharedPreferences setelah transaksi selesai
        await apiService.getUserById();

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LandingTransaction()),
          );
        }
      });
    } catch (e) {
      print("Error Midtrans: $e");
    }
  }

  void startPayment(String snapToken) {
    try {
      _midtrans.startPaymentUiFlow(token: snapToken);
    } catch (e) {
      print("Error saat memulai pembayaran: $e");
    }
  }
}
