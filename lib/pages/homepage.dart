import 'package:byteclub/gpt_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'dart:math' as math;
import 'dart:async';

class Page2 extends StatefulWidget {
  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  final gptService = GPTService(
    apiKey: "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",
    model: "gpt-4o",
  );

  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _conversation = [
    {"role": "system", "content": "You are a helpful assistant."}
  ];

  final List<Map<String, String>> _messages = [];

  bool _isLoading = false;

  Object? _cubeObject;
  double _rotationX = 0;
  double _rotationY = 0;
  Scene? _scene;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final reply = await gptService.sendMessage(text, _conversation, {"key": "value"});
      setState(() {
        _messages.add({"role": "assistant", "content": reply});
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "assistant", "content": "Error: ${e.toString()}"});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message["role"] == "user";
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(12),
        child: Text(
          message["content"] ?? "",
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with Assistant"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Shareholders'),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Unternehmen'),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanUpdate: (details) {
                            setState(() {
                              _rotationX += details.delta.dy * 0.05;
                              _rotationY += details.delta.dx * 0.05;
                              _rotationX = _rotationX.clamp(-math.pi / 36, math.pi / 36);
                              _rotationY = _rotationY.clamp(-math.pi / 36, math.pi / 36);
                              if (_cubeObject != null) {
                                _cubeObject!.rotation.setValues(_rotationX, _rotationY, 0);
                              }
                              if (_scene != null) {
                                _scene!.update();
                              }
                            });
                          },
                          onPanEnd: (details) {
                            // Animate the cube back to its original position
                            Timer.periodic(Duration(milliseconds: 16), (timer) {
                              setState(() {
                                _rotationX *= 0.9;
                                _rotationY *= 0.9;
                                if (_rotationX.abs() < 0.001 && _rotationY.abs() < 0.001) {
                                  _rotationX = 0;
                                  _rotationY = 0;
                                  timer.cancel();
                                }
                                if (_cubeObject != null) {
                                  _cubeObject!.rotation.setValues(_rotationX, _rotationY, 0);
                                }
                              });
                            });
                          },
                          child: Cube(
                            onSceneCreated: (Scene scene) {
                              final Object object = Object(fileName: 'lib/models/building.obj');
                              object.position.setValues(0, 0, 0);
                              object.scale.setValues(0.1, 0.1, 0.1); // Adjust the scale if necessary
                              scene.world.add(object);
                              scene.camera.zoom = 10;
                              scene.camera.position.setValues(0, 0, 10); // Adjust the camera position
                              _cubeObject = object;
                              _scene = scene;
                            },
                            interactive: false, // Disable built-in interaction as we handle it via GestureDetector
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Interaktionsthemen'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Umweltsphären'),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
