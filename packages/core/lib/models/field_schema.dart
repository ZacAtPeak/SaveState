enum FieldInputType {
  text,
  number,
  multiline,
  select,
  checkbox,
  list,
  dice,
}

class FieldSchema {
  const FieldSchema({
    required this.key,
    required this.label,
    required this.inputType,
    this.required = false,
    this.hint,
    this.options,
    this.min,
    this.max,
    this.pattern,
    this.enumOptions,
    this.derivedFrom,
    this.defaultValue,
  });

  final String key;
  final String label;
  final FieldInputType inputType;
  final bool required;
  final String? hint;
  final List<String>? options;
  final num? min;
  final num? max;
  final String? pattern;
  final List<String>? enumOptions;
  final String? derivedFrom;
  final dynamic defaultValue;

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'inputType': inputType.name,
        'required': required,
        if (hint != null) 'hint': hint,
        if (options != null) 'options': options,
        if (min != null) 'min': min,
        if (max != null) 'max': max,
        if (pattern != null) 'pattern': pattern,
        if (enumOptions != null) 'enumOptions': enumOptions,
        if (derivedFrom != null) 'derivedFrom': derivedFrom,
        if (defaultValue != null) 'defaultValue': defaultValue,
      };

  factory FieldSchema.fromJson(Map<String, dynamic> json) => FieldSchema(
        key: json['key'] as String,
        label: json['label'] as String,
        inputType: FieldInputType.values.byName(json['inputType'] as String),
        required: json['required'] as bool? ?? false,
        hint: json['hint'] as String?,
        options: (json['options'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        min: json['min'] as num?,
        max: json['max'] as num?,
        pattern: json['pattern'] as String?,
        enumOptions: (json['enumOptions'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        derivedFrom: json['derivedFrom'] as String?,
        defaultValue: json['defaultValue'],
      );
}
