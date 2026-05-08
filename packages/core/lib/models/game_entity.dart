class GameEntity {
  GameEntity({
    required this.entityTypeKey,
    Map<String, dynamic>? data,
  }) : _data = data ?? {};

  final String entityTypeKey;
  final Map<String, dynamic> _data;

  Map<String, dynamic> toJson() => {
        'entityTypeKey': entityTypeKey,
        'data': Map<String, dynamic>.from(_data),
      };

  factory GameEntity.fromJson(Map<String, dynamic> json) => GameEntity(
        entityTypeKey: json['entityTypeKey'] as String,
        data: json['data'] != null
            ? Map<String, dynamic>.from(json['data'] as Map)
            : {},
      );

  int getInt(String key, {int? fallback}) {
    final value = _data[key];
    if (value == null) return fallback ?? 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback ?? 0;
  }

  String getString(String key, {String? fallback}) {
    final value = _data[key];
    if (value == null) return fallback ?? '';
    if (value is String) return value;
    return fallback ?? '';
  }

  bool getBool(String key, {bool? fallback}) {
    final value = _data[key];
    if (value == null) return fallback ?? false;
    if (value is bool) return value;
    return fallback ?? false;
  }

  double getDouble(String key, {double? fallback}) {
    final value = _data[key];
    if (value == null) return fallback ?? 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return fallback ?? 0.0;
  }

  List<dynamic> getList(String key, {List<dynamic>? fallback}) {
    final value = _data[key];
    if (value == null) return fallback ?? const [];
    if (value is List) return value;
    return fallback ?? const [];
  }

  Map<String, dynamic> getMap(String key, {Map<String, dynamic>? fallback}) {
    final value = _data[key];
    if (value == null) return fallback ?? const {};
    if (value is Map) return Map<String, dynamic>.from(value);
    return fallback ?? const {};
  }
}
