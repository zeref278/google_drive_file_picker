import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_drive_file_picker/src/controller/google_drive_sub_controller.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class GoogleDriveScreen extends StatefulWidget {
  const GoogleDriveScreen({
    super.key,
    this.parentId,
    this.parentName,
  });

  final String? parentId;
  final String? parentName;

  @override
  State<GoogleDriveScreen> createState() => _GoogleDriveScreenState();
}

class _GoogleDriveScreenState extends State<GoogleDriveScreen> {
  late final GoogleDriveSubController controller;

  Timer? _timer;
  bool showSearchTextForm = false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isDownloading = false;

  @override
  void initState() {
    controller = GoogleDriveSubController(
      parentId: widget.parentId,
    )..load();
    super.initState();
  }

  onSearchFieldChange(String val) {
    _timer?.cancel();
    _timer = Timer(
      const Duration(milliseconds: 300),
      () {
        if (mounted) {
          controller.setKeyword(val);
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: Colors.black,
          ),
        ),
        title: showSearchTextForm
            ? TextFormField(
                controller: searchController,
                focusNode: focusNode,
                // textAlignVertical: TextAlignVertical.center,
                onChanged: (String value) {
                  onSearchFieldChange(value);
                },
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  hintText: "Search",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                ),
              )
            :
            //Default title widget
            Text(
                widget.parentName ?? '--',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showSearchTextForm = !showSearchTextForm;
                if (!showSearchTextForm) {
                  controller.setKeyword('');
                  searchController.clear();
                  focusNode.unfocus();
                } else {
                  focusNode.requestFocus();
                }
              });
            },
            icon: Icon(
              showSearchTextForm ? Icons.close : Icons.search,
              size: 18,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: ListenableBuilder(
                listenable: controller,
                builder: (context, child) {
                  final fileList = controller.fileList;

                  if (fileList.files?.isEmpty ?? true) {
                    return const Center(
                      child: Column(
                        children: [
                          SizedBox(height: 100),
                          CircularProgressIndicator(),
                          Text('Loading data'),
                        ],
                      ),
                    );
                  }

                  return SmartRefresher(
                    controller: controller.refreshController,
                    enablePullDown: true,
                    onRefresh: () {
                      controller.load();
                    },
                    enablePullUp: fileList.nextPageToken?.isNotEmpty ?? false,
                    onLoading: () {
                      controller.loadMore();
                    },
                    child: ListView.builder(
                      itemCount: fileList.files!.toList().length,
                      itemBuilder: ((context, index) {
                        File file = fileList.files!.toList()[index];

                        return file.mimeType!.contains(".folder")
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10,
                                  left: 4,
                                  right: 4,
                                ),
                                child: GestureDetector(
                                  onTap: () async {},
                                  child: _FolderCard(
                                    folder: file,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10,
                                  left: 4,
                                  right: 4,
                                ),
                                child: _ItemCard(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => DownloadAlertDialog(
                                        fileName: file.name ?? "NO-FILE-NAME",
                                        callBackFunction: () async {
                                          await _onItemTap(file);
                                        },
                                      ),
                                    );
                                  },
                                  file: file,
                                  index: index,
                                ),
                              );
                      }),
                    ),
                  );
                }),
          ),
          isDownloading
              ? const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Future<void> _onItemTap(File file) async {
    setState(() {
      isDownloading = true;
    });

    final fileDownloaded = await controller.download(
      file,
    );

    setState(() {
      isDownloading = false;
    });

    if (fileDownloaded != null) {
      Navigator.popUntil(context, ModalRoute.withName('/google_drive'));
      Navigator.pop(context, fileDownloaded);
    }
  }
}

class _ItemCard extends StatelessWidget {
  _ItemCard({
    super.key,
    required this.file,
    required this.index,
    required this.onPressed,
  });

  final int index;
  final File file;
  final VoidCallback onPressed;

  // Add other mimeTypes here
  final List<String> videoFileExt = ["video/mp4", "audio/mp4"];
  final List<String> powerpointExt = [
    "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "application/vnd.google-apps.presentation"
  ];
  final List<String> pdfExt = ["application/pdf"];
  final List<String> picExt = ["image/jpeg"];

  @override
  Widget build(BuildContext context) {
    IconData displayIcon = videoFileExt.contains(file.mimeType)
        ? Icons.video_file
        : powerpointExt.contains(file.mimeType)
            ? Icons.slideshow
            : pdfExt.contains(file.mimeType)
                ? Icons.picture_as_pdf
                : picExt.contains(file.mimeType)
                    ? Icons.image
                    : Icons.description;
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: [
            Icon(
              displayIcon,
              color: Colors.lightBlue,
              size: 20,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Text(
                file.name!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({
    super.key,
    required this.folder,
  });

  final File folder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleDriveScreen(
              parentId: folder.id,
              parentName: folder.name,
            ),
            settings: RouteSettings(
              name: '/google_drive_${folder.id}',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.folder,
              color: Colors.lightBlue,
              size: 20,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Text(
                folder.name ?? '--',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DownloadAlertDialog extends StatelessWidget {
  final String fileName;
  final Function callBackFunction;

  const DownloadAlertDialog({
    super.key,
    required this.fileName,
    required this.callBackFunction,
  });

  @override
  Widget build(BuildContext context) {
    return io.Platform.isIOS
        ? _buildCupertinoDialog(context)
        : _buildMaterialDialog(context);
  }

  Widget _buildMaterialDialog(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Download File',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Do you want to download the file:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fileName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel'.toUpperCase(),
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            callBackFunction();
          },
          child: Text(
            'Download'.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.only(
        right: 16,
        bottom: 6,
      ),
    );
  }

  Widget _buildCupertinoDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text(
        'Download File',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        children: [
          const SizedBox(height: 4),
          const Text(
            'Do you want to download the file:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fileName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
          ),
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
            callBackFunction();
          },
          isDefaultAction: true,
          child: const Text(
            'Download',
            style: TextStyle(),
          ),
        ),
      ],
    );
  }
}
