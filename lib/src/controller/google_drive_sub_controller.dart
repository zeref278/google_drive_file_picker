import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:google_drive_file_picker/src/controller/google_drive_controller.dart';
import 'package:google_drive_file_picker/src/type/google_drive_sorting.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:http/http.dart' as http;

class GoogleDriveSubController extends ChangeNotifier {
  GoogleDriveSubController({
    this.parentId,
  });

  final String? parentId;

  drive.FileList _fileList = drive.FileList();
  drive.FileList get fileList => _fileList;

  String? _keyword;
  String? get keyword => _keyword;

  GoogleDriveSorting sorting = GoogleDriveSorting.none();

  final RefreshController refreshController = RefreshController();

  bool get isRoot => parentId == null;

  String get query =>
      (isRoot
          ? "'root' in parents and trashed = false"
          : "'$parentId' in parents and trashed = false") +
      searchQuery +
      fileTypeQuery;

  String get searchQuery =>
      (_keyword ?? '').isNotEmpty ? "and name contains '$keyword'" : '';

  String get fileTypeQuery {
    final controller = GoogleDriveController();
    final fileType = controller.fileType;
    if (fileType.type != null) {
      return "and (mimeType contains '${fileType.type}' or mimeType contains 'folder')";
    }
    return '';
  }

  void setKeyword(String text) async {
    if ((_keyword ?? '') != text.trim()) {
      _keyword = text.trim().isNotEmpty ? text.trim() : null;

      refreshController.requestRefresh();
    }
  }

  Future<void> load() async {
    final controller = GoogleDriveController();
    final authenticateClient = controller.authenticateClient!;
    final driveApi = drive.DriveApi(authenticateClient);

    try {
      _fileList = await driveApi.files.list(
        pageSize: 100,
        // orderBy: 'name',
        q: query,
      );
      notifyListeners();
    } catch (_) {}

    refreshController.refreshCompleted();
  }

  Future<void> loadMore() async {
    final controller = GoogleDriveController();
    final authenticateClient = controller.authenticateClient!;
    final driveApi = drive.DriveApi(authenticateClient);

    final result = await driveApi.files.list(
      pageSize: 100,
      pageToken: _fileList.nextPageToken,
      q: query,
    );

    _fileList = drive.FileList(
      files: [...?_fileList.files, ...?result.files],
      nextPageToken: result.nextPageToken,
      incompleteSearch: result.incompleteSearch,
      kind: result.kind,
    );

    notifyListeners();
    refreshController.loadComplete();
  }

  Future<io.File?> download(drive.File file) async {
    final controller = GoogleDriveController();
    String fileName = file.name!;
    String fileId = file.id!;
    String fileMimeType = file.mimeType!;

    http.Response? response;

    if (fileMimeType.contains("spreadsheet") && !fileName.contains(".xlsx")) {
      //If the file is a google doc file, export the file as instructed by the google team.
      String url =
          "https://www.googleapis.com/drive/v3/files/${file.id}/export?mimeType=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet&key=${controller.googleDriveApiKey} HTTP/1.1";

      response = await controller.authenticateClient!.get(
        Uri.parse(url),
      );
    } else if (!fileMimeType.contains(".folder")) {
      // If the file is uploaded from somewhere else or if the file is not a google doc file process it with the "Files: Get" process.
      String url =
          "https://www.googleapis.com/drive/v3/files/$fileId?includeLabels=alt%3Dmedia&alt=media&key=${controller.googleDriveApiKey} HTTP/1.1";

      response = await controller.authenticateClient!.get(
        Uri.parse(url),
      );
    }

    if (response != null) {
      // Get temporary application document directory
      final dir = await getTemporaryDirectory();
      // Create custom path, where the downloaded file will be saved. TEMPORARILY
      String path = "${dir.path}/${file.name}";
      // Save the file
      io.File myFile = await io.File(path).writeAsBytes(response.bodyBytes);
      // Returns the files
      return myFile;
    }

    return null;
  }
}
