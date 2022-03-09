import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FabImageButton extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final void Function() callback;
  FabImageButton({required this.imageUrl, required this.width, required this.height, required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            width : width,
            height: height,
            decoration: BoxDecoration(
              color: Color(0x00FFFFFF),
              image: DecorationImage(
                  image:AssetImage(imageUrl),
                  fit:BoxFit.cover
              ),
            )
        ),onTap:(){
      callback();
    }
    );
  }
}
