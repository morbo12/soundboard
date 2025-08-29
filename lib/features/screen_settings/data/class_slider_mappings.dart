class SliderMapping {
  final int deejSliderIdx;
  final String processName;
  final int uiSliderIdx;

  SliderMapping({
    required this.deejSliderIdx,
    required this.processName,
    required this.uiSliderIdx,
  });

  Map<String, dynamic> toJson() => {
    'deejSliderIdx': deejSliderIdx,
    'processName': processName,
    'uiSliderIdx': uiSliderIdx,
  };

  factory SliderMapping.fromJson(Map<String, dynamic> json) => SliderMapping(
    deejSliderIdx: json['deejSliderIdx'] as int,
    processName: json['processName'] as String,
    uiSliderIdx: json['uiSliderIdx'] as int,
  );
}
