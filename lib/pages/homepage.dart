import 'package:byteclub/gpt_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class Page2
 extends StatefulWidget {
  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
    final gptService = GPTService(apiKey: "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", model: "gpt-4o");

    final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _conversation = [
    {"role": "system", "content": "You are a helpful assistant."}
  ];

  final List<Map<String, String>> _messages = [];

  bool _isLoading = false;

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
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
            Expanded(
              child: Cube(
                  onSceneCreated: (Scene scene) {
                    final Object object = Object(fileName: 'lib/models/building.obj');
                    object.position.setValues(0, 0, 0);
                    object.scale.setValues(0.1, 0.1, 0.1); // Adjust the scale if necessary
                    scene.world.add(object);
                    scene.camera.zoom = 10;
                    scene.camera.position.setValues(0, 0, 10); // Adjust the camera position
                    // Center the camera target on the object
                  },
                  interactive: false, // Disable user interaction
                ),
            ),
          ],
        ),
      ),
    );
  }
}
