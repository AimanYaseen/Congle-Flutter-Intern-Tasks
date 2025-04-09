import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SquareAnimation(),
          ),
        ),
      ),
    );
  }
}

class SquareAnimation extends StatefulWidget {
  const SquareAnimation({super.key});

  @override
  State<SquareAnimation> createState() => _SquareAnimationState();
}

class _SquareAnimationState extends State<SquareAnimation> with TickerProviderStateMixin {
  static const double _squareSize = 50.0;
  double _position = 0.0;
  bool _isAnimating = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  double _maxRightPosition = 0.0;
  double _maxLeftPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width - 64.0; // Account for padding
    _maxRightPosition = screenWidth / 2 - _squareSize / 2;
    _maxLeftPosition = -_maxRightPosition;
    _position = 0.0; // Start centered
  }

  void _moveSquare(double targetPosition) {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    _animation = Tween<double>(
      begin: _position,
      end: targetPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _animation.addListener(() {
      setState(() {
        _position = _animation.value;
      });
    });

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
        });
        _controller.reset();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(_position, 0),
          child: Container(
            width: _squareSize,
            height: _squareSize,
            decoration: BoxDecoration(
              color: Colors.red,
              border: Border.all(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isAnimating || _position <= _maxLeftPosition
                  ? null
                  : () => _moveSquare(_maxLeftPosition),
              child: const Text('Left'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isAnimating || _position >= _maxRightPosition
                  ? null
                  : () => _moveSquare(_maxRightPosition),
              child: const Text('Right'),
            ),
          ],
        ),
      ],
    );
  }
}