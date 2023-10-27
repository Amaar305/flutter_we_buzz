import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Custom text style for titles
TextStyle titleTextStyle = GoogleFonts.lato(
  textStyle: const TextStyle(
    fontSize: 24, // Adjust the font size as needed
    fontWeight: FontWeight.bold, // You can change the font weight
    color: Colors.black, // Change the text color
  ),
);

// Custom text style for body content
TextStyle bodyTextStyle = GoogleFonts.lato(
  textStyle: const TextStyle(
    fontSize: 16, // Adjust the font size as needed
    fontWeight: FontWeight.normal, // You can change the font weight
    color: Colors.grey, // Change the text color
  ),
);

// Example of using these custom text styles in your widgets
// Widget buildTitle() {
//   return Text(
//     "Title Text",
//     style: titleTextStyle,
//   );
// }

// Widget buildBodyText() {
//   return Text(
//     "This is the body content.",
//     style: bodyTextStyle,
//   );
// }
