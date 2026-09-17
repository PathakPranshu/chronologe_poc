import 'dart:io';
import 'dart:ui';

import 'package:chronologe_poc/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImagePreview extends StatefulWidget {
  final List<String> carouselImagePath;
  final int currentImageIndex;
  const ImagePreview({
    super.key,
    this.carouselImagePath = const [],
    this.currentImageIndex = 0,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  List<String> carouselImagePaths = [];
  late final PageController _pageController;
  bool _isZoomedIn = false;
  bool _isAppBarVisible = true;

  @override
  void initState() {
    carouselImagePaths = widget.carouselImagePath;
    _pageController = PageController(initialPage: widget.currentImageIndex);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _isAppBarVisible
          ? AppBar(
            animateColor: true,
              leading: IconButton(
                onPressed: () {
                  //Restore System UI before leaving the screen
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              backgroundColor: theme.colorScheme.surface.withAlpha(0),
              elevation: 0,
              flexibleSpace: ClipRect(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withAlpha(120),
                        offset: Offset(0, -75),
                        blurRadius: 20,
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isAppBarVisible = !_isAppBarVisible;
          });

          if (_isAppBarVisible) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          } else {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: carouselImagePaths.length,
          physics: _isZoomedIn
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          itemBuilder: (context, index) {
            return ZoomableImage(
              imagePath: carouselImagePaths[index],
              onZoomChanged: (isZoomed) {
                setState(() {
                  _isZoomedIn = isZoomed;
                });
              },
            );
          },
        ),
      ),
    );
  }
}
