import 'package:flutter/material.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/properties.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class TtsVolume extends StatefulWidget {
  const TtsVolume({
    super.key,
  });

  @override
  State<TtsVolume> createState() => _TtsVolumeState();
}

class _TtsVolumeState extends State<TtsVolume> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            SizedBox(
              width: ScreenSizeUtil.getWidth(context),
              child: Center(
                child: SfSlider(
                  // Slider properties
                  min: 0,
                  max: 100,
                  stepSize: 1,
                  showTicks: true,
                  showLabels: true,
                  showDividers: true,
                  interval: 10,
                  enableTooltip: false,
                  inactiveColor: Theme.of(context).colorScheme.primaryContainer,
                  activeColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  onChanged: (dynamic value) {
                    SettingsBox().ttsVolume = value / 100;
                    setState(() {});
                  },
                  // The slider's current value based on setVolumeValue (between 0 and 1)
                  value: SettingsBox().ttsVolume * 100,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
