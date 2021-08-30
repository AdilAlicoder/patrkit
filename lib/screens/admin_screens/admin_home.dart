import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:parkit_app/model/app_user.dart';
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

class AdminHomeScreen extends StatefulWidget {
  int index;
  AdminHomeScreen(this.index, {Key key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _pageIndex = 0;
  PageController _pageController;
  var _textStyle = new TextStyle(fontSize: 0.0);
  bool isUserSignedIn = false;
  List<Widget> tabPages;
  //
  final _advancedDrawerController = AdvancedDrawerController();

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.index;
    tabPages = [
      MyOrders(),
      SupportMessages(),
    ];
    _pageController = PageController(initialPage: _pageIndex);
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
                     
                      ListTile(
                        onTap: () {
                          Get.to(ReportedUsers());
                        },
                        leading: Icon(Icons.report),
                        title: Text('Reported User'),
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
      padding: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 10, right: SizeConfig.blockSizeHorizontal * 10),
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
            icon: Icon(Icons.support_agent),
            title: Text("Support"),
            selectedColor: Constants.appThemeColor,
          ),
     
        ],
      ),
    );
  }
}
