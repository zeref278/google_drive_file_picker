import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_drive_file_picker/google_drive_file_picker.dart';
import 'package:google_drive_file_picker/src/google_drive_screen.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

typedef FolderBuilder = Widget Function(drive.File);
typedef FileBuilder = Widget Function(drive.File);

class GoogleDriveController {
  GoogleDriveController._internal();
  static final GoogleDriveController _googleDriveHandler =
      GoogleDriveController._internal();
  factory GoogleDriveController() => _googleDriveHandler;

  google_sign_in.GoogleSignInAccount? account;

  String? _googleDriveApiKey;

  String? get googleDriveApiKey => _googleDriveApiKey;

  Map<String, String>? authHeaders;

  GoogleAuthClient? authenticateClient;

  GoogleDriveFileType _fileType = GoogleDriveFileType.all();
  GoogleDriveFileType get fileType => _fileType;

  setAPIKey({
    required String apiKey,
  }) {
    _googleDriveApiKey = apiKey;
  }

  Future getFileFromGoogleDrive({
    required BuildContext context,
    GoogleDriveFileType? fileType,
    FolderBuilder? folderBuilder,
    FileBuilder? fileBuilder,
  }) async {
    if (_googleDriveApiKey != null) {
      _fileType = fileType ?? GoogleDriveFileType.all();
      await _signIn();
      if (account != null) {
        authHeaders = await account!.authHeaders;
        authenticateClient = GoogleAuthClient(authHeaders!);
        return await _openGoogleDriveScreen(context);
      } else {
        log("Google Signin was declined by the user!");
      }
    } else {
      log('GOOGLEDRIVEAPIKEY has not yet been set. Please follow the documentation and call GoogleDriveHandler().setApiKey(YourAPIKey); to set your own API key');
    }
  }

  _openGoogleDriveScreen(BuildContext context) async {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GoogleDriveScreen(
          parentName: account?.displayName ?? 'Google drive',
        ),
        settings: const RouteSettings(
          name: '/google_drive',
        ),
      ),
    );
  }

  Future _signIn() async {
    final googleSignIn = google_sign_in.GoogleSignIn.standard(
      scopes: [drive.DriveApi.driveReadonlyScope],
    );
    account = await googleSignIn.signIn();
    return;
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
