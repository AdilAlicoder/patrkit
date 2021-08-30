import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  String userId = "";
  String userName = "";
  String fullName = "";
  String phoneNumber = "";
  String email = "";
  String password = "";
  String oneSignalUserId = "";
  bool isAdmin = false;
  bool isBlocked = false;
  String uniquePhoneQrCode = "";
  String encryptionKey = "";
  String userProfilePic = "";
  AppUser({this.userId, this.userName, this.fullName, this.phoneNumber, this.email, this.oneSignalUserId ,this.isAdmin, this.uniquePhoneQrCode, this.encryptionKey, this.userProfilePic, this.isBlocked});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    AppUser user = new AppUser(
      userId: json['userId'],
      userName : json['userName'],
      fullName : json['fullName'],
      phoneNumber : json['phoneNumber'],
      isAdmin : json['isAdmin'],
      email : json['email'],
      uniquePhoneQrCode : json['uniquePhoneQrCode'],
      encryptionKey : json['encryptionKey'],
      oneSignalUserId : (json['oneSignalUserId'] == null) ? "" : json['oneSignalUserId'],
      userProfilePic : (json['userProfilePic'] == null) ? "" : json['userProfilePic'],
      isBlocked: (json['isBlocked'] == null) ? false : json['isBlocked'],
   );
    return user;
  }

  Future saveUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("UserId", this.userId);
    prefs.setString("UserName", this.userName);
    prefs.setString("UserFullName", this.fullName);
    prefs.setString("UserPhoneNumber", this.phoneNumber);
    prefs.setBool("UserIsAdmin", this.isAdmin);
    prefs.setString("UserEmail", this.email);
    prefs.setString("UserPassword", this.password);
    prefs.setString("OneSignalUserId", this.oneSignalUserId);
    prefs.setString("UniquePhoneQrCode", this.uniquePhoneQrCode);
    prefs.setString("EncryptionKey", this.encryptionKey);
    prefs.setString("UserProfilePic", this.userProfilePic);    
    prefs.setBool("UserIsBlocked", this.isBlocked);    

  }

  static Future<AppUser> getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AppUser user = new AppUser();
    user.userId = prefs.getString("UserId") ?? "";
    user.userName = prefs.getString("UserName") ?? "";
    user.fullName = prefs.getString("UserFullName") ?? "";
    user.phoneNumber = prefs.getString("UserPhoneNumber") ?? "";
    user.isAdmin = prefs.getBool("UserIsAdmin") ?? false;
    user.isBlocked = prefs.getBool("UserIsBlocked") ?? false;
    user.email = prefs.getString("UserEmail") ?? "";
    user.password = prefs.getString("UserPassword") ?? "";
    user.oneSignalUserId = prefs.getString("OneSignalUserId") ?? "";
    user.uniquePhoneQrCode = prefs.getString("UniquePhoneQrCode") ?? "";
    user.encryptionKey = prefs.getString("EncryptionKey") ?? "";
    user.userProfilePic = prefs.getString("UserProfilePic") ?? "";
    return user;
  }

  static Future deleteUserAndOtherPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    prefs.setBool("IsFirstTimeLaunched", false);
  }

  static Future saveOneSignalUserID(String oneSignalId)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("OneSignalUserId", oneSignalId);
  }

  static Future getOneSignalUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("OneSignalUserId") ?? "";
  }
  
  ///*********FIRESTORE METHODS***********\\\\
  Future<dynamic> signUpUser(AppUser user) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("users").doc(user.userId).set({
      'userID': user.userId,
      'userName': user.userName,
      'fullName' : user.fullName,
      'phoneNumber': user.phoneNumber,
      'email': user.email,
      'oneSignalUserId' : "",
      'isAdmin' : false,
      'uniquePhoneQrCode' : user.uniquePhoneQrCode,
      'encryptionKey' : user.encryptionKey,
      "userProfilePic" : user.userProfilePic,
      "isBlocked" : user.isBlocked
    }).then((_) async {
      print("success!");
      await user.saveUserDetails();
      return user;
    }).catchError((error) {
      print("Failed to add user: $error");
      return null;
    });
  }

  static Future<dynamic> getLoggedInUserDetail(AppUser user) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .doc(user.userId)
    .get()
    .then((value) async {
      if(value.exists)
      {
        AppUser userTemp = AppUser.fromJson(value.data());
        userTemp.userId = user.userId;
        userTemp.password = user.password;
        await userTemp.saveUserDetails();
        return userTemp;
      }
      else
      {
        //Signup facebook user as first time login
         AppUser userTemp = await AppUser().signUpUser(user);
         return userTemp;
      }
    }).catchError((error) {
      print("Failed to add user: $error");
      return null;
    });
  }

  static Future<dynamic> getUserDetailByUserId(String userId) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .where('userID', isEqualTo: userId)
    .get()
    .then((value) async {
      AppUser userTemp = AppUser.fromJson(value.docs[0].data());
      userTemp.userId = userId;
      return userTemp;
    }).catchError((error) {
      print("Failed to add user: $error");
      return null;
    });
  }

}
