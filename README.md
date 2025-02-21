# google\_drive\_file\_picker

`google_drive_file_picker` is a Flutter plugin that allows users to browse, select, and retrieve files from **Google Drive** within a Flutter application. It provides an easy-to-use API for authentication, file listing, selection, and downloading.

## Features

- ✅ **Google Authentication** – Handles OAuth 2.0 authentication.
- 📂 **File Listing** – Fetch files and folders from Google Drive.
- 🔍 **Search & Filter** – Filter files by type, name.
- 📑 **File Selection** – Pick single files.
- ⬇️ **Download Support** – Download selected files.

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

### 2. Configure Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project or use an existing one.
3. Enable the **Google Drive API**.
4. Create OAuth 2.0 credentials (Client ID & Secret).
5. Add necessary scopes for file access.
6. Download the credentials JSON file and configure it in your Flutter project.

---

## Usage

### 1. Authenticate and Initialize

```dart
import 'package:google_drive_file_picker/google_drive_file_picker.dart';

final GoogleDriveFilePicker picker = GoogleDriveFilePicker();
await picker.authenticate();
```

### 2. Pick a File

```dart
final GoogleDriveFile? file = await picker.pickFile();
if (file != null) {
  print("Selected file: ${file.name}");
}
```

### 3. Download a File

```dart
final File localFile = await picker.downloadFile(file);
print("Downloaded file path: ${localFile.path}");
```

---

## Permissions

Make sure to configure the OAuth consent screen and include the necessary **Google Drive API** scopes in your project settings.

### Required Scopes

```yaml
https://www.googleapis.com/auth/drive.file
https://www.googleapis.com/auth/drive.readonly
```

---

## Use Cases

- 📁 **Cloud Storage Access** – Retrieve user files stored in Google Drive.
- 📜 **Document Management** – Fetch and process PDFs, images, and other file formats.
- 🔄 **Backup & Restore** – Save app data in Google Drive for backup purposes.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributions

Contributions are welcome! Feel free to open an issue or submit a pull request.

---

## Contact

For questions or support, reach out via [GitHub Issues](https://github.com/your-repo/google_drive_file_picker/issues).

