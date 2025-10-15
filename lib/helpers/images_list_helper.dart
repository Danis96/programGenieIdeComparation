class ImagesListHelper {
  dynamic getVSCodeImagePath(String section) {
    switch (section) {
      case 'Extension/Plugin View':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/extension_vscode.png?updatedAt=1760551402378';
      case 'Toolbar Visibility':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/toolbar_vscode.png?updatedAt=1760551400558';
      case 'After Installation Screen on Chat Open':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/after_installation_vscode.png?updatedAt=1760551400183';
      case 'Insert PAT and Base URL':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/insert_pat_vscode.png?updatedAt=1760551401322';
      case 'After PAT Added - Chat Opened':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/after_pat_vscode.png?updatedAt=1760551401083';
      case 'Chat Header':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/chat_header_vscode.png?updatedAt=1760551400531';
      case 'Chat Header History':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/chat_header_history_vscode.png?updatedAt=1760551401316';
      default:
        return [];
    }
  }

  dynamic getIntelliJImagePath(String section) {
    switch (section) {
      case 'Extension/Plugin View':
        return [
          'https://ik.imagekit.io/9j9bfa4c7h/programGenie/extension_intellij.png?updatedAt=1760551402199',
          'https://ik.imagekit.io/9j9bfa4c7h/programGenie/extension_intellij.png?updatedAt=1760551402199',
          'https://ik.imagekit.io/9j9bfa4c7h/programGenie/extension_intellij.png?updatedAt=1760551402199',
        ];
      case 'Toolbar Visibility':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/toolbar_intellij.png?updatedAt=1760551400464';
      case 'After Installation Screen on Chat Open':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/after_installation_intellij.png?updatedAt=1760551401922';
      case 'Insert PAT and Base URL':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/insert_pat_intellij.png?updatedAt=1760551402056';
      case 'After PAT Added - Chat Opened':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/after_pat_intellij.png?updatedAt=1760551401624';
      case 'Chat Header':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/chat_header_intellij.png?updatedAt=1760551400304';
      case 'Chat Header History':
        return 'https://ik.imagekit.io/9j9bfa4c7h/programGenie/chat_header_history_intellij.png?updatedAt=1760551401187';
      default:
        return [];
    }
  }

  dynamic getVisualStudioImagePath(String section) {
    // All Visual Studio images are missing - needs screenshots
    return [];
  }
}
