import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'retro_theme.dart';

/// Wraps scaffold body with clean retro paper background
class RetroBackground extends StatelessWidget {
  final Widget child;
  const RetroBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RetroColors.paperBg,
      child: child,
    );
  }
}

class GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grainPaint = Paint();
    grainPaint.color = const Color(0x0A111111);

    const double step = 8.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        if ((x + y) % (step * 2) == 0) {
          canvas.drawCircle(Offset(x, y), 0.75, grainPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Retro Card with 2.5px solid black border and hard offset shadow
class RetroCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double radius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Offset shadowOffset;

  const RetroCard({
    super.key,
    required this.child,
    this.color,
    this.radius = 22,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.shadowOffset = const Offset(4, 5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? RetroColors.cardSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: RetroColors.ink, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: RetroColors.ink,
            offset: shadowOffset,
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Interactive Retro Button with press translation animation (tap down shrinks shadow and translates button)
class RetroButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final bool showTrailingSquare;

  const RetroButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = RetroColors.brandGreen,
    this.textColor = RetroColors.ink,
    this.icon,
    this.showTrailingSquare = true,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final offset = _isPressed ? Offset.zero : const Offset(4, 5);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOutCubic,
          transform: Matrix4.translationValues(
            _isPressed ? 4.0 : 0.0,
            _isPressed ? 5.0 : 0.0,
            0.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RetroColors.ink, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: RetroColors.ink,
                offset: offset,
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.textColor, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
                style: RetroTheme.headingStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: widget.textColor,
                ),
              ),
              if (widget.showTrailingSquare) ...[
                const Spacer(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: RetroColors.ink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 48x48 Rounded square Icon Button with hard shadow
class RetroIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool hasBadge;

  const RetroIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.hasBadge = false,
  });

  @override
  State<RetroIconButton> createState() => _RetroIconButtonState();
}

class _RetroIconButtonState extends State<RetroIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            width: 44,
            height: 44,
            transform: Matrix4.translationValues(
              _isPressed ? 3.0 : 0.0,
              _isPressed ? 3.0 : 0.0,
              0.0,
            ),
            decoration: BoxDecoration(
              color: RetroColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: RetroColors.ink, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: RetroColors.ink,
                  offset: _isPressed ? Offset.zero : const Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(widget.icon, color: RetroColors.ink, size: 22),
          ),
          if (widget.hasBadge)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: RetroColors.expenseRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: RetroColors.ink, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

/// Filter / Tag Chip
class RetroChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const RetroChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? RetroColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: RetroColors.ink, width: 2.0),
        ),
        child: Text(
          label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: RetroTheme.monoStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : RetroColors.ink,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Stat Tile component
class RetroStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const RetroStatTile({
    super.key,
    required this.label,
    required this.value,
    this.backgroundColor = RetroColors.cardSurface,
    this.textColor = RetroColors.ink,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap != null
            ? () {
                HapticFeedback.lightImpact();
                onTap!();
              }
            : null,
        onLongPress: onLongPress != null
            ? () {
                HapticFeedback.heavyImpact();
                onLongPress!();
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RetroColors.ink, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: RetroColors.ink,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                value,
                style: RetroTheme.headingStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
                style: RetroTheme.monoStyle(
                  fontSize: 10,
                  color: textColor == Colors.white ? Colors.white70 : RetroColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centered outlined pill label with horizontal lines to both sides
class RetroSectionLabel extends StatelessWidget {
  final String label;
  const RetroSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: RetroDivider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: RetroColors.paperBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: RetroColors.ink, width: 2.0),
            ),
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RetroTheme.monoStyle(
                fontSize: 10,
                color: RetroColors.ink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Expanded(child: RetroDivider()),
      ],
    );
  }
}

/// Dashed divider line
class RetroDivider extends StatelessWidget {
  final double height;
  const RetroDivider({super.key, this.height = 1.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _DashedLinePainter(),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dashPaint = Paint();
    dashPaint.color = RetroColors.dividerDashed;
    dashPaint.strokeWidth = 1.5;
    dashPaint.style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0.0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), dashPaint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Category Icon rounded square box (48x48, 2.5px black border, pastel fill, black icon)
class RetroCategoryIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final double size;

  const RetroCategoryIcon({
    super.key,
    required this.icon,
    this.backgroundColor = RetroColors.mint,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: RetroColors.ink, width: 2.2),
      ),
      child: Icon(icon, color: RetroColors.ink, size: size * 0.52),
    );
  }
}

/// Retro Switch
class RetroSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const RetroSwitch({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onChanged == null;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              HapticFeedback.selectionClick();
              onChanged!(!value);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey[300]
              : (value ? RetroColors.brandGreen : RetroColors.cardSurface),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: RetroColors.ink, width: 2.5),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey[500] : RetroColors.ink,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Retro Text Field
class RetroTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final bool autofocus;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextStyle? style;

  const RetroTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!.toUpperCase(), style: RetroTheme.monoStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: RetroColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RetroColors.ink, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: RetroColors.ink,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: style ?? RetroTheme.headingStyle(fontSize: 16, fontWeight: FontWeight.w700),
            cursorColor: RetroColors.brandGreen,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: RetroTheme.headingStyle(fontSize: 16, color: Colors.grey[500]!),
              border: InputBorder.none,
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
      ],
    );
  }
}

