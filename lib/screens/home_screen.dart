import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:flutter/material.dart";
import "package:social_media/constants/colors.dart";
import "package:social_media/screens/chat_list_screen.dart";
import "package:social_media/screens/home_data_screen.dart";
import "package:social_media/screens/post_creation_screen.dart";
import "package:social_media/screens/profile_screen.dart";
import "package:social_media/screens/search_screen.dart";

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedItemIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomeDataScreen(),
    ChatListScreen(),
    PostCreation(),
    // const SearchScreen(),
    ProfileScreen(
      toggler: false,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(selectedItemIndex),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: shasTransparentBackground,
        color: shasBarColor,
        onTap: (index) {
          setState(() {
            selectedItemIndex = index;
          });
        },
        items: [
          Icon(
            Icons.home,
            color: Colors.white,
          ),
          Icon(
            Icons.wechat_sharp,
            color: Colors.white,
          ),
          Icon(
            Icons.add_a_photo,
            color: Colors.white,
          ),
          // Icon(
          //   Icons.search,
          //   color: Colors.white,
          // ),
          Icon(
            Icons.person_2_outlined,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
