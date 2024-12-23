class PrintConfig {
  static const List<String> VALID_PAPER_SIZES = ['A4', 'A3', 'Letter', 'Legal'];
  static const int MIN_COPIES = 1;
  static const int MAX_COPIES = 100;

  final String paperSize;
  bool _color;
  bool _doubleSided;
  int _copies;

  PrintConfig({
    this.paperSize = 'A4',
    bool color = false,
    bool doubleSided = false,
    int copies = 1,
  })  : _color = color,
        _doubleSided = doubleSided,
        _copies = copies;

  // Getters
  bool get color => _color;
  bool get doubleSided => _doubleSided;
  int get copies => _copies;

  // Setters
  set color(bool value) => _color = value;
  set doubleSided(bool value) => _doubleSided = value;
  set copies(int value) => _copies = value;

  PrintConfig copyWith({
    String? paperSize,
    bool? color,
    bool? doubleSided,
    int? copies,
  }) {
    return PrintConfig(
      paperSize: paperSize ?? this.paperSize,
      color: color ?? this._color,
      doubleSided: doubleSided ?? this._doubleSided,
      copies: (copies ?? this._copies).clamp(MIN_COPIES, MAX_COPIES),
    );
  }

  Map<String, dynamic> toJson() => {
    'paper_size': paperSize,
    'color': _color,
    'double_sided': _doubleSided,
    'copies': _copies,
  };

  factory PrintConfig.fromJson(Map<String, dynamic> json) => PrintConfig(
    paperSize: json['paper_size'] ?? 'A4',
    color: json['color'] ?? false,
    doubleSided: json['double_sided'] ?? false,
    copies: (json['copies'] ?? 1).clamp(MIN_COPIES, MAX_COPIES),
  );

  double calculateCost() {
    double baseCost = paperSize == 'A3' ? 0.20 : 0.10;
    if (_color) baseCost *= 2;
    if (_doubleSided) baseCost *= 1.5;
    return baseCost * _copies;
  }
}