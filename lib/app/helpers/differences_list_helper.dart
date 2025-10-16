class DifferencesListHelper {
  Map<String, String> prewrittenDifferences = {
    'Extension/Plugin View':
        'This is view from settings of respective IDE.\nHere differences can be seen in the way the extension/plugin is shown.\nText description for each IDE is provided in the screenshot and can be easily changed.\nCurrently, the extension/plugin image is not visible in Visual Studio.\nDifference in view are SYSTEM differences and cannot be changed.\n- Text content can be changed if needed.',
    'Toolbar Visibility':
        'The toolbar is SYSTEM difference and cannot be changed.\n- Only Icon can be changed.\n- Second image shows the toolbar opened and we can see difference in the way icon is shown.',
    'After Installation Screen on Chat Open':
        'As images shown below:\n- VS Code opens a new chat window\n- IntelliJ opens a chat settings screen that indicates to user importance of authentication with PAT and Base URL.\n- Visual Studio no images yet.\n- In VS Code user will found out about PAT when he starts to communicate with Genie.',
    'Insert PAT and Base URL':
        '- First diffferences are SYSTEM differences in the way PAT and Base URL are shown.\n- Second difference is in the way Base URL is shown when it is empty.\n- Third difference is in the way PAT is shown when it is empty.\n- Fourth difference is in the way Base URL is shown when it is in error.\n- Fifth difference is in the way PAT is shown when it is in error.\n- Sixth difference is in the way PAT is shown when it is successfully added.\n- Intellij also has visibility of PAT in the settings screen, while vs code does not.',
    'After PAT Added - Chat Opened': '- No difference in the way chat is opened in VS Code and IntelliJ.',
    'Chat Header':
        '- First difference is in the positioning of elements in header.\n- When showing new chat difference is in representation, New Chat and Chat + time.\n- Different way of deleting history chat session (delete icon in header) or (delete icon in history list).\n- In Intellij you can access settings from header in vs code you can not.\n- VS code shows number of messages while Intellij is not.\n- Difference in the way when accesing history (dropdown) or (icon).\n- New Chat option in VS Code creates new chat session, while Intellij creates new session when Genie communication is accomplished.',
    'Chat Header History':
        '- Difference in design of list items.\n- VS Code has search functionality while Intellij does not.\n- VS Code shows date of chat session while Intellij does not.\n- Also as we mentioned above, in Intellij you can delete chat session from history list, while in vs code you do that from header.\n- History session is recorded by projects in Intellij.\n- Intellij can delete last chat session from history list, while VS Code can not.',
    'User Messages':
        '- Difference in width of user message.\n- Intellij shows timestamp, while vs code does not.\n- When we have long messages, Intellij has option to expand/collapse while vscode shows longer message bubble.\n- Intellij shows products, artifacts and documents as chips in user message while vs code does not show them in user bubble.\n- Intellij can copy entire message content with copy button.\n- In Intellij user message is always blue, it does not depend on theme change.',
    'Assistant Messages':
        '- Intellij shows border around message bubble, while vs code does not.\n- Intellij shows timestamp, while vs code does not.\n- Difference in code block header options.\n- Intellij has option to expand/collapse, while vs code does not.\n- Intellij has option to apply code from chat while vs code does not.\n- Difference in showing token revoked error message. (text)\n- Inline code is colored blue in Intellij.',
    'Chat Input':
        '- Difference in element positioning in chat input.\n- Difference in chat input placeholder text.\n- Difference in chat input header.\n- Difference in @ color.\n- Intellij has upload document option, while vs code does not.\n- VS Code shows loader on button while Intellij does not.\n- Difference in buttons.\n- Difference in long text input.\n- Difference in presenting chips prod&artifacts in chat input header.\n- Difference in presenting long number of chips.\n- Intellij shows document chip and picker, while vs code does not.\n- Intellij has blue border around input panel.',
    'Chat Panel':
        '- Difference in new chat empty state text.\n- Difference in loading state.\n- VS Code shows loader on button while Intellij does not, as we mentioned above.\n- Difference in chat panel positioning vs code left, while intellij is positioned right.\n- In VS Code user can resize chat panel and close it when it comes to specific size, while Intellij does not.',
    'Product & Artifacts':
        '- Difference in popup position.\n- Difference in design of elements items.\n- Difference in item when state is selected.\n- Difference in text when no artifacts found.\n- Difference in showing token expired error message.\n- In Intellij is shown number of pages and products/artifacts.\n- Intellij can move and resize product and artifact window.',
    'Right Click Actions':
        "- Intellij after selection and choosing action shows appropriate prompt and selected code in user message bubble, while VS Code does that in background and shows user notification with message while waiting for reply.\n- Intellij let's you to choose actions even if you did not select any code, and you will send whole active file while when pressed on actions.\n- Intellij prompts for appropriate actions can be changed if needed.",
    'Artifacts Preview':
        '- Both IDEs shown preview in separate window tab.\n- Both cover all types of artifacts.\n- VS Code has Editor option for React, while Intellij does not, because of purpose use.',
  };
}
