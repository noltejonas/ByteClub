import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class Page2
 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Cube(
          onSceneCreated: (Scene scene) {
            scene.world.add(Object(
              fileName: 'lib/models/building.obj',
            ));
            scene.camera.zoom = 10;
            //scene.camera.position.setValues(0, 0, 10); // Lock the camera position
            //scene.camera.target.setValues(0, 0, 0); // Lock the camera target
          },
          interactive: false, // Disable user interaction
        ),
      ),
    );
  }
}
