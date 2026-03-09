import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:programgenieplugins/app/feedback/feedback_provider.dart';
import 'package:programgenieplugins/app/feedback/feedback_service.dart';
import 'package:programgenieplugins/app/helpers/differences_list_helper.dart';
import 'package:programgenieplugins/app/helpers/images_list_helper.dart';
import 'package:programgenieplugins/app/helpers/section_list_helper.dart';
import 'package:programgenieplugins/widgets/custom_image_slider.dart';
import 'package:provider/provider.dart';

enum ComparisonVersion { v1, v2 }

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({
    super.key,
    required this.themeMode,
    required this.onToggleThemeMode,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleThemeMode;

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  ComparisonVersion selectedVersion = ComparisonVersion.v1;
  Map<String, TextEditingController> commentControllers = {};
  Map<String, bool> expandedSections = {};
  Map<String, bool> showFeedbacksSections = {};
  final ImagesListHelper imagesListHelper = ImagesListHelper();
  final DifferencesListHelper differencesListHelper = DifferencesListHelper();

  int get selectedVersionNumber =>
      selectedVersion == ComparisonVersion.v1 ? 1 : 2;

  String get selectedVersionLabel =>
      selectedVersion == ComparisonVersion.v1 ? 'Version 1' : 'Version 2';

  String get selectedVersionMonthLabel {
    switch (selectedVersion) {
      case ComparisonVersion.v1:
        return 'November';
      case ComparisonVersion.v2:
        return 'March';
    }
  }

  String _segmentKey(String section) => '$selectedVersionLabel::$section';

  List<String> _segmentKeysForSection(String section) {
    final String currentKey = _segmentKey(section);
    if (selectedVersion == ComparisonVersion.v1) {
      // Backward compatibility: older feedbacks were stored under plain section name.
      return [currentKey, section];
    }
    return [currentKey];
  }

  Future<void> _loadFeedbacksForSection(
    FeedbackProvider feedbackProvider,
    String section,
  ) async {
    for (final String key in _segmentKeysForSection(section)) {
      await feedbackProvider.loadFeedbacksBySegment(key);
    }
  }

  List<FeedbackModel> _combinedFeedbacksForSection(
    FeedbackProvider feedbackProvider,
    String section,
  ) {
    final Map<String, FeedbackModel> byId = <String, FeedbackModel>{};
    for (final String key in _segmentKeysForSection(section)) {
      for (final FeedbackModel feedback in feedbackProvider.getFeedbacksForSegment(key)) {
        byId[feedback.id] = feedback;
      }
    }
    final List<FeedbackModel> feedbacks = byId.values.toList();
    feedbacks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return feedbacks;
  }

  List<String> get _currentSections =>
      SectionListHelper.forVersion(selectedVersionNumber);

  Color _surfaceTint(ColorScheme scheme, double opacity) {
    return Color.alphaBlend(
      scheme.primary.withValues(alpha: opacity),
      scheme.surface,
    );
  }

  Color _ideTint(BuildContext context, String ide) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    switch (ide) {
      case 'vscode':
        return Color.alphaBlend(
          Colors.blue.withValues(alpha: 0.14),
          scheme.surfaceContainerHigh,
        );
      case 'intellij':
        return Color.alphaBlend(
          Colors.pink.withValues(alpha: 0.12),
          scheme.surfaceContainerHigh,
        );
      default:
        return Color.alphaBlend(
          Colors.indigo.withValues(alpha: 0.13),
          scheme.surfaceContainerHigh,
        );
    }
  }

  Color _ideBorder(String ide) {
    switch (ide) {
      case 'vscode':
        return Colors.blue.shade400;
      case 'intellij':
        return Colors.purple.shade400;
      default:
        return Colors.indigo.shade400;
    }
  }

  Future<void> _loadFeedbacksForCurrentVersion() async {
    final FeedbackProvider feedbackProvider = Provider.of<FeedbackProvider>(
      context,
      listen: false,
    );
    for (final String section in _currentSections) {
      await _loadFeedbacksForSection(feedbackProvider, section);
    }
  }

  void _ensureSectionState(List<String> sections) {
    for (final String section in sections) {
      commentControllers.putIfAbsent(section, TextEditingController.new);
      expandedSections.putIfAbsent(section, () => true);
      showFeedbacksSections.putIfAbsent(section, () => false);
    }
  }

  @override
  void initState() {
    super.initState();
    _ensureSectionState(SectionListHelper.v1Sections);
    _ensureSectionState(SectionListHelper.v2Sections);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeedbacksForCurrentVersion();
    });
  }

  @override
  void dispose() {
    for (final TextEditingController controller in commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void showExpandedImage(BuildContext context, String imagePath, String title) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
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
                              title,
                              style: TextStyle(
                                color: scheme.onPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: scheme.onPrimary),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.5,
                        maxScale: 4,
                        child: CachedNetworkImage(
                          imageUrl: imagePath,
                          fit: BoxFit.contain,
                          errorWidget:
                              (BuildContext context, String url, Object error) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 64,
                                        color: scheme.outlineVariant,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        imagePath,
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageSection(
    BuildContext context,
    dynamic imagePaths,
    String title,
    Color borderColor, {
    bool isPlaceholder = false,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color overlayBackground = isDark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.9)
        : scheme.scrim.withValues(alpha: 0.56);
    final Color overlayForeground = isDark
        ? scheme.onSurface
        : scheme.onPrimary;

    final List<String> imageList = imagePaths is List<String>
        ? imagePaths
        : (imagePaths is String ? [imagePaths] : []);

    // If no images or placeholder
    if (isPlaceholder || imageList.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.outlineVariant, width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 64,
                color: scheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Image Not Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Screenshot needed for:\n$title',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (imageList.length == 1) {
      final String imagePath = imageList[0];
      return InkWell(
        onTap: () => showExpandedImage(context, imagePath, title),
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  errorWidget:
                      (BuildContext context, String url, Object error) {
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
                                imagePath,
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
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: overlayBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.zoom_in,
                    color: overlayForeground,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ImageSlider(
      imagePaths: imageList,
      title: title,
      borderColor: borderColor,
    );
  }

  Widget _buildVersionSelector(ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Version 1'),
            selected: selectedVersion == ComparisonVersion.v1,
            onSelected: (bool selected) async {
              if (!selected || selectedVersion == ComparisonVersion.v1) {
                return;
              }
              setState(() {
                selectedVersion = ComparisonVersion.v1;
              });
              await _loadFeedbacksForCurrentVersion();
            },
          ),
          ChoiceChip(
            label: const Text('Version 2'),
            selected: selectedVersion == ComparisonVersion.v2,
            onSelected: (bool selected) async {
              if (!selected || selectedVersion == ComparisonVersion.v2) {
                return;
              }
              setState(() {
                selectedVersion = ComparisonVersion.v2;
              });
              await _loadFeedbacksForCurrentVersion();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          'IDE Plugin Comparison ProgramGenie - $selectedVersionLabel • $selectedVersionMonthLabel',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        toolbarHeight: 80,
        actions: [
          IconButton(
            tooltip: 'Switch theme',
            onPressed: widget.onToggleThemeMode,
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : widget.themeMode == ThemeMode.light
                  ? Icons.light_mode
                  : Icons.brightness_auto,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 82),
                  ..._currentSections.map((section) {
                final String segmentKey = _segmentKey(section);
                final bool isExpanded = expandedSections[section] ?? true;
                final dynamic vscodeImagePaths = imagesListHelper
                    .getVSCodeImagePath(
                      section,
                      version: selectedVersionNumber,
                    );
                final dynamic intellijImagePaths = imagesListHelper
                    .getIntelliJImagePath(
                      section,
                      version: selectedVersionNumber,
                    );
                final dynamic visualStudioImagePaths = imagesListHelper
                    .getVisualStudioImagePath(
                      section,
                      version: selectedVersionNumber,
                    );

                return Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(
                          alpha: isDark ? 0.18 : 0.08,
                        ),
                        blurRadius: isDark ? 12 : 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header with Collapse Button
                      InkWell(
                        onTap: () {
                          setState(() {
                            expandedSections[section] = !isExpanded;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _surfaceTint(scheme, isDark ? 0.55 : 0.84),
                                _surfaceTint(scheme, isDark ? 0.78 : 0.96),
                              ],
                            ),
                            borderRadius: isExpanded
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  )
                                : BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  section,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: scheme.onPrimary,
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Collapsible Content
                      if (isExpanded) ...[
                        // Horizontal Layout: VSCode | IntelliJ | Visual Studio
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // VS Code Column
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _ideTint(context, 'vscode'),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _ideBorder('vscode'),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/Visual_Studio_Code_1.35_icon.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'VS Code',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: scheme.onSurface,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    buildImageSection(
                                      context,
                                      vscodeImagePaths,
                                      'VS Code - $section',
                                      _ideBorder('vscode'),
                                      isPlaceholder: vscodeImagePaths == null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // IntelliJ Column
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _ideTint(context, 'intellij'),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _ideBorder('intellij'),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/JetBrains_IntelliJ_IDEA_Product_Icon.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'IntelliJ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: scheme.onSurface,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    buildImageSection(
                                      context,
                                      intellijImagePaths,
                                      'IntelliJ - $section',
                                      _ideBorder('intellij'),
                                      isPlaceholder: intellijImagePaths == null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Visual Studio Column
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _ideTint(
                                          context,
                                          'visualstudio',
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _ideBorder('visualstudio'),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/Visual_Studio_Icon_2022.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Visual Studio',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: scheme.onSurface,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    buildImageSection(
                                      context,
                                      visualStudioImagePaths,
                                      'Visual Studio - $section',
                                      _ideBorder('visualstudio'),
                                      isPlaceholder:
                                          visualStudioImagePaths == null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Differences & Boss Comments
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: scheme.outlineVariant,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Pre-written Differences
                                Text(
                                  'Differences:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: scheme.surface,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: scheme.outlineVariant,
                                    ),
                                  ),
                                  child: Text(
                                    differencesListHelper.getDifferences(
                                      section,
                                      version: selectedVersionNumber,
                                    ),
                                    style: const TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Boss Comment
                                Text(
                                  "Feedback:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: commentControllers[section],
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'Add feedback here...',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Submit Feedback Button
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final String comment =
                                              commentControllers[section]!.text;
                                          if (comment.trim().isNotEmpty) {
                                            final feedbackProvider =
                                                Provider.of<FeedbackProvider>(
                                                  context,
                                                  listen: false,
                                                );
                                            await feedbackProvider.addFeedback(
                                              segmentKey,
                                              comment,
                                            );

                                            if (feedbackProvider.error ==
                                                null) {
                                              commentControllers[section]!
                                                  .clear();

                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Feedback submitted for "$section" ($selectedVersionLabel)',
                                                    ),
                                                    backgroundColor:
                                                        scheme.primary,
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              }

                                              // Reload feedbacks for this section
                                              await _loadFeedbacksForSection(
                                                feedbackProvider,
                                                section,
                                              );
                                            } else {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error: ${feedbackProvider.error}',
                                                    ),
                                                    backgroundColor:
                                                        scheme.error,
                                                    duration: const Duration(
                                                      seconds: 3,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.send),
                                        label: const Text(
                                          'Submit Feedback',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: scheme.primary,
                                          foregroundColor: scheme.onPrimary,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Show/Hide Feedbacks Button
                                    Consumer<FeedbackProvider>(
                                      builder: (context, feedbackProvider, child) {
                                        final int count =
                                            _combinedFeedbacksForSection(
                                              feedbackProvider,
                                              section,
                                            ).length;

                                        return ElevatedButton(
                                          onPressed: () async {
                                            setState(() {
                                              showFeedbacksSections[section] =
                                                  !(showFeedbacksSections[section] ??
                                                      false);
                                            });

                                            if (showFeedbacksSections[section] ==
                                                true) {
                                              await _loadFeedbacksForSection(
                                                feedbackProvider,
                                                section,
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                scheme.secondaryContainer,
                                            foregroundColor:
                                                scheme.onSecondaryContainer,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                showFeedbacksSections[section] ==
                                                        true
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                showFeedbacksSections[section] ==
                                                        true
                                                    ? 'Hide Feedbacks'
                                                    : 'Show Feedbacks${count > 0 ? ' ($count)' : ''}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Display Feedbacks Section
                        if (showFeedbacksSections[section] == true)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Consumer<FeedbackProvider>(
                              builder: (context, feedbackProvider, child) {
                                final List<FeedbackModel> feedbacks =
                                    _combinedFeedbacksForSection(
                                      feedbackProvider,
                                      section,
                                    );

                                if (feedbackProvider.isLoading) {
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: scheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: scheme.outlineVariant,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (feedbacks.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: scheme.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: scheme.outlineVariant,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.feedback_outlined,
                                            size: 48,
                                            color: scheme.outlineVariant,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'No feedbacks yet for this section',
                                            style: TextStyle(
                                              color: scheme.onSurfaceVariant,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: scheme.outlineVariant,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.feedback,
                                            color: scheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Previous Feedbacks (${feedbacks.length})',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: scheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ...feedbacks.map((
                                        FeedbackModel feedback,
                                      ) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: scheme.surface,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: scheme.outlineVariant,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: scheme.shadow.withValues(
                                                  alpha: 0.08,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.comment,
                                                    size: 16,
                                                    color: scheme.primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      feedback.comment,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 12,
                                                    color:
                                                        scheme.onSurfaceVariant,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatTimestamp(
                                                      feedback.timestamp,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: scheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ],
                  ),
                );
                  }),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: scheme.surface,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: _buildVersionSelector(scheme),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
