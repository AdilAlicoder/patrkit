import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:http/http.dart';
import 'package:parkit_app/model/app_user.dart';
import 'package:parkit_app/utils/constants.dart';

class AppController {

  final firestoreInstance = FirebaseFirestore.instance;

  //SIGN UP
  Future signUpUser(String userName, String fullName, String phoneNumber, String email, String password, String encryptionKey) async {
    try {
      final cryptor = new PlatformStringCryptor();
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print(userCredential.user.uid);
      String encryptedUniqueCode = await cryptor.encrypt("${userCredential.user.uid}", Constants.encryptionKey);
      encryptedUniqueCode  = "JustParkit*"+ encryptedUniqueCode;
    
      AppUser newUser = new AppUser(
        userId: userCredential.user.uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        userName: userName,
        isAdmin: false,
        oneSignalUserId: '',
        uniquePhoneQrCode: encryptedUniqueCode,
        encryptionKey: encryptionKey,
        isBlocked: false,
      );
      dynamic resultUser = await newUser.signUpUser(newUser);
      if (resultUser != null) 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['User'] = resultUser;
        Constants.isUserSignedIn = true;
        Constants.appUser = resultUser;
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] ="User cannot signup at this time. Try again later";
        return finalResponse;
      }
    } on FirebaseAuthException catch (e) {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        finalResponse['ErrorMessage'] = "No user found for that email";
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        finalResponse['ErrorMessage'] = "Wrong password provided for that user";
      }
      else{
        finalResponse['ErrorMessage'] = e.message;
      }
      return finalResponse;
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  //SIGN IN
  Future signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      print(userCredential.user.uid);
       AppUser newUser = new AppUser(
        userId: userCredential.user.uid,
        email: email,
        phoneNumber: '',
        userName: '',
        oneSignalUserId: '',
        isAdmin: false,
        isBlocked: false,
      );
      dynamic resultUser = await AppUser.getLoggedInUserDetail(newUser);
      if (resultUser != null)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['User'] = resultUser;
        Constants.appUser = resultUser;
        return finalResponse;
      }
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "User cannot login at this time. Try again later";
        return finalResponse;
      }
    } on FirebaseAuthException catch (e) {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        finalResponse['ErrorMessage'] = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        finalResponse['ErrorMessage'] =
            "The account already exists for that email";
      } else {
        finalResponse['ErrorMessage'] = e.code;
      }
      return finalResponse;
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }
  
  //FORGOT PASSWORD
  Future forgotPassword(String email) async {
    try {
      String result = "";
      await FirebaseAuth.instance
      .sendPasswordResetEmail(email: email).then((_) async {
        result = "Success";
      }).catchError((error) {
        result = error.toString();
        print("Failed emailed : $error");
      });

      if (result == "Success") {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } else {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = result;
        return finalResponse;
      }
    } on FirebaseAuthException catch (e) {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      finalResponse['ErrorMessage'] = e.code;
      return finalResponse;
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }
  
  //UPDATE PROFILE PIC
  Future<dynamic> updateUserProfile(String userName, String fullName, String phoneNumber, String profileImageUrl) async {
    AppUser user = await AppUser.getUserDetail();
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .doc(Constants.appUser.userId)
    .update({
      'userName': user.userName,
      'fullName' : user.fullName,
      'phoneNumber': user.phoneNumber,
      'userProfilePic' : profileImageUrl,
     }).then((_) async {
      print("success!");
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      return finalResponse;
    }).catchError((error) {
      print("Failed to update: $error");
      return setUpFailure();
    });
  }
  
  Future<dynamic> orderQrCodeNow(String fullName, String streetAddress, String city, String postCode, String qrStickerColor) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("orders").add({
      'fullName': fullName,
      'streetAddress' : streetAddress,
      'city': city,
      'postCode' : postCode,
      'phoneNumber' : Constants.appUser.phoneNumber,   
      'orderStatus' : 'Pending',
      'userEmail' : Constants.appUser.email,
      'userId' : Constants.appUser.userId,
      'qrStickerColor' : qrStickerColor,
     }).then((_) async {
      print("success!");
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      return finalResponse;
    }).catchError((error) {
      print("Failed to update: $error");
      return setUpFailure();
    });
  }

  Future<dynamic> updateOrderState( Map order , String orderNewStatus) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("orders").doc(order['orderId']).update({
      'orderStatus' : '$orderNewStatus',
     }).then((_) async {
      print("success!");
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      return finalResponse;
    }).catchError((error) {
      print("Failed to update: $error");
      return setUpFailure();
    });
  }
  
  Future getOrdersList(List ordersList) async {
    try {
      dynamic result = await firestoreInstance.collection("orders").get().then((value) {
      value.docs.forEach((result) 
      {
          print(result.data);
          Map orderData = result.data();
          orderData['orderId'] = result.id;
          ordersList.add(orderData);
        });
        return true;
      });

      if (result)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      }
      else
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }
  
  //UPDATE PROFILE PIC
  Future<dynamic> updateOneSignalUserID(String oneSignalUserID) async {
    AppUser user = await AppUser.getUserDetail();
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .doc(Constants.appUser.userId)
    .update({
      "oneSignalUserId": oneSignalUserID
     }).then((_) async {
      print("success!");
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      return finalResponse;
    }).catchError((error) {
      print("Failed to update: $error");
      return setUpFailure();
    });
  }
  
  Future sendChatNotificationToUser(AppUser user) async {
    try {
      Map<String, String> requestHeaders = {
        "Content-type": "application/json", 
        "Authorization" : "Basic YjEyNTU4MTEtZjAzZi00MzBiLWExM2UtMjgzOTAzYzAyNTVm"
      };
      
      var url = 'https://onesignal.com/api/v1/notifications';
      String json = '{ "include_player_ids" : ["${user.oneSignalUserId}"] ,"app_id" : "${Constants.oneSignalId}", "small_icon" : "app_icon", "headings" : {"en" : "New Message"},"contents" : {"en" : "You have received a new message"}}';
      Response response = await post(url, headers: requestHeaders, body: json);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
     
      if (response.statusCode == 200) {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } else {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot set tag mode at this time. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  //CONTACT PAGE
  Future<dynamic> submitContactUsQuery(String subject, String message) async {

    Map messageDetail = {
      'userId' : Constants.appUser.userId,
      'messageText' : message,
    };

    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("contact_us").add({
      'userFullName': Constants.appUser.fullName,
      'userEmail': Constants.appUser.email,
      'userPhoneNumber' : Constants.appUser.phoneNumber, 
      'userId' : Constants.appUser.userId,
      'subject': subject,
      'message' : message,
      'messageTimeStamp' : FieldValue.serverTimestamp(),  
      'messagesList' : [messageDetail]
     }).then((_) async {
      print("success!");
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      return finalResponse;
    }).catchError((error) {
      print("Failed to update: $error");
      return setUpFailure();
    });
  }

  //CONTACT PAGE
  Future<dynamic> sendSupportMessage(Map ticketDetail, Map messageDetail) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("contact_us").doc(ticketDetail['contact_Id']).update({
      'messageTimeStamp' : FieldValue.serverTimestamp(),  
      "messagesList": FieldValue.arrayUnion([messageDetail])
     }).then((_) async {
      print("success!");
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      return finalResponse;
    }).catchError((error) {
      print("Failed to update: $error");
      return setUpFailure();
    });
  }

  Future getMySupportTickets(List supportTicketsList) async {
    try {
      dynamic result = await firestoreInstance.collection("contact_us").get().then((value) {
      value.docs.forEach((result) 
      {
          print(result.data);
          Map orderData = result.data();
          orderData['contact_Id'] = result.id;
          if(Constants.appUser.isAdmin) 
            supportTicketsList.add(orderData);
          else if(Constants.appUser.userId == orderData['userId'])
            supportTicketsList.add(orderData);
          else
            print('Not my contact message');
        });
        return true;
      });

      if (result)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      }
      else
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future<dynamic> getSupportDetail(Map ticketDetail) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("contact_us").doc(ticketDetail['contact_Id']).get()
    .then((value) async {
      print("success!");
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      finalResponse['Data'] = value.data();
      return finalResponse;
    }).catchError((error) {
      print("Failed to update: $error");
      return setUpFailure();
    });
  }

  Future sendSupportMessageNotification(Map supportTicketDetail) async {
    try {
      Map<String, String> requestHeaders = {
        "Content-type": "application/json", 
        "Authorization" : "Basic YjEyNTU4MTEtZjAzZi00MzBiLWExM2UtMjgzOTAzYzAyNTVm"
      };

      AppUser userToSend;
      if(Constants.appUser.isAdmin)
        userToSend = await AppUser.getUserDetailByUserId(supportTicketDetail['userId']); //get user
      else
        userToSend = await AppUser.getUserDetailByUserId('yQJe6tgqR0ONBBx9lGzLViUBAlB2'); //get admin

      var url = 'https://onesignal.com/api/v1/notifications';
      String json = '{ "include_player_ids" : ["${userToSend.oneSignalUserId}"] ,"app_id" : "${Constants.oneSignalId}", "small_icon" : "app_icon", "headings" : {"en" : "New Message"},"contents" : {"en" : "Support message for ${supportTicketDetail['subject']}"}}';
      Response response = await post(url, headers: requestHeaders, body: json);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
     
      if (response.statusCode == 200) {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } else {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot set tag mode at this time. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

   Future getAllReportedUsersList(List usersList) async {
    try {
      dynamic result = await firestoreInstance.collection("reportedUsers").get().then((value) {
      value.docs.forEach((result) 
      {
          print(result.data);
          Map orderData = result.data();
          orderData['reportedUsers_docID'] = result.id;
          usersList.add(orderData);
        });
        return true;
      });

      if (result)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      }
      else
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

   //UPDATE PROFILE PIC
  Future<dynamic> blockUser(String userId) async {
    AppUser user = await AppUser.getUserDetail();
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .doc(userId)
    .update({
      'isBlocked': true,
     }).then((_) async {
      print("success!");
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      return finalResponse;
    }).catchError((error) {
      print("Failed to update: $error");
      return setUpFailure();
    });
  }

  Map setUpFailure() {
    Map finalResponse = <dynamic, dynamic>{}; //empty map
    finalResponse['Status'] = "Error";
    finalResponse['ErrorMessage'] = "Please try again later. Server is busy.";
    return finalResponse;
  }
}
