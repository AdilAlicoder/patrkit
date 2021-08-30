import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:wakelock/wakelock.dart';
import 'package:parkit_app/model/app_user.dart';
import 'package:parkit_app/screens/Call_Ui/incomingcall.dart';
import 'package:parkit_app/screens/about_us/about_us.dart';
import 'package:parkit_app/screens/chatlist_screen/chatlist_screen.dart';
import 'package:parkit_app/screens/contact_page/contact_page.dart';
import 'package:parkit_app/screens/how_it_works/how_it_works.dart';
import 'package:parkit_app/screens/my_orders/my_orders.dart';
import 'package:parkit_app/screens/order_screen/order_screen.dart';
import 'package:parkit_app/screens/profile_screen/profile_screen.dart';
import 'package:parkit_app/screens/reported_users/reported_users.dart';
import 'package:parkit_app/screens/scan_screen/scan_screen.dart';
import 'package:parkit_app/screens/start_up/start_up.dart';
import 'package:parkit_app/screens/support_page/support_page.dart';
import 'package:parkit_app/utils/constants.dart';
import 'package:parkit_app/utils/size_config.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../timer.dart';


class HomeScreen extends StatefulWidget {
  int index;
  HomeScreen(this.index, {Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pageIndex = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String uid;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  PageController _pageController;
  var _textStyle = new TextStyle(fontSize: 0.0);
  bool isUserSignedIn = false;
  List<Widget> tabPages;
  //
  final _advancedDrawerController = AdvancedDrawerController();
   Future<void> currentuser() async {
    final User user = await auth.currentUser;
  _firebaseMessaging.getToken().then((token){
     Firestore.instance.collection('token').document(user.uid).setData({
          'token':token
        });
      }
  );
    
    
  }
   static const platform = const MethodChannel("matrix/notify");
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _pageIndex = widget.index;

    AppUser adminUser = new AppUser(userId: "yQJe6tgqR0ONBBx9lGzLViUBAlB2", email: "jpipayments@gmail.com" , fullName: "Admin", isAdmin: true);
    if(Constants.appUser.isAdmin)
    {
      tabPages = [
        MyOrders(),
        ScanScreen(),
      ];
    }
    else
    {
      tabPages = [
        OrderScreen(),
        ScanScreen(),
        ChatListScreen(),
        ProfileScreen(), 
      ];
    } 
    _pageController = PageController(initialPage: _pageIndex);
    currentuser();
    platform.setMethodCallHandler(nativeMethodCallHandler);
  }
  Future<dynamic> nativeMethodCallHandler(MethodCall methodCall) async {

      Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MHomePage()),
  );
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._pageIndex = page;
    });
  }

  void onTabTapped(int index) {
    setState(() {
      this._pageIndex = index;
    });
    this._pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
 
  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      openRatio: 0.5,
      backdropColor: Constants.appThemeColor,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      childDecoration: const BoxDecoration(
        // NOTICE: Uncomment if you want to add shadow behind the page.
        // Keep in mind that it may cause animation jerks.
        // boxShadow: <BoxShadow>[
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 0.0,
        //   ),
        // ],
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.appThemeColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.white
          ),
          leading: IconButton(
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (context, value, child) {
                return Icon(
                  value.visible ? Icons.clear : Icons.menu,
                );
              },
            ),
          ),
          title: Text(
            'JustParkIt',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize : SizeConfig.fontSize * 2.7,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white), 
              onPressed: (){
              
           
                AppUser.deleteUserAndOtherPreferences();
               Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => StartUp()),(Route<dynamic> route) => false,);
              }
            )
          ],
        ),
        backgroundColor: Colors.white,
        //drawer: homeDrawer(),
        body: tabPages[_pageIndex],
        bottomNavigationBar: bottomBar2(),
      ),
      drawer: SafeArea(
        child: Container(
          color: Constants.appThemeColor,
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: SizeConfig.safeBlockHorizontal * 35,
                  height: SizeConfig.safeBlockHorizontal * 35,
                  margin: const EdgeInsets.only(
                    top: 30.0,
                    bottom: 0.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/logo2.png',
                    fit: BoxFit.cover,
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 15),
                  child: Column(
                    children: [
                      if(Constants.appUser.isAdmin)
                      ListTile(
                        onTap: () {
                          Get.to(MyOrders());
                        },
                        leading: Icon(Icons.shopping_cart),
                        title: Text('View Orders'),
                      ), 

                      ListTile(
                        onTap: () {
                          Get.to(HowItWorks());
                        },
                        leading: Icon(Icons.info_outline),
                        title: Text('How it works'),
                      ),  

                      ListTile(
                        onTap: () {
                          Get.to(AboutUs());
                        },
                        leading: Icon(Icons.list_alt),
                        title: Text('About Us'),
                      ),               
                      ListTile(
                        onTap: () {
                          Share.share('Check out JustParkIt App \nhttps://justparkit.co.uk/');
                        },
                        leading: Icon(Icons.share),
                        title: Text('Share'),
                      ),
                    
                      if(!Constants.appUser.isAdmin)
                      ListTile(
                        onTap: () {
                          Get.to(ContactPage());
                        },
                        leading: Icon(Icons.contact_mail),
                        title: Text('Contact'),
                      ),
                      

                      ListTile(
                        onTap: () {
                          Get.to(SupportMessages());
                        },
                        leading: Icon(Icons.support_agent),
                        title: Text('Support'),
                      ),
                     
                      ListTile(
                        onTap: () {
                          AppUser.deleteUserAndOtherPreferences();
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => StartUp()),(Route<dynamic> route) => false,);
                        },
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                      ),
                    ],
                  ),
                ),
                
                //Spacer(),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 15.0
                    ),
                    child: Text(
                      'Terms of Service | Privacy Policy',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: SizeConfig.fontSize * 1.5
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  Widget bottomBar2(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 3,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: SalomonBottomBar(
        currentIndex: _pageIndex,
        onTap: onTabTapped,
        unselectedItemColor: Colors.grey,
        items: [
         
          /// Likes
          SalomonBottomBarItem(
            icon: Icon(Icons.shopping_cart),
            title: Text("Order"),
            selectedColor: Constants.appThemeColor,
          ),

          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.qr_code),
            title: Text("Scan"),
            selectedColor: Constants.appThemeColor,
          ),

          if(!Constants.appUser.isAdmin)
          /// Search
          SalomonBottomBarItem(
            icon: FaIcon(
              FontAwesomeIcons.solidComments,
            ),
            title: Text("Chats"),
            selectedColor: Constants.appThemeColor,
          ),

            /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: Constants.appThemeColor,
          ),
     
        ],
      ),
    );
  }
  Widget bottomBar() {
    return new BottomNavigationBar(
      currentIndex: _pageIndex,
      onTap: onTabTapped,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      iconSize: 30.0,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          title: Text(''),
          icon: Icon(
            Icons.home,
            color: Colors.grey,
          ),
          activeIcon: Icon(
            Icons.home,
            color: Constants.appThemeColor,
          ),
        ),
        BottomNavigationBarItem(
          title: Text(''),
          icon: Icon(
            Icons.account_circle,
            color: Colors.grey,
          ),
          activeIcon: Icon(
            Icons.account_circle,
            color: Constants.appThemeColor,
          ),
        ),
        BottomNavigationBarItem(
          title: Text(''),
          icon: Icon(
            Icons.favorite,
            color: Colors.grey,
          ),
          activeIcon: Icon(
            Icons.favorite,
            color: Constants.appThemeColor,
          ),
        ),
        BottomNavigationBarItem(
          title: Text(''),
          icon: FaIcon(
            FontAwesomeIcons.solidComments,
            color: Colors.grey
          ),
          activeIcon: FaIcon(
            FontAwesomeIcons.solidComments,
            color: Constants.appThemeColor,
          ),
        ),
        BottomNavigationBarItem(
          title: Text(''),
          icon: Icon(
            Icons.settings,
            color: Colors.grey
          ),
          activeIcon: Icon(
            Icons.settings,
            color: Constants.appThemeColor,
          ),
        ),
      ],
    );
  }
}
