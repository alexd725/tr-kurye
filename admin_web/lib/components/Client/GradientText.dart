import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_delivery_admin/utils/Extensions/context_extensions.dart';

import '../../utils/Colors.dart';

class GradientText extends StatelessWidget {
  const GradientText(this.text, {required this.gradient, this.style});
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        softWrap: true,
        style: TextStyle(
          fontSize: context.width() / 10.2,
          fontWeight: FontWeight.w900,
          fontFamily: GoogleFonts.poppins().fontFamily,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = primaryColor,
        ),
      ),
    );
  }
}