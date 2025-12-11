import 'package:flutter/material.dart';
import 'dart:async';

class ConnectButton extends StatefulWidget {
  final bool isConnected;
  final VoidCallback onPressed;

  const ConnectButton({
    super.key,
    required this.isConnected,
    required this.onPressed,
  });

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _seconds = 0;
  double _dragPosition = 0;
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {
          _dragPosition = _animation.value;
        });
      });
  }

  @override
  void didUpdateWidget(ConnectButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnected && !oldWidget.isConnected) {
      _startTimer();
    } else if (!widget.isConnected && oldWidget.isConnected) {
      _stopTimer();
      _resetSlider();
    }
  }

  void _startTimer() {
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _seconds = 0;
    });
  }

  void _resetSlider() {
    _animation = Tween<double>(
      begin: _dragPosition,
      end: 0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (widget.isConnected) return;
    
    setState(() {
      _isDragging = true;
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxWidth);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxWidth) {
    if (widget.isConnected) return;
    
    setState(() {
      _isDragging = false;
    });

    // If dragged more than 80% of the width, trigger connection
    if (_dragPosition > maxWidth * 0.8) {
      widget.onPressed();
      // Keep the slider at the end position
      setState(() {
        _dragPosition = maxWidth;
      });
    } else {
      // Reset to start
      _resetSlider();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDragDistance = constraints.maxWidth - 68; // 68 is the slider button width

        return GestureDetector(
          onTap: widget.isConnected ? widget.onPressed : null,
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              gradient: widget.isConnected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF27AE60),
                        const Color(0xFF1E8449),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey.shade200,
                        Colors.grey.shade300,
                      ],
                    ),
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: widget.isConnected
                      ? const Color(0xFF27AE60).withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: widget.isConnected
                      ? const Color(0xFF27AE60).withOpacity(0.15)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: 30,
                  offset: const Offset(0, 4),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background text/hint
                Center(
                  child: AnimatedOpacity(
                    opacity: widget.isConnected ? 0.0 : (1.0 - (_dragPosition / maxDragDistance).clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.black45,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Slide to Connect',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.black45,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                // Connected state content
                if (widget.isConnected)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Connected',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _formatTime(_seconds),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Slider button
                AnimatedPositioned(
                  duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  left: widget.isConnected ? null : 4 + _dragPosition,
                  right: widget.isConnected ? 4 : null,
                  top: 4,
                  bottom: 4,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, maxDragDistance),
                    onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, maxDragDistance),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.grey.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: widget.isConnected
                                ? const Color(0xFF27AE60).withOpacity(0.3)
                                : Colors.blue.withOpacity(_dragPosition / maxDragDistance * 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isConnected ? Icons.lock : Icons.lock_open,
                        color: widget.isConnected
                            ? const Color(0xFF27AE60)
                            : Color.lerp(
                                Colors.grey.shade600,
                                const Color(0xFF27AE60),
                                (_dragPosition / maxDragDistance).clamp(0.0, 1.0),
                              ),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
