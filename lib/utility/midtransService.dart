// import 'package:midtrans_sdk/midtrans_sdk.dart';

// class PaymentService {
//   late MidtransSDK midtrans;

//   Future<void> initMidtrans() async {
//     midtrans = await MidtransSDK.init(
//       clientKey: "YOUR_CLIENT_KEY",
//       merchantBaseUrl: "https://your-server.com/",
//       environment: MidtransEnvironment.sandbox, // Ubah ke production jika sudah live
//     );
//     midtrans.setUIKitCustomSetting(
//       skipCustomerDetailsPages: true, // Langsung ke pembayaran
//     );
//   }

//   void pay(String transactionToken) {
//     midtrans.startPaymentUiFlow(
//       token: transactionToken,
//       onSuccess: (result) {
//         print("Pembayaran berhasil: ${result.transactionId}");
//       },
//       onPending: (result) {
//         print("Pembayaran pending: ${result.transactionId}");
//       },
//       onError: (result) {
//         print("Pembayaran gagal: ${result.message}");
//       },
//     );
//   }
// }
