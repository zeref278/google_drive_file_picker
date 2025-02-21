import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_drive_file_picker/google_drive_file_picker.dart';

void main() {
  runApp(
    const MaterialApp(
      home: GoogleDriveTestApp(),
    ),
  );
}

class GoogleDriveTestApp extends StatefulWidget {
  const GoogleDriveTestApp({
    super.key,
  });

  @override
  State<GoogleDriveTestApp> createState() => _GoogleDriveTestAppState();
}

class _GoogleDriveTestAppState extends State<GoogleDriveTestApp> {
  final GoogleDriveController controller = GoogleDriveController();
  File? _file;

  @override
  void initState() {
    controller.setAPIKey(apiKey: 'your_api_key');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Google drive file picker'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () async {
              final file = await controller.getFileFromGoogleDrive(
                context: context,
              );

              if (file != null) {
                setState(() {
                  _file = file;
                });
              }
            },
            child: const Text(
              'Open google drive',
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            _file?.path ?? '--',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
