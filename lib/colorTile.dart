import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'color.dart' as hex;

class ColorTile extends ListTile {
  final hex.Color color;

  ColorTile(BuildContext context, {required this.color, required String title, required GestureTapCallback onSelect})
      : super(
    title: Container(
        child: Center(
          child: Text(title),
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: color.value,
            width: 3,
          ),
        )),
    onTap: () {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
              title: Center( child: Text("Pick a color for $title")),
              titlePadding: const EdgeInsets.all(0.0),
              contentPadding: const EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              content:
              SlidePicker(
                  labelTypes: [],
                  colorModel: ColorModel.hsv,
                  pickerColor: color.value,
                  enableAlpha: false,
                  displayThumbColor: true,
                  showIndicator: true,
                  onColorChanged: (Color newColor) {
                    color.value = newColor;
                  }),

              actions: [
                TextButton(
                  child: const Text("Looks good!"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSelect.call();
                  },
                ),
              ]
          )
      );
    },
  );
}