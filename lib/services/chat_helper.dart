
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkit_app/model/app_user.dart';

class ChatDatabaseModel{
  
  getConversationMessages(String chatRoomId) async{
    return await FirebaseFirestore.instance.collection("ChatRoom").
      doc(chatRoomId).collection('chats')
      .orderBy('timestamp', descending: false)
      .snapshots();
  }

  sendConversationMessage(String chatRoomId, Map messageMap) async{
    FirebaseFirestore.instance.collection("ChatRoom").
    doc(chatRoomId).collection('chats').add(messageMap).then((_) async {
      print("success!");
    }).catchError((error) {
      print("Failed to update: $error");
    });
  }

  getUserChatRooms(String userId) async {
    return await FirebaseFirestore.instance.collection('ChatRoom').
    where('users', arrayContains: userId)
    .orderBy('lastMessageTimeStamp', descending: true)
    .snapshots();
  }

  getUserDetail(String userName) async {
    return await FirebaseFirestore.instance.collection('users').
    where('userName', isEqualTo: userName).snapshots();
  }

  Future deleteUserChat(String chatRoomId, AppUser reportedBy, AppUser reportedUser, String reason) async {
    try {
      dynamic result = await FirebaseFirestore.instance.collection("ChatRoom").
        doc(chatRoomId).delete().then((_) async {
        print("success!");
        sendBlockUserToAdmin(reportedBy, reportedUser, reason);
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return null;
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
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Error'] = "Error";
      finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
      return finalResponse;
    }
  }

  Future<dynamic> sendBlockUserToAdmin(AppUser reportedBy, AppUser reportedUser, String reason) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("reportedUsers").add({
      'reportedByUserId': reportedBy.userId,
      'reportedByUserName': reportedBy.userName,
      'reportedByFullName' : reportedBy.fullName,
      'reportedByPhoneNumber': reportedBy.phoneNumber,
      'reportedUserId': reportedUser.userId,
      'reportedUserName': reportedUser.userName,
      'reportedFullName' : reportedUser.fullName,
      'reportedPhoneNumber': reportedUser.phoneNumber,
      'reportReason' : reason,
      'reportedTime' : FieldValue.serverTimestamp(),
    }).then((_) async {
      print("success!");
    }).catchError((error) {
      print("Failed to add user: $error");
      return null;
    });
  }

}