/// iPhone 4 Lock Screen "Slide to Save" widget
class RetroSlideToSave extends StatefulWidget {
  final String label;
  final VoidCallback onSave;
  final Color trackColor;
  final Color thumbColor;
  final double height;

  const RetroSlideToSave({
    super.key,
    this.label = 'SLIDE TO SAVE',
    required this.onSave,
    this.trackColor = RetroColors.brandGreen,
    this.thumbColor = RetroColors.cardSurface,
    this.height = 68.0,
  });

  @override
  State<RetroSlideToSave> createState() => _RetroSlideToSaveState();
}

class _RetroSlideToSaveState extends State<RetroSlideToSave> with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        setState(() {
          _dragValue = _resetAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDragDistance) {
    if (_isSubmitted) return;
    setState(() {
      _dragValue = (_dragValue + details.delta.dx / maxDragDistance).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isSubmitted) return;
    if (_dragValue >= 0.80) {
      setState(() {
        _dragValue = 1.0;
        _isSubmitted = true;
      });
      HapticFeedback.heavyImpact();
      widget.onSave();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _dragValue = 0.0;
            _isSubmitted = false;
          });
        }
      });
    } else {
      _resetAnimation = Tween<double>(begin: _dragValue, end: 0.0).animate(
        CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
      );
      _resetController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = widget.height;
    const double thumbWidth = 60.0;
    const double padding = 5.0;

    final bool isDarkTrack = widget.trackColor.computeLuminance() < 0.15;
    final Color textColor = isDarkTrack ? Colors.white.withValues(alpha: 0.9) : RetroColors.ink;
    final Color doubleArrowColor = isDarkTrack ? Colors.white70 : RetroColors.ink;

    final bool isDarkThumb = widget.thumbColor.computeLuminance() < 0.15;
    final Color thumbIconColor = isDarkThumb ? Colors.white : RetroColors.ink;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: widget.trackColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RetroColors.ink, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: RetroColors.ink,
            offset: Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxDragDistance = constraints.maxWidth - thumbWidth - (padding * 2);
          final thumbOffset = _dragValue * maxDragDistance;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Track Label Text
              Positioned.fill(
                left: thumbWidth + padding * 2,
                child: Center(
                  child: Opacity(
                    opacity: (1.0 - (_dragValue * 1.5)).clamp(0.0, 1.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
                          style: RetroTheme.headingStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.double_arrow_rounded,
                          color: doubleArrowColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Draggable Slider Thumb
              Positioned(
                left: padding + thumbOffset,
                top: padding,
                bottom: padding,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) => _onDragUpdate(details, maxDragDistance),
                  onHorizontalDragEnd: _onDragEnd,
                  child: Container(
                    width: thumbWidth,
                    decoration: BoxDecoration(
                      color: widget.thumbColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: RetroColors.ink, width: 2.0),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: thumbIconColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A custom Retro Slidable Tile that supports swipe-to-edit and swipe-to-delete
/// with fully rounded action cards and no sharp rectangular ClipRect clipping.
class RetroSlidableTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const RetroSlidableTile({
    super.key,
    required this.child,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  State<RetroSlidableTile> createState() => _RetroSlidableTileState();
}

class _RetroSlidableTileState extends State<RetroSlidableTile> with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  static const double _openEditOffset = -105.0;
  static const double _openDeleteOffset = 115.0;
  static const double _fullSwipeThreshold = 180.0;
  static const double _deleteSwipeThreshold = 180.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        setState(() {
          _dragOffset = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double targetOffset, {VoidCallback? onComplete}) {
    _animation = Tween<double>(begin: _dragOffset, end: targetOffset).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward(from: 0.0).then((_) {
      if (onComplete != null) onComplete();
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double screenWidth) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(-screenWidth, screenWidth);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double screenWidth) {
    final velocity = details.velocity.pixelsPerSecond.dx;

    if (_dragOffset <= -_fullSwipeThreshold || velocity < -800) {
      HapticFeedback.lightImpact();
      _animateTo(-screenWidth, onComplete: () {
        if (mounted) setState(() => _dragOffset = 0.0);
        widget.onEdit();
      });
    } else if (_dragOffset >= _deleteSwipeThreshold || velocity > 800) {
      HapticFeedback.mediumImpact();
      _animateTo(screenWidth, onComplete: () {
        if (mounted) setState(() => _dragOffset = 0.0);
        widget.onDelete();
      });
    } else if (_dragOffset <= -40.0) {
      HapticFeedback.selectionClick();
      _animateTo(_openEditOffset);
    } else if (_dragOffset >= 40.0) {
      HapticFeedback.selectionClick();
      _animateTo(_openDeleteOffset);
    } else {
      _animateTo(0.0);
    }
  }

  void _handleTap() {
    if (_dragOffset.abs() > 10.0) {
      _animateTo(0.0);
    } else if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deleteWidth = (_dragOffset + 20.0).clamp(110.0, screenWidth);
    final editWidth = ((-_dragOffset) + 20.0).clamp(105.0, screenWidth);

    return Stack(
      children: [
        if (_dragOffset > 0)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: (_dragOffset / 40.0).clamp(0.0, 1.0),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _animateTo(0.0, onComplete: widget.onDelete);
                },
                onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, screenWidth),
                onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, screenWidth),
                child: Container(
                  width: deleteWidth,
                  margin: const EdgeInsets.only(bottom: 4, left: 3),
                  decoration: BoxDecoration(
                    color: RetroColors.expenseRed,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: RetroColors.ink, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: RetroColors.ink,
                        offset: Offset(3, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 20),
                      Icon(Icons.delete_outline, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'DELETE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        if (_dragOffset < 0)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: (-_dragOffset / 40.0).clamp(0.0, 1.0),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _animateTo(0.0, onComplete: widget.onEdit);
                },
                onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, screenWidth),
                onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, screenWidth),
                child: Container(
                  width: editWidth,
                  margin: const EdgeInsets.only(bottom: 4, right: 3),
                  decoration: BoxDecoration(
                    color: RetroColors.infoBluePastel,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: RetroColors.ink, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: RetroColors.ink,
                        offset: Offset(3, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'EDIT',
                        style: TextStyle(
                          color: RetroColors.ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.edit_outlined, color: RetroColors.ink, size: 18),
                      SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

        Transform.translate(
          offset: Offset(_dragOffset, 0),
          child: GestureDetector(
            onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, screenWidth),
            onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, screenWidth),
            onTap: _handleTap,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
