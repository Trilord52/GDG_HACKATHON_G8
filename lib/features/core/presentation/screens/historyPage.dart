import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:safe_campus/features/core/presentation/widgets/historyPageContainer.dart';

class Historypage extends StatelessWidget {
  const Historypage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Historypagecontainer(
            image: null,
            name: "biniyam",
            detailes: "yesterday",
          ),
          Historypagecontainer(
            image: null,
            name: "John Doe",
            detailes: "1 week ago",
          ),
          Historypagecontainer(
            image: null,
            name: "Jane Smith",
            detailes: "1 month ago",
          ),
        ],
      ),
    );
  }
}
