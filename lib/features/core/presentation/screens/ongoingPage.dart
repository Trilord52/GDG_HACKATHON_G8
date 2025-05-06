import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:safe_campus/features/core/presentation/widgets/ongoingContainer.dart';

class Ongoingpage extends StatelessWidget {
  const Ongoingpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        
        children: [
          Ongoingcontainer(image: null, name: "Biniyam", detailes: "1 minute ago"),
          Ongoingcontainer(image: null, name: "Jane Smith", detailes: "10 minute ago"),
          Ongoingcontainer(image: null, name: "John Doe", detailes: "1 hour ago"),
        ],
      )
    );
  }
}