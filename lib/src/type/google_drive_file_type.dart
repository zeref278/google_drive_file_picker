class GoogleDriveFileType {
  const GoogleDriveFileType(this.type);
  final String? type;

  factory GoogleDriveFileType.all() => const GoogleDriveFileType(null);

  factory GoogleDriveFileType.image() => const GoogleDriveFileType('image');
  factory GoogleDriveFileType.video() => const GoogleDriveFileType('video');
  factory GoogleDriveFileType.audio() => const GoogleDriveFileType('audio');
}
