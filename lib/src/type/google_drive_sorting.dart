class GoogleDriveSorting {
  final String? sortBy;
  const GoogleDriveSorting(
    this.sortBy,
  );

  factory GoogleDriveSorting.none() => const GoogleDriveSorting(null);

  factory GoogleDriveSorting.nameDesc() => const GoogleDriveSorting(
        'name desc',
      );

  factory GoogleDriveSorting.nameAsc() => const GoogleDriveSorting(
        'name',
      );

  factory GoogleDriveSorting.createdTimeDesc() => const GoogleDriveSorting(
        'createdTime desc',
      );

  factory GoogleDriveSorting.createdTimeAsc() => const GoogleDriveSorting(
        'createdTime',
      );

  factory GoogleDriveSorting.modifiedTimeDesc() => const GoogleDriveSorting(
        'modifiedTime desc',
      );

  factory GoogleDriveSorting.modifiedTimeAsc() => const GoogleDriveSorting(
        'modifiedTime',
      );
}
