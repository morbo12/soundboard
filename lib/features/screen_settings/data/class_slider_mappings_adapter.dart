import 'package:hive/hive.dart';
import 'class_slider_mappings.dart';

class SliderMappingAdapter extends TypeAdapter<SliderMapping> {
  @override
  final int typeId = 0; // Unique ID for this adapter

  @override
  SliderMapping read(BinaryReader reader) {
    final deejSliderIdx = reader.readInt();
    final processName = reader.readString();
    final uiSliderIdx = reader.readInt();
    return SliderMapping(
      deejSliderIdx: deejSliderIdx,
      processName: processName,
      uiSliderIdx: uiSliderIdx,
    );
  }

  @override
  void write(BinaryWriter writer, SliderMapping obj) {
    writer.writeInt(obj.deejSliderIdx);
    writer.writeString(obj.processName);
    writer.writeInt(obj.uiSliderIdx);
  }
}
