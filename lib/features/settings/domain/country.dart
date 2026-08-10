class Country {
  final String code;
  final String name;
  final String flag;
  final String timezone;

  const Country({
    required this.code,
    required this.name,
    required this.flag,
    required this.timezone,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'] as String,
      name: json['name'] as String,
      flag: json['flag'] as String,
      timezone: json['timezone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'flag': flag,
      'timezone': timezone,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
