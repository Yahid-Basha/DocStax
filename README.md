# DocStax - Comprehensive Document Management App

## Overview
DocStax is a feature-rich mobile application designed for efficient document management and sharing. Built using Flutter and Dart, the app integrates seamlessly with Google Drive and Firebase to provide a robust backend and secure file storage.

## UI

![UI Images 1](https://github.com/Yahid-Basha/DocStax/assets/97111767/908e5f10-ff89-4382-b3e4-c2c89fb13eb8)

![UI images 2](https://github.com/Yahid-Basha/DocStax/assets/97111767/11d96a76-040c-4c20-b000-259dc15ec23a)


## Features
- **Channel Management:**
  - Structured document management with channels for organizing files.
  - Create, list, and manage folders.
  - Display the most recent files and profile images for each folder.

- **Shared with Me:**
  - Access and manage files shared by others.
  - Consistent user experience with similar functionalities as the primary channels.

- **Local Storage Management:**
  - Offline access to downloaded files.
  - Open, share, and manage files directly from the device.
  - Persistent storage using SharedPreferences to track downloaded files.

- **File Operations:**
  - File uploading, downloading, deleting, and sharing.
  - Seamless file operations using Flutter’s file_picker and open_filex packages.

- **Permissions Management:**
  - Advanced sharing capabilities with granular permission settings.
  - Share files with specific individuals or set general access permissions using the Google Drive API.

## Technologies Used
- **Frontend:** Flutter, Dart
- **Backend:** Firebase Authentication, Firebase Storage, Google Drive API
- **Packages and Libraries:** 
  - [open_filex](https://pub.dev/packages/open_filex)
  - [file_picker](https://pub.dev/packages/file_picker)
  - [shared_preferences](https://pub.dev/packages/shared_preferences)
  - [googleapis](https://pub.dev/packages/googleapis)
  - [share_plus](https://pub.dev/packages/share_plus)
- **Tools:** Android Studio, Visual Studio Code, Figma (for UI design)

## Installation and Setup
1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/docstax.git
   cd docstax
   ```


2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Usage
- **Channels:** Create and manage folders, view recent files, and access folder-specific actions.
- **Shared with Me:** View and manage files shared by others.
- **Downloads:** Access files downloaded to local storage, open them, and share with other applications.

## Contributions
Contributions are welcome! Please create an issue or submit a pull request with your changes. Ensure your code adheres to the project's coding standards and passes all tests.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact
For any inquiries or feedback, please contact [yahidbasha@gmail.com](mailto:yahidbasha@gmail.com) and [krishnaveni8v@gmail.com](mailto:krishnaveni8v@gmail.com).
