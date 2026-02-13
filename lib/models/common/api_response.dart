class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final List<String> errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message = '',
    this.errors = const [],
  });

  ApiResponse.success({
    required T data,
    String message = 'Success',
  })  : success = true,
        data = data,
        message = message,
        errors = const [];

  ApiResponse.error({
    required String message,
    List<String> errors = const [],
  })  : success = false,
        data = null,
        message = message,
        errors = errors;

  ApiResponse.loading()
      : success = false,
        data = null,
        message = 'Loading...',
        errors = const [];

  ApiResponse copyWith({
    bool? success,
    T? data,
    String? message,
    List<String>? errors,
  }) {
    return ApiResponse(
      success: success ?? this.success,
      data: data ?? this.data,
      message: message ?? this.message,
      errors: errors ?? this.errors,
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T)? dataEncoder) {
    return {
      'success': success,
      'data': data != null && dataEncoder != null ? dataEncoder(data as T) : null,
      'message': message,
      'errors': errors,
    };
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataDecoder,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && dataDecoder != null ? dataDecoder(json['data']) : null,
      message: json['message'] as String? ?? '',
      errors: List<String>.from(json['errors'] as List? ?? []),
    );
  }

  bool get hasError => !success && errors.isNotEmpty;

  String get errorMessage {
    if (message.isNotEmpty) return message;
    if (errors.isNotEmpty) return errors.join(', ');
    return 'Unknown error occurred';
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory PaginatedResponse.empty() {
    return PaginatedResponse(
      items: const [],
      totalCount: 0,
      page: 1,
      pageSize: 10,
      hasMore: false,
    );
  }

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? itemDecoder,
  ) {
    final items = json['items'] as List? ?? [];
    final decodedItems = itemDecoder != null
        ? items.map((item) => itemDecoder(item)).toList()
        : items.cast<T>();

    return PaginatedResponse(
      items: decodedItems,
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T)? itemEncoder) {
    return {
      'items': itemEncoder != null ? items.map((item) => itemEncoder(item)).toList() : items,
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
      'hasMore': hasMore,
    };
  }

  PaginatedResponse<T> copyWith({
    List<T>? items,
    int? totalCount,
    int? page,
    int? pageSize,
    bool? hasMore,
  }) {
    return PaginatedResponse(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  int get totalPages {
    return (totalCount / pageSize).ceil();
  }

  bool get isFirstPage => page == 1;

  bool get isLastPage => !hasMore;

  PaginatedResponse<T> addItems(List<T> newItems) {
    return copyWith(
      items: [...items, ...newItems],
      totalCount: totalCount,
      hasMore: hasMore,
    );
  }
}
