import 'package:flutter/material.dart';

class WhatsAppIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WhatsAppIcon({
    Key? key,
    this.size = 24,
    this.color = const Color(0xFF25D366), // Default to WhatsApp green
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: WhatsAppIconPainter(color: color),
    );
  }
}

class WhatsAppIconPainter extends CustomPainter {
  final Color color;

  WhatsAppIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Main circle (WhatsApp green background)
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, paint);
    
    // Draw speech bubble shape in green
    final bubblePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final bubbleSize = radius * 0.7;
    final bubbleCenter = Offset(center.dx, center.dy);
    
    // Main bubble body (rounded rectangle)
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: bubbleCenter,
        width: bubbleSize * 1.2,
        height: bubbleSize * 0.9,
      ),
      Radius.circular(bubbleSize * 0.2),
    );
    canvas.drawRRect(bubbleRect, bubblePaint);
    
    // Draw the tail of the speech bubble (triangle)
    final tailPath = Path();
    final tailWidth = bubbleSize * 0.3;
    final tailHeight = bubbleSize * 0.2;
    
    tailPath.moveTo(bubbleCenter.dx + bubbleSize * 0.3, bubbleCenter.dy + bubbleSize * 0.45);
    tailPath.lineTo(bubbleCenter.dx + bubbleSize * 0.3 + tailWidth, bubbleCenter.dy + bubbleSize * 0.45);
    tailPath.lineTo(bubbleCenter.dx + bubbleSize * 0.3 + tailWidth * 0.5, bubbleCenter.dy + bubbleSize * 0.45 + tailHeight);
    tailPath.close();
    
    canvas.drawPath(tailPath, bubblePaint);
    
    // Draw the "W" letter in white
    final textSize = bubbleSize * 0.4;
    final textCenter = Offset(bubbleCenter.dx, bubbleCenter.dy - bubbleSize * 0.05);
    
    // Draw "W" using lines
    final wPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = bubbleSize * 0.08
      ..strokeCap = StrokeCap.round;
    
    // Left stroke of W
    canvas.drawLine(
      Offset(textCenter.dx - textSize * 0.4, textCenter.dy - textSize * 0.3),
      Offset(textCenter.dx - textSize * 0.2, textCenter.dy + textSize * 0.3),
      wPaint,
    );
    
    // Middle-left stroke of W
    canvas.drawLine(
      Offset(textCenter.dx - textSize * 0.2, textCenter.dy - textSize * 0.3),
      Offset(textCenter.dx, textCenter.dy + textSize * 0.3),
      wPaint,
    );
    
    // Middle-right stroke of W
    canvas.drawLine(
      Offset(textCenter.dx, textCenter.dy - textSize * 0.3),
      Offset(textCenter.dx + textSize * 0.2, textCenter.dy + textSize * 0.3),
      wPaint,
    );
    
    // Right stroke of W
    canvas.drawLine(
      Offset(textCenter.dx + textSize * 0.2, textCenter.dy - textSize * 0.3),
      Offset(textCenter.dx + textSize * 0.4, textCenter.dy + textSize * 0.3),
      wPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
