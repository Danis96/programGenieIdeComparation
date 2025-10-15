import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:programgenieplugins/feedback/feedback_provider.dart';
import 'package:programgenieplugins/feedback/feedback_service.dart';
import 'package:programgenieplugins/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FeedbackProvider())],
      child: const PluginComparisonApp(),
    ),
  );
}

class PluginComparisonApp extends StatelessWidget {
  const PluginComparisonApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IDE Plugin Comparison ProgramGenie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ComparisonPage(),
    );
  }
}

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({Key? key}) : super(key: key);

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  final List<String> sections = [
    'Extension/Plugin View',
    'Toolbar Visibility',
    'After Installation Screen on Chat Open',
    'Insert PAT and Base URL',
    'After PAT Added - Chat Opened',
    'Chat Header',
    'Chat Header History',
  ];

  Map<String, TextEditingController> commentControllers = {};
  Map<String, bool> expandedSections = {};
  Map<String, bool> showFeedbacksSections = {};
  Map<String, String> prewrittenDifferences = {
    'Extension/Plugin View':
        'This is view from settings of respective IDE.\nHere differences can be seen in the way the extension/plugin is shown.\nText description for each IDE is provided in the screenshot and can be easily changed.\nCurrently, the extension/plugin image is not visible in Visual Studio.\nDifference in view are SYSTEM differences and cannot be changed.',
    'Toolbar Visibility': 'The toolbar is SYSTEM difference and cannot be changed.\nOnly Icon can be changed.',
    'After Installation Screen on Chat Open':
        'As images shown below:\n- VS Code opens a new chat window\n- IntelliJ opens a chat settings screen that indicates to user importance of authentication with PAT and Base URL.\n- Visual Studio no images yet.',
    'Insert PAT and Base URL': 'The PAT and base URL are not visible in VS Code and IntelliJ.',
    'After PAT Added - Chat Opened': 'The after PAT added screen is not visible in VS Code and IntelliJ.',
    'Chat Header': 'The chat header is not visible in VS Code and IntelliJ.',
    'Chat Header History': 'The chat header history is not visible in VS Code and IntelliJ.',
  };

  @override
  void initState() {
    super.initState();
    for (var section in sections) {
      commentControllers[section] = TextEditingController();
      expandedSections[section] = true;
      showFeedbacksSections[section] = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final FeedbackProvider feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
      for (var section in sections) {
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
      builder: (context) => Dialog(
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
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
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

  Widget buildImageSection(BuildContext context, String imagePath, String title, Color borderColor, {bool isPlaceholder = false}) {
    return InkWell(
      onTap: isPlaceholder ? null : () => showExpandedImage(context, imagePath, title),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: isPlaceholder ? Colors.grey.shade200 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isPlaceholder ? Colors.grey.shade400 : borderColor, width: 2, style: isPlaceholder ? BorderStyle.solid : BorderStyle.solid),
        ),
        child: isPlaceholder
            ? Center(
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
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
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

  String? _getVSCodeImagePath(String section) {
    switch (section) {
      case 'Extension/Plugin View':
        return 'assets/extension_vscode.png';
      case 'Toolbar Visibility':
        return 'assets/toolbar_vscode.png';
      case 'After Installation Screen on Chat Open':
        return 'assets/after_installation_vscode.png';
      case 'Insert PAT and Base URL':
        return 'assets/insert_pat_vscode.png';
      case 'After PAT Added - Chat Opened':
        return 'assets/after_pat_vscode.png';
      case 'Chat Header':
        return 'assets/chat_header_vscode.png';
      case 'Chat Header History':
        return 'assets/chat_header_history_vscode.png';
      default:
        return null;
    }
  }

  String? _getIntelliJImagePath(String section) {
    switch (section) {
      case 'Extension/Plugin View':
        return 'assets/extension_intellij.png';
      case 'Toolbar Visibility':
        return 'assets/toolbar_intellij.png';
      case 'After Installation Screen on Chat Open':
        return 'assets/after_installation_intellij.png';
      case 'Insert PAT and Base URL':
        return 'assets/insert_pat_intellij.png';
      case 'After PAT Added - Chat Opened':
        return 'assets/after_pat_intellij.png';
      case 'Chat Header':
        return 'assets/chat_header_intellij.png';
      case 'Chat Header History':
        return 'assets/chat_header_history_intellij.png';
      default:
        return null;
    }
  }

  String? _getVisualStudioImagePath(String section) {
    // All Visual Studio images are missing - needs screenshots
    return null;
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
            children: sections.map((section) {
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
                                    _getVSCodeImagePath(section) ?? '',
                                    'VS Code - $section',
                                    Colors.blue.shade300,
                                    isPlaceholder: _getVSCodeImagePath(section) == null,
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
                                    _getIntelliJImagePath(section) ?? '',
                                    'IntelliJ - $section',
                                    Colors.purple.shade300,
                                    isPlaceholder: _getIntelliJImagePath(section) == null,
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
                                    _getVisualStudioImagePath(section) ?? '',
                                    'Visual Studio - $section',
                                    Colors.indigo.shade300,
                                    isPlaceholder: _getVisualStudioImagePath(section) == null,
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
                                child: Text(prewrittenDifferences[section] ?? '', style: const TextStyle(fontStyle: FontStyle.normal, fontSize: 14)),
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
