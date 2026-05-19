class PaginationData {
  final int totalCount;
  final int? pageSize;
  final int? currentPage;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;

  PaginationData({
    required this.totalCount,
    this.pageSize,
    this.currentPage,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      totalCount: json['totalCount'],
      pageSize: json['pageSize'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      hasPrevious: json['hasPrevious'],
      hasNext: json['hasNext'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'pageSize': pageSize,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'hasPrevious': hasPrevious,
      'hasNext': hasNext,
    };
  }
}
