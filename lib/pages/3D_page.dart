import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Building3DViewer extends StatelessWidget {
  final String modelPath;
  final double height;
  
  const Building3DViewer({
    Key? key,
    required this.modelPath,
    this.height = 250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ModelViewer(
        src: modelPath,
        alt: "3D Business Model",
        ar: false,
        autoRotate: true,
        cameraControls: true,
        backgroundColor: const Color.fromARGB(255, 240, 245, 255),
      ),
    );
  }
}