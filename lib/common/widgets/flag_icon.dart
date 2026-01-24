import 'package:flutter/material.dart';

class FlagIcon extends StatelessWidget {
  const FlagIcon({
    super.key,
    required this.languageCode,
    this.width = 24,
    this.height = 16,
    this.borderRadius = 3,
  });

  final String languageCode;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final painter = switch (languageCode) {
      'sv' => const _SwedenFlagPainter(),
      'cs' => const _CzechFlagPainter(),
      _ => const _UnitedKingdomFlagPainter(),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(painter: painter),
        ),
      ),
    );
  }
}

class _SwedenFlagPainter extends CustomPainter {
  const _SwedenFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()..color = const Color(0xFF006AA7);
    final yellow = Paint()..color = const Color(0xFFFECC00);

    canvas.drawRect(Offset.zero & size, blue);

    final crossThickness = size.height * 0.22;
    final verticalX = size.width * 0.40;
    final horizontalY = (size.height - crossThickness) / 2;

    canvas.drawRect(
      Rect.fromLTWH(0, horizontalY, size.width, crossThickness),
      yellow,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        verticalX - crossThickness / 2,
        0,
        crossThickness,
        size.height,
      ),
      yellow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CzechFlagPainter extends CustomPainter {
  const _CzechFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white;
    final red = Paint()..color = const Color(0xFFD7141A);
    final blue = Paint()..color = const Color(0xFF11457E);

    canvas.drawRect(Offset.zero & size, white);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
      red,
    );

    final triangle = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.45, size.height / 2)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(triangle, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UnitedKingdomFlagPainter extends CustomPainter {
  const _UnitedKingdomFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()..color = const Color(0xFF012169);
    final white = Paint()..color = Colors.white;
    final red = Paint()..color = const Color(0xFFC8102E);

    canvas.drawRect(Offset.zero & size, blue);

    final whiteDiag = size.height * 0.18;
    final redDiag = size.height * 0.10;

    final diag1 = Path()
      ..moveTo(0, 0)
      ..lineTo(whiteDiag, 0)
      ..lineTo(size.width, size.height - whiteDiag)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - whiteDiag, size.height)
      ..lineTo(0, whiteDiag)
      ..close();

    final diag2 = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, whiteDiag)
      ..lineTo(whiteDiag, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - whiteDiag)
      ..lineTo(size.width - whiteDiag, 0)
      ..close();

    canvas.drawPath(diag1, white);
    canvas.drawPath(diag2, white);

    final redDiag1 = Path()
      ..moveTo(0, 0)
      ..lineTo(redDiag, 0)
      ..lineTo(size.width, size.height - redDiag)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - redDiag, size.height)
      ..lineTo(0, redDiag)
      ..close();

    final redDiag2 = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, redDiag)
      ..lineTo(redDiag, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - redDiag)
      ..lineTo(size.width - redDiag, 0)
      ..close();

    canvas.drawPath(redDiag1, red);
    canvas.drawPath(redDiag2, red);

    final whiteCross = size.height * 0.30;
    final redCross = size.height * 0.18;

    canvas.drawRect(
      Rect.fromLTWH((size.width - whiteCross) / 2, 0, whiteCross, size.height),
      white,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, (size.height - whiteCross) / 2, size.width, whiteCross),
      white,
    );

    canvas.drawRect(
      Rect.fromLTWH((size.width - redCross) / 2, 0, redCross, size.height),
      red,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, (size.height - redCross) / 2, size.width, redCross),
      red,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
