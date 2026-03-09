import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imagePaths;
  final String title;
  final Color borderColor;

  const ImageSlider({
    super.key,
    required this.imagePaths,
    required this.title,
    required this.borderColor,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color overlayBackground = isDark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.9)
        : scheme.scrim.withValues(alpha: 0.58);
    final Color overlayForeground = isDark
        ? scheme.onSurface
        : scheme.onPrimary;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.borderColor, width: 1.5),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imagePaths.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () => _showExpandedImage(
                  context,
                  widget.imagePaths[index],
                  '${widget.title} (${index + 1}/${widget.imagePaths.length})',
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: widget.imagePaths[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    errorWidget:
                        (
                          BuildContext context,
                          String error,
                          dynamic stackTrace,
                        ) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: scheme.outlineVariant,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Image not found',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.imagePaths[index],
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                  ),
                ),
              );
            },
          ),
          if (widget.imagePaths.length > 1)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: overlayBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: overlayForeground,
                      size: 28,
                    ),
                    onPressed: _currentIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                  ),
                ),
              ),
            ),
          if (widget.imagePaths.length > 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: overlayBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: overlayForeground,
                      size: 28,
                    ),
                    onPressed: _currentIndex < widget.imagePaths.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                  ),
                ),
              ),
            ),
          if (widget.imagePaths.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: overlayBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imagePaths.length}',
                    style: TextStyle(
                      color: overlayForeground,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: overlayBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.zoom_in, color: overlayForeground, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showExpandedImage(
    BuildContext context,
    String imagePath,
    String title,
  ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color overlayBackground = isDark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.9)
        : scheme.scrim.withValues(alpha: 0.72);
    final Color overlayForeground = isDark
        ? scheme.onSurface
        : scheme.onPrimary;

    // Create a separate PageController for the expanded view
    final PageController expandedPageController = PageController(
      initialPage: _currentIndex,
    );
    int expandedCurrentIndex = _currentIndex;

    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${widget.title} (${expandedCurrentIndex + 1}/${widget.imagePaths.length})',
                                  style: TextStyle(
                                    color: scheme.onPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  expandedPageController.dispose();
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: scheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: expandedPageController,
                                onPageChanged: (int index) {
                                  setDialogState(() {
                                    expandedCurrentIndex = index;
                                  });
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                  _pageController.jumpToPage(index);
                                },
                                itemCount: widget.imagePaths.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InteractiveViewer(
                                    panEnabled: true,
                                    boundaryMargin: const EdgeInsets.all(20),
                                    minScale: 0.5,
                                    maxScale: 4,
                                    child: CachedNetworkImage(
                                      imageUrl: widget.imagePaths[index],
                                      fit: BoxFit.contain,
                                      errorWidget:
                                          (
                                            BuildContext context,
                                            String url,
                                            Object error,
                                          ) {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.image_not_supported,
                                                    size: 64,
                                                    color:
                                                        scheme.outlineVariant,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    widget.imagePaths[index],
                                                    style: TextStyle(
                                                      color: scheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                    ),
                                  );
                                },
                              ),
                              if (widget.imagePaths.length > 1)
                                Positioned(
                                  left: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: overlayBackground,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: scheme.shadow.withValues(
                                              alpha: 0.25,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.chevron_left,
                                          color: overlayForeground,
                                          size: 36,
                                        ),
                                        onPressed: expandedCurrentIndex > 0
                                            ? () {
                                                expandedPageController
                                                    .previousPage(
                                                      duration: const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      curve: Curves.easeInOut,
                                                    );
                                              }
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.imagePaths.length > 1)
                                Positioned(
                                  right: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: overlayBackground,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: scheme.shadow.withValues(
                                              alpha: 0.25,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.chevron_right,
                                          color: overlayForeground,
                                          size: 36,
                                        ),
                                        onPressed:
                                            expandedCurrentIndex <
                                                widget.imagePaths.length - 1
                                            ? () {
                                                expandedPageController.nextPage(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.imagePaths.length > 1)
                                Positioned(
                                  bottom: 20,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: overlayBackground,
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: scheme.shadow.withValues(
                                              alpha: 0.25,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '${expandedCurrentIndex + 1} / ${widget.imagePaths.length}',
                                        style: TextStyle(
                                          color: overlayForeground,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
