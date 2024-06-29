import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  String id;
  CustomIcon(this.id);

  Widget build(BuildContext context) {
    return Image.network(
      'https://openweathermap.org/img/wn/$id@2x.png',
    );
  }
}
