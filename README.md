# google_drive_file_picker

`google_drive_file_picker` is a Flutter plugin that allows users to browse, select, and retrieve files from **Google Drive** within a Flutter application. It provides an easy-to-use API for authentication, file listing, selection, and downloading.

## Features

- ✅ **Google Authentication** – Handles OAuth 2.0 authentication.
- 📂 **File Listing** – Fetch files and folders from Google Drive.
- 🔍 **Search & Filter** – Filter files by type, name.
- 📑 **File Selection** – Pick single files.
- ⬇️ **Download Support** – Download selected files.

---

## Showcase

Here are some screenshots of the plugin in action:

<img src="https://raw.githubusercontent.com/zeref278/google_drive_file_picker/main/attachments/video.MP4" width="300"/>

<img src="https://raw.githubusercontent.com/zeref278/google_drive_file_picker/main/attachments/image_1.PNG" width="300"/>
<img src="https://raw.githubusercontent.com/zeref278/google_drive_file_picker/main/attachments/image_2.PNG" width="300"/>


---

## Installation

### 1. Add Dependency

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  google_drive_file_picker: latest_version
```

Run the following command:

```sh
flutter pub get
```

### 2. Setup Sign In Google
https://pub.dev/packages/google_sign_in

### 3. Configure Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project or use an existing one.
3. Enable the **Google Drive API**.
4. CREATE NEW CREDENTIAL (API KEY)

---

## Usage

### 1. Set API Key

```dart
import 'package:google_drive_file_picker/google_drive_file_picker.dart';

final GoogleDriveController controller = GoogleDriveController();
controller.setAPIKey(apiKey: 'your_api_key');
```

### 2. Pick a File

```dart
final file = await controller.getFileFromGoogleDrive(
  context: context,
);
```

---

## Permissions

Make sure to configure the OAuth consent screen and include the necessary **Google Drive API** scopes in your project settings.

### Required Scopes

```yaml
https://www.googleapis.com/auth/drive.readonly
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributions

Contributions are welcome! Feel free to open an issue or submit a pull request.

---

## Contact

For questions or support, reach out via [GitHub Issues](https://github.com/zeref278/google_drive_file_picker/issues).
