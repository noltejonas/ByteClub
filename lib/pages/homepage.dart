import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'detail_screen.dart';
import 'package:byteclub/gpt_service.dart';

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

  // Now we only show user messages, not the GPT reply
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  Map<String, dynamic> _data = {};
  List<String> _impactedParts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String response =
        await rootBundle.loadString('lib/constants/data.json');
    final data = await json.decode(response);
    setState(() {
      _data = data['StGallenModel'];
    });
  }

  void _resetImpactedParts() {
    setState(() {
      _impactedParts = [];
    });
  }

  // Propagate impact upward: if a child is impacted, add its parent recursively.
  bool _propagate(String key, Map<String, dynamic> node, Set<String> impacted) {
    final String name = node['name'] ?? key;
    bool anyChildImpacted = false;
    if (node.containsKey('children') && node['children'] is Map<String, dynamic>) {
      Map<String, dynamic> children = node['children'];
      for (var entry in children.entries) {
        bool childResult = _propagate(entry.key, entry.value, impacted);
        if (childResult) {
          anyChildImpacted = true;
        }
      }
    }
    if (impacted.contains(name) || anyChildImpacted) {
      impacted.add(name);
      return true;
    }
    return false;
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
      _resetImpactedParts();
    });
    _controller.clear();

    try {
      final reply = await gptService.sendMessage(
          text, _conversation, {"key": "value"});
      // We use the reply solely to update impacted parts.
      setState(() {
        // Assume reply is a comma-separated list of impacted part names.
        _impactedParts =
            reply.split(',').map((part) => part.trim()).toList();
        // Propagate change: if a child is impacted, also mark its parent.
        Set<String> impactedSet = Set<String>.from(_impactedParts);
        _data.forEach((key, node) {
          _propagate(key, node, impactedSet);
        });
        _impactedParts = impactedSet.toList();
      });
    } catch (e) {
      // Optionally log the error in background.
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    // Now only user messages are shown.
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(12),
        child: Text(
          message["content"] ?? "",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCard(String key, Map<String, dynamic> content) {
    // Fallback to key if content['name'] is null
    final String name = content['name'] ?? key;
    bool isImpacted = _impactedParts.contains(name);
    
    // Special case for Unternehmen card with 3D simulation
    if (key == "Unternehmen") {
      return Card(
        color: isImpacted ? Colors.green[100] : null,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  parentCategory: name,
                  details: content['children'] ?? {},
                  impactedParts: _impactedParts,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: _buildCompanySimulation(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Regular cards for other categories
    return Card(
      color: isImpacted ? Colors.green[100] : null,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                parentCategory: name,
                details: content['children'] ?? {},
                impactedParts: _impactedParts,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            name,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  // 3D Simulation for the company card
  Widget _buildCompanySimulation() {
    // This is a placeholder for the 3D visualization
    // You'll need to install a 3D rendering package like model_viewer_plus
    // For now, we'll use a simple placeholder
    return Stack(
      children: [
        // 3D model visualization placeholder
        Container(
          color: Colors.grey.shade100,
          child: Center(
            child: Icon(Icons.view_in_ar, size: 60, color: Colors.blue),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: ElevatedButton.icon(
            icon: Icon(Icons.open_in_full),
            label: Text("View 3D Model"),
            onPressed: () {
              // Open full-screen 3D visualization
              // This is where you would implement your full 3D visualization
            },
          ),
        ),
      ],
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
                  _buildCard("Umweltsphaeren", _data['Umweltsphaeren'] ?? {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
