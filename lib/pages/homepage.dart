import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_cube/flutter_cube.dart';
import 'detail_screen.dart';
import 'package:byteclub/gpt_service.dart';
import 'dart:math' as math;

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
  Map<String, dynamic> _data = {}; // Define the _data variable

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String response = await rootBundle.loadString('lib/constants/data.json');
    final data = await json.decode(response);
    setState(() {
      _data = data['StGallenModel'];
    });
  }

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

  Widget _buildCard(String title, Map<String, dynamic> content) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                parentCategory: title,
                details: content,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18)),
              if (title == "Unternehmen")
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    height: 300, // Set a fixed height for the Cube widget
                    child: Cube(
                      onSceneCreated: (Scene scene) {
                         Object object = Object(fileName: 'lib/models/building.obj');
                        object.position.setValues(0, 0, 0);
                        object.scale.setValues(0.1, 0.1, 0.1); // Adjust the scale if necessary
                        scene.world.add(object);
                        scene.camera.zoom = 10;
                        scene.camera.position.setValues(0, 0, 10); // Adjust the camera position
                   // Center the camera target on the object

                        // Custom interaction handling
                        double initialX = 0;
                        double initialY = 0;
                        double rotationX = 0;
                        double rotationY = 0;
                        /*
                        scene.onUpdate = () {
                          // Limit rotation to 5 degrees in each direction
                          rotationX = rotationX.clamp(-math.pi / 36, math.pi / 36);
                          rotationY = rotationY.clamp(-math.pi / 36, math.pi / 36);

                          object.rotation.setValues(rotationX, rotationY, 0);
                        };

                        scene.onPointerMove = (details) {
                          if (details.delta.dx != 0 || details.delta.dy != 0) {
                            rotationX += details.delta.dy * 0.01;
                            rotationY += details.delta.dx * 0.01;
                          }
                        };*/
                      },
                      interactive: true, // Enable user interaction
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Ask a case...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ..._messages.map(_buildMessage).toList(),
                  _buildCard("Stakeholder", _data['Stakeholder'] ?? {}),
                  _buildCard("Unternehmen", _data['Unternehmen'] ?? {}),
                  _buildCard("Interaktionsthemen", _data['Interaktionsthemen'] ?? {}),
                  _buildCard("Umweltsphären", _data['Umweltsphären'] ?? {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
