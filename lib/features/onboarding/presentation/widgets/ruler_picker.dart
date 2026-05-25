import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';

/// A custom horizontal scrollable ruler picker for weight, etc.
class HorizontalRulerPicker extends StatefulWidget {
  final double minValue;
  final double maxValue;
  final double initialValue;
  final double tickSpacing;
  final int majorTickInterval;
  final int mediumTickInterval;
  final String unit;
  final ValueChanged<double> onChanged;

  const HorizontalRulerPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    this.tickSpacing = 10.0,
    this.majorTickInterval = 10,
    this.mediumTickInterval = 5,
    required this.unit,
    required this.onChanged,
  });

  @override
  State<HorizontalRulerPicker> createState() => _HorizontalRulerPickerState();
}

class _HorizontalRulerPickerState extends State<HorizontalRulerPicker> {
  late ScrollController _scrollController;
  late double _currentVal;
  bool _isSnapping = false;

  @override
  void initState() {
    super.initState();
    _currentVal = widget.initialValue.clamp(widget.minValue, widget.maxValue);
    final initialOffset = (_currentVal - widget.minValue) * widget.tickSpacing;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(HorizontalRulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unit != widget.unit ||
        (widget.initialValue - _currentVal).abs() > 0.1) {
      _currentVal = widget.initialValue.clamp(widget.minValue, widget.maxValue);
      final targetOffset = (_currentVal - widget.minValue) * widget.tickSpacing;
      if (_scrollController.hasClients && !_isSnapping) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(targetOffset);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final double calculated = widget.minValue + (offset / widget.tickSpacing);
    final clamped = calculated.clamp(widget.minValue, widget.maxValue);

    // Round to 1 decimal place or integer
    final finalVal = double.parse(clamped.toStringAsFixed(1));

    if (finalVal != _currentVal) {
      setState(() {
        _currentVal = finalVal;
      });
      widget.onChanged(finalVal);
      // Trigger a light haptic tap on values changing (tactile tick effect)
      if (finalVal % 1 == 0 ||
          (widget.unit == 'kg' && (finalVal * 10) % 5 == 0)) {
        HapticFeedback.selectionClick();
      }
    }
  }

  void _snapToTick() async {
    if (_isSnapping || !_scrollController.hasClients) return;
    _isSnapping = true;

    // Allow animation to snap perfectly
    final snappedVal = _currentVal.roundToDouble();
    final targetOffset = (snappedVal - widget.minValue) * widget.tickSpacing;

    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
    _isSnapping = false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final int tickCount = (widget.maxValue - widget.minValue).toInt() + 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double sidePadding = constraints.maxWidth / 2;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              _snapToTick();
            }
            return true;
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ruler scale scrolling view
              SizedBox(
                height: 100,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: sidePadding),
                  itemCount: tickCount,
                  itemBuilder: (context, index) {
                    final double val = widget.minValue + index;
                    final bool isMajor =
                        (val - widget.minValue) % widget.majorTickInterval == 0;
                    final bool isMedium =
                        (val - widget.minValue) % widget.mediumTickInterval ==
                        0;

                    double tickHeight = 14.0;
                    Color tickColor = colors.outline;
                    double strokeWidth = 1.0;

                    if (isMajor) {
                      tickHeight = 36.0;
                      tickColor = colors.onSurface.withValues(alpha: 0.8);
                      strokeWidth = 2.0;
                    } else if (isMedium) {
                      tickHeight = 24.0;
                      tickColor = colors.onSurface.withValues(alpha: 0.5);
                      strokeWidth = 1.5;
                    } else {
                      tickHeight = 14.0;
                      tickColor = colors.outline.withValues(alpha: 0.6);
                      strokeWidth = 1.0;
                    }

                    return Container(
                      width: widget.tickSpacing,
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // Tick line
                          Positioned(
                            bottom: 22,
                            child: Container(
                              width: strokeWidth,
                              height: tickHeight,
                              color: tickColor,
                            ),
                          ),
                          // Tick label (only for major values)
                          if (isMajor)
                            Positioned(
                              bottom: 0,
                              child: Text(
                                val.toInt().toString(),
                                style: AppTypography.numeralSm(
                                  color: colors.onSurfaceVariant.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Centered Indicator Line & Accent Node
              Positioned(
                top: 0,
                bottom: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Triangle pointer
                    Icon(
                      LucideIcons.chevronDown,
                      size: 24,
                      color: colors.primary,
                    ),
                    const Spacer(),
                    // Highlight center indicator line
                    Container(
                      width: 3.5,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A custom vertical scrollable ruler picker for height, etc.
class VerticalRulerPicker extends StatefulWidget {
  final double minValue;
  final double maxValue;
  final double initialValue;
  final double tickSpacing;
  final int majorTickInterval;
  final int mediumTickInterval;
  final String unit;
  final ValueChanged<double> onChanged;

  const VerticalRulerPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    this.tickSpacing = 10.0,
    this.majorTickInterval = 10,
    this.mediumTickInterval = 5,
    required this.unit,
    required this.onChanged,
  });

  @override
  State<VerticalRulerPicker> createState() => _VerticalRulerPickerState();
}

class _VerticalRulerPickerState extends State<VerticalRulerPicker> {
  late ScrollController _scrollController;
  late double _currentVal;
  bool _isSnapping = false;

  @override
  void initState() {
    super.initState();
    _currentVal = widget.initialValue.clamp(widget.minValue, widget.maxValue);
    final initialOffset = (_currentVal - widget.minValue) * widget.tickSpacing;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(VerticalRulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unit != widget.unit ||
        (widget.initialValue - _currentVal).abs() > 0.1) {
      _currentVal = widget.initialValue.clamp(widget.minValue, widget.maxValue);
      final targetOffset = (_currentVal - widget.minValue) * widget.tickSpacing;
      if (_scrollController.hasClients && !_isSnapping) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(targetOffset);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final double calculated = widget.minValue + (offset / widget.tickSpacing);
    final clamped = calculated.clamp(widget.minValue, widget.maxValue);

    final finalVal = double.parse(clamped.toStringAsFixed(1));

    if (finalVal != _currentVal) {
      setState(() {
        _currentVal = finalVal;
      });
      widget.onChanged(finalVal);
      // Trigger subtle tactile response
      if (finalVal % 1 == 0 || (widget.unit == 'cm' && finalVal % 5 == 0)) {
        HapticFeedback.selectionClick();
      }
    }
  }

  void _snapToTick() async {
    if (_isSnapping || !_scrollController.hasClients) return;
    _isSnapping = true;

    final snappedVal = _currentVal.roundToDouble();
    final targetOffset = (snappedVal - widget.minValue) * widget.tickSpacing;

    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
    _isSnapping = false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final int tickCount = (widget.maxValue - widget.minValue).toInt() + 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double sidePadding = constraints.maxHeight / 2;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              _snapToTick();
            }
            return true;
          },
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Ruler dial scrolling view
              SizedBox(
                width: 140,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: sidePadding),
                  itemCount: tickCount,
                  itemBuilder: (context, index) {
                    final double val = widget.minValue + index;
                    final bool isMajor =
                        (val - widget.minValue) % widget.majorTickInterval == 0;
                    final bool isMedium =
                        (val - widget.minValue) % widget.mediumTickInterval ==
                        0;

                    double tickWidth = 24.0;
                    Color tickColor = colors.outline;
                    double strokeWidth = 1.0;

                    if (isMajor) {
                      tickWidth = 48.0;
                      tickColor = colors.onSurface.withValues(alpha: 0.8);
                      strokeWidth = 2.0;
                    } else if (isMedium) {
                      tickWidth = 36.0;
                      tickColor = colors.onSurface.withValues(alpha: 0.5);
                      strokeWidth = 1.5;
                    } else {
                      tickWidth = 24.0;
                      tickColor = colors.outline.withValues(alpha: 0.6);
                      strokeWidth = 1.0;
                    }

                    // For FT/IN display, format the major labels properly
                    String label = val.toInt().toString();
                    if (widget.unit == 'ft') {
                      final int totalInches = val.toInt();
                      final int ft = totalInches ~/ 12;
                      final int inches = totalInches % 12;
                      if (isMajor) {
                        label = "$ft'";
                      } else if (isMedium && inches == 6) {
                        label = "$ft'6\"";
                      } else {
                        label = '';
                      }
                    }

                    return Container(
                      height: widget.tickSpacing,
                      alignment: Alignment.centerLeft,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        clipBehavior: Clip.none,
                        children: [
                          // Tick line
                          Positioned(
                            left: 0,
                            child: Container(
                              height: strokeWidth,
                              width: tickWidth,
                              color: tickColor,
                            ),
                          ),
                          // Tick label
                          if (isMajor ||
                              (widget.unit == 'ft' &&
                                  isMedium &&
                                  (val.toInt() % 12 == 6)))
                            Positioned(
                              left: 60,
                              child: Text(
                                label,
                                style: AppTypography.numeralSm(
                                  color: colors.onSurfaceVariant.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Centered Indicator Pointer
              Positioned(
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    // Accent indicator line
                    Container(
                      height: 3.5,
                      width: 58,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Centered arrow head pointing left
                    Icon(
                      LucideIcons.arrowLeft,
                      size: 28,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
