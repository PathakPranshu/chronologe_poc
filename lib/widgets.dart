import 'dart:io';

import 'package:flutter/material.dart';

import './theme.dart';

class TimelineCard extends StatelessWidget {
  final String title;
  final String description;
  final String formattedDate;
  final String? imagePath;
  final String mood;
  final VoidCallback onTap;

  const TimelineCard({
    super.key,
    required this.title,
    required this.description,
    required this.formattedDate,
    required this.mood,
    this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Profile Block: Image Canvas or Fallback Icon Box
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withAlpha(100),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imagePath != null
                    ? Image.file(File(imagePath!), fit: BoxFit.cover)
                    : Center(
                        child: Icon(
                          Icons.menu_book_outlined,
                          size: 24,
                          color: theme.colorScheme.onSurfaceVariant.withAlpha(
                            100,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // Right Profile Block: Descriptive Metadata Tree
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? "Untitled Entry" : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description.isEmpty
                        ? "No description provided."
                        : description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        formattedDate,
                        style: CustomTheme.toRobotoItalic(
                          theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withAlpha(
                              175,
                            ),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 16,
                        decoration: BoxDecoration(
                          color: CustomTheme.getMoodColor(mood, context),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ZoomableImage extends StatefulWidget {
  final String imagePath;
  final Function(bool) onZoomChanged;

  const ZoomableImage({
    super.key,
    required this.imagePath,
    required this.onZoomChanged,
  });

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTapDetails;
  
  final double _minScale = 1.0;
  final double _maxScale = 3.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        _transformationController.value = _animation!.value;
      });

    _transformationController.addListener(() {
      final currentScale = _transformationController.value.getMaxScaleOnAxis();
      final isZoomed = currentScale > _minScale + 0.05; // 0.05 buffer
      widget.onZoomChanged(isZoomed);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    final position = _doubleTapDetails?.localPosition;
    if (position == null) return;

    final double currentScale = _transformationController.value.getMaxScaleOnAxis();
    final Matrix4 endMatrix;

    if (currentScale > _minScale) {
      // If already zoomed in, zoom out to default
      endMatrix = Matrix4.identity();
    } else {
      // If zoomed out, zoom in exactly where the user tapped
      final x = -position.dx * (_maxScale - 1);
      final y = -position.dy * (_maxScale - 1);
      
      endMatrix = Matrix4.identity()
        ..translate(x, y)
        ..scale(_maxScale);
    }

    _animateToMatrix(endMatrix);
  }

  void _animateToMatrix(Matrix4 endMatrix) {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        maxScale: _maxScale,
        minScale: _minScale,
        clipBehavior: Clip.none,
        child: Center(
          child: Image.file(
            File(widget.imagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}