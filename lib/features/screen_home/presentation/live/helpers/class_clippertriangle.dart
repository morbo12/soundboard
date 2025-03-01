import 'package:flutter/material.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_match_event_colors.dart';

class RightTriangle extends StatelessWidget {
  const RightTriangle({super.key, required this.matchEventTypeID});
  final int matchEventTypeID;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: ClipPath(
        clipper: TriangleClipperRight(),
        child: Container(
          // width: 20,
          height: 30,
          color: MatchEventColors(matchEventTypeID).getTileColor(context),
        ),
      ),
    );
  }
}

class LeftTriangle extends StatelessWidget {
  const LeftTriangle({super.key, required this.matchEventTypeID});
  final int matchEventTypeID;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: ClipPath(
        clipper: TriangleClipperLeft(),
        child: Container(
          // width: 20,
          height: 30,
          color: MatchEventColors(matchEventTypeID).getTileColor(context),
        ),
      ),
    );
  }
}

class TriangleClipperRight extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, size.height / 2);
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class TriangleClipperLeft extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
