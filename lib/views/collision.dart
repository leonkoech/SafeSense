import 'package:flutter/material.dart';
// import 'package:swipe_aid/views/car.dart';
// import "../components/SideNav.dart";

// import 'package:flutter_blue/flutter_blue.dart';
class Collision extends StatefulWidget {
  const Collision({super.key});
  

  @override
  State<Collision> createState() => _CollisionState();
}

class _CollisionState extends State<Collision> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF1B1B1E),
        // drawer: SideNavigation,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title:  const Text(
              "Collision Summary",
              style: TextStyle(color: Color(0xFFFBFFFE)),
            ),

        ),
         floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your action here
            //  Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => CarMode()),
            //   );
          },
          child: Icon(Icons.arrow_left), // You can change the icon
          backgroundColor: Colors.blue, // You can change the background color
        ),
        
        );
        
  }
}
