import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:programgenieplugins/feedback/feedback_provider.dart';
import 'package:programgenieplugins/feedback/feedback_service.dart';
import 'package:programgenieplugins/helpers/differences_list_helper.dart';
import 'package:programgenieplugins/helpers/images_list_helper.dart';
import 'package:programgenieplugins/helpers/section_list_helper.dart';
import 'package:programgenieplugins/widgets/custom_image_slider.dart';
import 'package:provider/provider.dart';

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({Key? key}) : super(key: key);

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  Map<String, TextEditingController> commentControllers = {};
  Map<String, bool> expandedSections = {};
  Map<String, bool> showFeedbacksSections = {};
  final ImagesListHelper imagesListHelper = ImagesListHelper();
  final DifferencesListHelper differencesListHelper = DifferencesListHelper();

  @override
  void initState() {
    super.initState();
    for (var section in SectionListHelper.sections) {
      commentControllers[section] = TextEditingController();
      expandedSections[section] = true;
      showFeedbacksSections[section] = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final FeedbackProvider feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
      for (var section in SectionListHelper.sections) {
        feedbackProvider.loadFeedbacksBySegment(section);
      }
    });
  }

  @override
  void dispose() {
    commentControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void showExpandedImage(BuildContext context, String imagePath, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9, maxHeight: MediaQuery.of(context).size.height * 0.9),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
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
                          errorWidget: (BuildContext context, String url, Object error) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(imagePath, style: TextStyle(color: Colors.grey.shade600)),
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

  Widget buildImageSection(BuildContext context, dynamic imagePaths, String title, Color borderColor, {bool isPlaceholder = false}) {
    final List<String> imageList = imagePaths is List<String> ? imagePaths : (imagePaths is String ? [imagePaths] : []);

    // If no images or placeholder
    if (isPlaceholder || imageList.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Image Not Available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Screenshot needed for:\n$title',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
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
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 2),
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
                  errorWidget: (BuildContext context, String url, Object error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Image not found',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            imagePath,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
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
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ImageSlider(imagePaths: imageList, title: title, borderColor: borderColor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('IDE Plugin Comparison ProgramGenie', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: SectionListHelper.sections.map((section) {
              final bool isExpanded = expandedSections[section] ?? true;

              return Container(
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
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
                          gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade900]),
                          borderRadius: isExpanded
                              ? const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))
                              : BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                section,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white, size: 32),
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
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.shade300, width: 2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/Visual_Studio_Code_1.35_icon.png', width: 24, height: 24),
                                        const SizedBox(width: 8),
                                        Text(
                                          'VS Code',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  buildImageSection(
                                    context,
                                    imagesListHelper.getVSCodeImagePath(section) ?? '',
                                    'VS Code - $section',
                                    Colors.blue.shade300,
                                    isPlaceholder: imagesListHelper.getVSCodeImagePath(section) == null,
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
                                      color: Colors.purple.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.purple.shade300, width: 2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/JetBrains_IntelliJ_IDEA_Product_Icon.png', width: 24, height: 24),
                                        const SizedBox(width: 8),
                                        Text(
                                          'IntelliJ',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  buildImageSection(
                                    context,
                                    imagesListHelper.getIntelliJImagePath(section) ?? '',
                                    'IntelliJ - $section',
                                    Colors.purple.shade300,
                                    isPlaceholder: imagesListHelper.getIntelliJImagePath(section) == null,
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
                                      color: Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.indigo.shade300, width: 2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/Visual_Studio_Icon_2022.png', width: 24, height: 24),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Visual Studio',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  buildImageSection(
                                    context,
                                    imagesListHelper.getVisualStudioImagePath(section) ?? '',
                                    'Visual Studio - $section',
                                    Colors.indigo.shade300,
                                    isPlaceholder: imagesListHelper.getVisualStudioImagePath(section) == null,
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
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade300, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pre-written Differences
                              Text(
                                'Differences:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Text(
                                  differencesListHelper.prewrittenDifferences[section] ?? '',
                                  style: const TextStyle(fontStyle: FontStyle.normal, fontSize: 14),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Boss Comment
                              Text(
                                "Feedback:",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: commentControllers[section],
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Add feedback here...',
                                  filled: true,
                                  fillColor: Colors.yellow.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(color: Colors.yellow.shade300, width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(color: Colors.yellow.shade300, width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Submit Feedback Button
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final String comment = commentControllers[section]!.text;
                                        if (comment.trim().isNotEmpty) {
                                          final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
                                          await feedbackProvider.addFeedback(section, comment);

                                          if (feedbackProvider.error == null) {
                                            commentControllers[section]!.clear();

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Feedback submitted for "$section"'),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            }

                                            // Reload feedbacks for this section
                                            await feedbackProvider.loadFeedbacksBySegment(section);
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: ${feedbackProvider.error}'),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.send),
                                      label: const Text('Submit Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Show/Hide Feedbacks Button
                                  Consumer<FeedbackProvider>(
                                    builder: (context, feedbackProvider, child) {
                                      final int count = feedbackProvider.getFeedbackCountForSegmentSync(section);

                                      return ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            showFeedbacksSections[section] = !(showFeedbacksSections[section] ?? false);
                                          });

                                          if (showFeedbacksSections[section] == true) {
                                            await feedbackProvider.loadFeedbacksBySegment(section);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade600,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(showFeedbacksSections[section] == true ? Icons.visibility_off : Icons.visibility),
                                            const SizedBox(width: 8),
                                            Text(
                                              showFeedbacksSections[section] == true ? 'Hide Feedbacks' : 'Show Feedbacks${count > 0 ? ' ($count)' : ''}',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                              final List<FeedbackModel> feedbacks = feedbackProvider.getFeedbacksForSegment(section);

                              if (feedbackProvider.isLoading) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade300, width: 2),
                                  ),
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              }

                              if (feedbacks.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300, width: 2),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.feedback_outlined, size: 48, color: Colors.grey.shade400),
                                        const SizedBox(height: 8),
                                        Text('No feedbacks yet for this section', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.shade300, width: 2),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.feedback, color: Colors.blue.shade900),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Previous Feedbacks (${feedbacks.length})',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ...feedbacks.map((FeedbackModel feedback) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blue.shade200),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.comment, size: 16, color: Colors.blue.shade700),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(feedback.comment, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                                                const SizedBox(width: 4),
                                                Text(_formatTimestamp(feedback.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
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
            }).toList(),
          ),
        ),
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
