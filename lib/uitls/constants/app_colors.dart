import 'package:flutter/material.dart';

class AppColors {

  static final Color _primaryColor =  Color(0xFF08B3AC);
  static final Color _secondaryColor =  Color(0xffAA7BFF);
  static final Color green = Color(0xff034F4b);

  static final MaterialColor primaryColor = getMaterialColor(_primaryColor);
  static final MaterialColor secondaryColor = getMaterialColor(_secondaryColor);

  static final LinearGradient gradientTtBWithPrimary = LinearGradient(
    colors: [Color(0xFF08B3AC), Color(0xff034D4A)],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );


  static final LinearGradient gradientButtonprimary = LinearGradient(
    colors: [Color(0xff08B3AC), Color(0xff034D4A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static final LinearGradient gradientLtRWithSecondery = LinearGradient(
    colors: [Color(0xffAA7BFF), Color(0xff664A99)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static final LinearGradient gradientLtRWithSecondery2 = LinearGradient(
    colors: [Color(0xfff6ca44), Color(0xff8F4D05)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static getMaterialColor(Color color){
    int red = color.red;
    int green = color.green;
    int blue = color.blue;

    final Map<int, Color>shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
    };

    return MaterialColor(color.value, shades);

  }


}