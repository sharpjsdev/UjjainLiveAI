import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../providers/speech_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  late Animation<double> _emblemScaleAnimation;
  late Animation<double> _emblemFadeAnimation;
  late Animation<double> _mantraFadeAnimation;
  late Animation<double> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _loaderFadeAnimation;

  Timer? _stepTimer;
  int _spiritualStepIndex = 0;
  final List<String> _spiritualSteps = [
    'Connecting to Sacred Ujjain Sanctum...',
    'Loading Mahakaleshwar Aarti & Darshan Timings...',
    'Preparing Shipra Ghats & Simhastha 2028 Muhurat...',
    'Har Har Mahadev • Welcome, Pilgrim!',
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSpiritualStepCycle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapApp();
    });
  }

  void _initAnimations() {
    // Main entrance choreographer
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    // Continuous subtle divine pulsing of the golden aura
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat(reverse: true);

    // Slow rotation of celestial halo
    _rotationController = AnimationController(
      duration: const Duration(seconds: 24),
      vsync: this,
    )..repeat();

    // Staged entrance animations
    _emblemScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _emblemFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _mantraFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeInOut),
      ),
    );

    _titleSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.45, 0.8, curve: Curves.easeIn),
      ),
    );

    _loaderFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _entryController.forward();
  }

  void _startSpiritualStepCycle() {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _spiritualStepIndex = (_spiritualStepIndex + 1) % _spiritualSteps.length;
      });
    });
  }

  Future<void> _bootstrapApp() async {
    final startTime = DateTime.now();

    try {
      // 1. Request Microphone and Location permissions in a single unified OS batch.
      // On Android, requesting them together displays the Microphone dialog first,
      // and immediately follows with the Location dialog smoothly without dropping either one!
      await [
        Permission.microphone,
        Permission.location,
      ].request();

      // 2. Pre-initialize providers sequentially so platform channels do not conflict
      if (mounted) {
        final chatProvider = context.read<ChatProvider>();
        final speechProvider = context.read<SpeechProvider>();

        await chatProvider.initialize();
        await speechProvider.initialize();
      }
    } catch (e) {
      debugPrint('[SplashScreen] Initialization notice: $e');
    }

    if (!mounted) return;

    // Ensure splash remains visible long enough for a serene experience
    final elapsed = DateTime.now().difference(startTime);
    final minDisplayDuration = const Duration(milliseconds: 2800);
    if (elapsed < minDisplayDuration) {
      await Future.delayed(minDisplayDuration - elapsed);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/chat');
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _entryController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.sanctumGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top auspicious mantra header
                          FadeTransition(
                            opacity: _mantraFadeAnimation,
                            child: _buildSacredHeader(),
                          ),

                          // Centerpiece: Sacred Emblem + Title
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12),
                              // Animated Sacred Simhastha Emblem
                              ScaleTransition(
                                scale: _emblemScaleAnimation,
                                child: FadeTransition(
                                  opacity: _emblemFadeAnimation,
                                  child: AnimatedBuilder(
                                    animation: Listenable.merge([_pulseController, _rotationController]),
                                    builder: (context, child) {
                                      return _buildEmblemWithAura(size.width);
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Sacred Typography & Brand Identity
                              AnimatedBuilder(
                                animation: _titleSlideAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _titleSlideAnimation.value),
                                    child: FadeTransition(
                                      opacity: _titleFadeAnimation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: _buildTitleSection(),
                              ),
                            ],
                          ),

                          // Bottom loader & blessing footer
                          FadeTransition(
                            opacity: _loaderFadeAnimation,
                            child: _buildFooterSection(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSacredHeader() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.templeGold.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ॐ',
                style: TextStyle(
                  color: AppColors.templeGold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '॥ जय श्री महाकाल ॥',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'ॐ',
                style: TextStyle(
                  color: AppColors.templeGold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmblemWithAura(double screenWidth) {
    final emblemSize = math.min(screenWidth * 0.58, 230.0);
    final pulseScale = 1.0 + (_pulseController.value * 0.06);

    return SizedBox(
      width: emblemSize,
      height: emblemSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Radiating Aura Glow
          Transform.scale(
            scale: pulseScale,
            child: Container(
              width: emblemSize,
              height: emblemSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.templeGold.withValues(alpha: 0.35),
                    AppColors.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Slowly rotating celestial halo ring
          Transform.rotate(
            angle: _rotationController.value * 2 * math.pi,
            child: SizedBox(
              width: emblemSize * 0.94,
              height: emblemSize * 0.94,
              child: CustomPaint(
                painter: CelestialHaloPainter(),
              ),
            ),
          ),

          // Core Sacred Simhastha Emblem (Trishul, Tripundra, Kumbh & Om)
          Container(
            width: emblemSize * 0.76,
            height: emblemSize * 0.76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.templeGold,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/simhastha_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const CustomPaint(
                  painter: SacredSimhasthaEmblemPainter(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        // Sacred Devanagari Title
        Text(
          'सिंहस्थ उज्जैन',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.goldLight,
            letterSpacing: 2.0,
            shadows: [
              Shadow(
                color: AppColors.primary.withValues(alpha: 0.6),
                blurRadius: 12,
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Latin Regal Title
        ShaderMask(
          shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
          child: const Text(
            'UJJAIN LIVE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 5.0,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Pilgrim Sanctuary Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.25),
                AppColors.tilak.withValues(alpha: 0.25),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.temple_hindu,
                color: AppColors.templeGold,
                size: 15,
              ),
              SizedBox(width: 8),
              Text(
                'Your Sacred Guide to Ujjain',
                style: TextStyle(
                  color: Color(0xFFFFF3E0),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Subtitle
        Text(
          'Live Updates • Simhastha 2028 • Offline Ready',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.goldLight.withValues(alpha: 0.8),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Saffron & Gold Pulse Progress Bar
        SizedBox(
          width: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              backgroundColor: Color(0xFF3E160A),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 3.5,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Dynamic Spiritual Loading Step
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            _spiritualSteps[_spiritualStepIndex],
            key: ValueKey<int>(_spiritualStepIndex),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.goldLight,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.4,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Bottom devotion invocation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 1,
              width: 32,
              color: AppColors.templeGold.withValues(alpha: 0.3),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'हर हर महादेव',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.templeGold,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            Container(
              height: 1,
              width: 32,
              color: AppColors.templeGold.withValues(alpha: 0.3),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Custom painter for the rotating outer celestial aura ring
class CelestialHaloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rayPaint = Paint()
      ..color = AppColors.templeGold.withValues(alpha: 0.25)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    const numPoints = 16;
    for (int i = 0; i < numPoints; i++) {
      final angle = (i * 2 * math.pi) / numPoints;
      final x1 = center.dx + (radius - 12) * math.cos(angle);
      final y1 = center.dy + (radius - 12) * math.sin(angle);
      final x2 = center.dx + radius * math.cos(angle);
      final y2 = center.dy + radius * math.sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), rayPaint);
      canvas.drawCircle(Offset(x2, y2), 1.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the sacred Simhastha centerpiece:
/// Shiva's Tripundra (three ash lines), Crimson Tilak, Golden Trishul, and Amrit Kumbh
class SacredSimhasthaEmblemPainter extends CustomPainter {
  const SacredSimhasthaEmblemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;

    // 1. Draw Amrit Kumbh (Nectar Pot) at the base
    final kumbhPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.goldLight, AppColors.templeGold, AppColors.primaryDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(center: Offset(center.dx, h * 0.76), width: w * 0.36, height: h * 0.22))
      ..style = PaintingStyle.fill;

    final kumbhPath = Path();
    kumbhPath.moveTo(center.dx - w * 0.08, h * 0.68);
    kumbhPath.quadraticBezierTo(center.dx - w * 0.18, h * 0.73, center.dx - w * 0.14, h * 0.82);
    kumbhPath.quadraticBezierTo(center.dx, h * 0.87, center.dx + w * 0.14, h * 0.82);
    kumbhPath.quadraticBezierTo(center.dx + w * 0.18, h * 0.73, center.dx + w * 0.08, h * 0.68);
    kumbhPath.close();
    canvas.drawPath(kumbhPath, kumbhPaint);

    // 2. Draw Golden Trishul (Trident)
    final trishulPaint = Paint()
      ..color = AppColors.templeGold
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final trishulFill = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.goldLight, AppColors.templeGold],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(center: center, width: w * 0.45, height: h * 0.6))
      ..style = PaintingStyle.fill;

    // Central shaft
    canvas.drawLine(
      Offset(center.dx, h * 0.20),
      Offset(center.dx, h * 0.70),
      trishulPaint..strokeWidth = 3.5,
    );

    // Center spear tip
    final centerProng = Path();
    centerProng.moveTo(center.dx, h * 0.14);
    centerProng.lineTo(center.dx + w * 0.038, h * 0.23);
    centerProng.lineTo(center.dx - w * 0.038, h * 0.23);
    centerProng.close();
    canvas.drawPath(centerProng, trishulFill);

    // Left curved prong
    final leftProng = Path();
    leftProng.moveTo(center.dx, h * 0.36);
    leftProng.cubicTo(
      center.dx - w * 0.18, h * 0.34,
      center.dx - w * 0.18, h * 0.20,
      center.dx - w * 0.12, h * 0.17,
    );
    canvas.drawPath(leftProng, trishulPaint..strokeWidth = 3.0);

    // Left spear head
    final leftTip = Path();
    leftTip.moveTo(center.dx - w * 0.12, h * 0.17);
    leftTip.lineTo(center.dx - w * 0.09, h * 0.22);
    leftTip.lineTo(center.dx - w * 0.15, h * 0.22);
    leftTip.close();
    canvas.drawPath(leftTip, trishulFill);

    // Right curved prong
    final rightProng = Path();
    rightProng.moveTo(center.dx, h * 0.36);
    rightProng.cubicTo(
      center.dx + w * 0.18, h * 0.34,
      center.dx + w * 0.18, h * 0.20,
      center.dx + w * 0.12, h * 0.17,
    );
    canvas.drawPath(rightProng, trishulPaint..strokeWidth = 3.0);

    // Right spear head
    final rightTip = Path();
    rightTip.moveTo(center.dx + w * 0.12, h * 0.17);
    rightTip.lineTo(center.dx + w * 0.15, h * 0.22);
    rightTip.lineTo(center.dx + w * 0.09, h * 0.22);
    rightTip.close();
    canvas.drawPath(rightTip, trishulFill);

    // Damru in the middle of Trishul
    final damruPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final damruBorder = Paint()
      ..color = AppColors.templeGold
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final damruPath = Path();
    damruPath.moveTo(center.dx - w * 0.05, h * 0.38);
    damruPath.lineTo(center.dx + w * 0.05, h * 0.38);
    damruPath.lineTo(center.dx - w * 0.05, h * 0.44);
    damruPath.lineTo(center.dx + w * 0.05, h * 0.44);
    damruPath.close();
    canvas.drawPath(damruPath, damruPaint);
    canvas.drawPath(damruPath, damruBorder);

    // 3. Shiva's Tripundra (Three Sacred White/Ash Lines)
    final tripundraPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4;

    for (int i = -1; i <= 1; i++) {
      final yOffset = h * 0.52 + (i * 5.5);
      final curvePath = Path();
      curvePath.moveTo(center.dx - w * 0.19, yOffset);
      curvePath.quadraticBezierTo(center.dx, yOffset + 3.0, center.dx + w * 0.19, yOffset);
      canvas.drawPath(curvePath, tripundraPaint);
    }

    // 4. Crimson Tilak (Bindu in the center of Tripundra)
    final tilakPaint = Paint()
      ..color = AppColors.tilak
      ..style = PaintingStyle.fill;

    final tilakGlow = Paint()
      ..color = AppColors.tilak.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawCircle(Offset(center.dx, h * 0.52), 4.8, tilakGlow);
    canvas.drawCircle(Offset(center.dx, h * 0.52), 3.5, tilakPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
