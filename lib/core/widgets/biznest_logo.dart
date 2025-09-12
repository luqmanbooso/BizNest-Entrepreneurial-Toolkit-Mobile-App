import 'package:flutter/material.dart';

class BizNestLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const BizNestLogo({
    super.key,
    this.size = 100.0,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon - Using your PNG image
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/biznest.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          // Logo Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
                child: Text(
                  'Biz',
                  style: TextStyle(
                    fontSize: size * 0.32,
                    fontWeight: FontWeight.w900,
                    color: textColor ?? Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
                child: Text(
                  'Nest',
                  style: TextStyle(
                    fontSize: size * 0.32,
                    fontWeight: FontWeight.w900,
                    color: textColor ?? Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
