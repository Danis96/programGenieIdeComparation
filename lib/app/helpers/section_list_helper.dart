class SectionListHelper {
  static final List<String> v1Sections = [
    'Extension/Plugin View',
    'Toolbar Visibility',
    'After Installation Screen on Chat Open',
    'Insert PAT and Base URL',
    'After PAT Added - Chat Opened',
    'Chat Header',
    'Chat Header History',
    'User Messages',
    'Assistant Messages',
    'Chat Input',
    'Chat Panel',
    'Product & Artifacts',
    'Right Click Actions',
    'Artifacts Preview',
  ];

  static final List<String> v2Sections = [
    'Genie Rules',
    'Session Rename',
    'Search history sessions',
    'Welcome message - empty state',
    'Session filter tags',
    'Error console action',
    'Run terminal action',
    'Reasoning Effort and Content',
    'Genie Web Search',
    'Genie Vision',
  ];

  static List<String> forVersion(int version) {
    if (version == 2) {
      return v2Sections;
    }
    return v1Sections;
  }
}
