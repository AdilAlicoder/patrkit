import 'dart:convert';
import 'package:parkit_app/services/app_controller.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart';


class StripeTransactionResponse{
  String message;
  bool success;
  StripeTransactionResponse({this.message, this.success});
}

class StripeService{
  static String apiBaseUrl = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '$apiBaseUrl/payment_intents';
  static String secret = 'sk_test_51J8OkxLV2BOBq83bJkEimMTJB04DCIdykwOGGhhREV5Ly1P70oGHYxe5E4DuzeqQBJQaO51chEUnkmN44vS4gakC00tsTMGDEw';
  static Map<String, String> headers;

  static init(){
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: "pk_test_51J8OkxLV2BOBq83bLr72SOi98UzMAzKHSG1lPYXlwHgywkmQuaktTkVnOhMNWKJk1dcizd4kcFIoenzriEcemHj400KfruOE9W",
        merchantId: "Test",
        androidPayMode: 'test'
      )
    );
  } 

  static Future payWithNewCard({String amount, String currency, String fullName, String address, String city, String postCode, String qrStickerColor}) async
  {
    try{
      setStripeHeaders();
      var paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest()
      );
      print(jsonEncode(paymentMethod));
      //Call create intent code to generate cleint secret
      var paymentIntent = await StripeService.createPaymentIntent(
        amount,
        currency,
        fullName,
        address,
        city,
        postCode,
        qrStickerColor
      );

      var response = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id,
        ),
      );

      var result = await createOrder(fullName, address, city, postCode, qrStickerColor); 
      return result;
    }
    catch(e)
    {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      if(e.message == 'cancelled')
       finalResponse['ErrorMessage'] = 'Cancelled by user';
      else
        finalResponse['ErrorMessage'] = e.message;

      return finalResponse;
    }
  }


  static Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency, String fullName, String address, String city, String postCode, String qrStickerColor)async{

    try{
      Map <String, dynamic> body = {
        'amount' : amount,
        'currency' : currency,
        'payment_method_types[]' : 'card',
        'metadata[user_id]' : '${Constants.appUser.userId}',
        'metadata[user_name]' : '${Constants.appUser.userName}',
        'metadata[fullName]' : '$fullName',
        'metadata[address]' : '$address',
        'metadata[city]' : '$city',
        'metadata[postCode]' : '$postCode',
        'metadata[qrStickerColor]' : '$qrStickerColor'
      };

      var response = await post(
        StripeService.paymentApiUrl,
        body: body,
        headers: StripeService.headers,
      );
      return jsonDecode(response.body);
    } 
    catch(e){
      print('err charging user :  ${e.toString()}');
    }
  }

  //CREATE ORDER
  static Future createOrder(String fullName, String streetAddress, String city, String postCode, String qrStickerColor) async {
    try {
      dynamic result = await AppController().orderQrCodeNow(fullName, streetAddress, city, postCode, qrStickerColor);
      return result;
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  static void setStripeHeaders() {
     headers = {
      'Authorization' : 'Bearer $secret',
      'Content-Type' : 'application/x-www-form-urlencoded'
    };
  }
  static Map setUpFailure() {
    Map finalResponse = <dynamic, dynamic>{}; //empty map
    finalResponse['Status'] = "Error";
    finalResponse['ErrorMessage'] = "Cannot connect to server. Please try again later";
    return finalResponse;
  }
}