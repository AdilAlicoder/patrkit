import 'dart:io';
import 'package:path/path.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parkit_app/services/app_controller.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';

class ProfileScreen extends StatefulWidget {

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final cryptor = new PlatformStringCryptor();
  TextEditingController userName = new TextEditingController(text: Constants.appUser.userName);
  TextEditingController fullName = new TextEditingController(text: Constants.appUser.fullName);
  TextEditingController phoneNumber = new TextEditingController(text: Constants.appUser.phoneNumber);
  TextEditingController email = new TextEditingController(text: Constants.appUser.email);
  bool isLoading = false;
  //IMAGE
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File _image;
  final picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
  }

  void pickFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if(pickedFile != null)
    {
      _image = File(pickedFile.path);
      setState(() {});
    }
  }


  void updateProfilePressed() async {
    if (userName.text.isEmpty)
      Constants.showDialog("Please enter user name");
    else if (fullName.text.isEmpty)
      Constants.showDialog("Please enter full name");
    else if (phoneNumber.text.isEmpty)
      Constants.showDialog("Please enter phone number");
    else
      updateProfile();
    //else if(Constants.appUser.phoneNumber != phoneNumber.text)
    // showNumberChangeConfirmationView();
  }

/*
  void showNumberChangeConfirmationView(){
     Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        title: Text('Phone Number Confirmation'),
        content: Text('Your personal QR code is linked with your number, so changing number will generate a new code and previous one will be invalidated. Are your sure you want to update your phone number ?'),
        actions: [
          FlatButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel')
          ),
          FlatButton(
            onPressed: () {
              updateProfile();
              Get.back();
            },
            child: Text('Yes')
          )
        ],
      )
    );
  }
*/  

  Future<String> uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + basename(_image.path);
    final StorageReference storageReference = _storage.ref().child("user_pictures").child(Constants.appUser.userId).child(fileName);
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    return await storageReference.getDownloadURL();
  }

  Future<void> updateProfile() async {
    setState(() => isLoading = true);  
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black,);
    String uploadImageUrl  = "";
    if(_image != null)
      uploadImageUrl = await uploadFile();
    dynamic result = await AppController().updateUserProfile(userName.text, fullName.text, phoneNumber.text, uploadImageUrl);
    EasyLoading.dismiss();
    setState(() => isLoading = false); 
    if (result['Status'] == "Success") 
    {
      Constants.appUser.userName = userName.text;
      Constants.appUser.fullName =  fullName.text;
      Constants.appUser.phoneNumber = phoneNumber.text;
      Constants.appUser.userProfilePic = uploadImageUrl;
      await Constants.appUser.saveUserDetails();      
      Constants.showDialog('Your profile has been successfully updated');
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 8, right: SizeConfig.blockSizeHorizontal * 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
                    height: SizeConfig.blockSizeVertical * 5,
                    width: SizeConfig.blockSizeVertical * 5,
                  ),
                  userImage(),
                  Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
                    height: SizeConfig.blockSizeVertical * 5,
                    child: BarcodeWidget(
                      barcode: Barcode.qrCode(), // Barcode type and settings
                      data: '${Constants.appUser.uniquePhoneQrCode}', // Content
                      width: SizeConfig.blockSizeVertical * 5,
                      height: SizeConfig.blockSizeVertical * 5,
                    ),
                  ),
                ],
              ),

               Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: 10),                   
                  child: Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: SizeConfig.fontSize * 1.6
                    ),
                  ),
                ),
                Container(
                  height: SizeConfig.blockSizeVertical * 7,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: TextField(
                      style: TextStyle(fontSize: SizeConfig.fontSize * 2),
                      controller: userName,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        hintText: 'Enter username',
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                        fillColor: Colors.grey[100],
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: 10),                   
                  child: Text(
                    'Full Name',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: SizeConfig.fontSize * 1.6
                    ),
                  ),
                ),
                Container(
                  height: SizeConfig.blockSizeVertical * 7,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: TextField(
                      style: TextStyle(fontSize: SizeConfig.fontSize * 2),
                      controller: fullName,
                      inputFormatters: [WhitelistingTextInputFormatter(RegExp("[a-zA-Z \u00c0-\u017e]"))],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        hintText: 'Enter full name',
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                        fillColor: Colors.grey[100],
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: 10),                   
                  child: Text(
                    'Mobile Number',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: SizeConfig.fontSize * 1.6
                    ),
                  ),
                ),
                Container(
                  height: SizeConfig.blockSizeVertical * 7,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: TextField(
                      style: TextStyle(fontSize: SizeConfig.fontSize * 2),
                      controller: phoneNumber,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(15)],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        hintText: 'Enter mobile number',
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                        fillColor: Colors.grey[100],
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: 10),                   
                  child: Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: SizeConfig.fontSize * 1.6
                    ),
                  ),
                ),
                Container(
                  height: SizeConfig.blockSizeVertical * 7,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: TextField(
                      style: TextStyle(fontSize: SizeConfig.fontSize * 2, color: Colors.grey),
                      controller: email,
                      readOnly: true,
                      enabled:  false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        hintText: 'Enter email',
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                        fillColor: Colors.grey[100],
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: updateProfilePressed,
                  child: Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
                    height: SizeConfig.blockSizeVertical * 7,
                    decoration: BoxDecoration(
                      color: Constants.appThemeColor,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child: Text(
                        'UPDATE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize : SizeConfig.fontSize * 1.8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }

  Widget userImage(){
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
           if(Constants.appUser.userProfilePic.isEmpty && _image == null)
            CircleAvatar(
              radius: SizeConfig.blockSizeVertical *8,
              backgroundImage: AssetImage('assets/user_bg.png'),
              child: Container(
                width: SizeConfig.blockSizeVertical *20,
                //color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    
                    GestureDetector(
                      child: Icon(Icons.edit, color: Colors.black, size: 28,),
                      onTap: (){
                        pickFromGallery();
                      },
                    ),
                    
                  ],
                ),
              ),
            ),

            if(Constants.appUser.userProfilePic.isNotEmpty || _image != null)
            CircleAvatar(
              radius: SizeConfig.blockSizeVertical * 8,
              backgroundImage: (_image == null) ? CachedNetworkImageProvider(Constants.appUser.userProfilePic) : FileImage(_image),
              child: Container(
                width: SizeConfig.blockSizeVertical *20,
                //color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [                 
                    GestureDetector(
                      child: Icon(Icons.edit, color: Colors.black, size: 28,),
                      onTap: (){
                        pickFromGallery();
                      },
                    ),    
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}