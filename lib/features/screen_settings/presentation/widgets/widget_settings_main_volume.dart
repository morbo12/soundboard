import 'package:flutter/material.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/core/properties.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class MainVolume extends StatefulWidget {
  const MainVolume({super.key});

  @override
  State<MainVolume> createState() => _MainVolumeState();
}

class _MainVolumeState extends State<MainVolume> {
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
                    SettingsBox().mainVolume = value / 100;
                    setState(() {});
                  },
                  // The slider's current value based on setVolumeValue (between 0 and 1)
                  value: SettingsBox().mainVolume * 100,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
