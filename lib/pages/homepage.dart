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
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _conversation = [
    {"role": "system", "content": "You are a helpful assistant."}
  ];

  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  Map<String, dynamic> _data = {};
  List<String> _impactedParts = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString('lib/data/data.json');
      final data = await json.decode(response);
      setState(() {
        _data = data['StGallenModel'];
      });
    } catch (e) {
      print('Error loading data: $e');
    }
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
        _impactedParts = reply.split(',').map((part) => part.trim()).toList();
        
        // Propagate change: if a child is impacted, also mark its parent.
        Set<String> impactedSet = Set<String>.from(_impactedParts);
        _data.forEach((key, node) {
          _propagate(key, node, impactedSet);
        });
        _impactedParts = impactedSet.toList();
      });
    } catch (e) {
      print('Error sending message: $e');
      // Optionally show an error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCard(String key, Map<String, dynamic> content) {
    // Fallback to key if content['name'] is null
    final String name = content['name'] ?? key;
    bool isImpacted = _impactedParts.contains(name);
    
    // Define consistent card styling
    final cardDecoration = BoxDecoration(
      color: isImpacted ? Colors.green.shade50 : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          spreadRadius: 0,
          offset: Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: isImpacted ? Colors.green.shade300 : Colors.grey.shade200,
        width: isImpacted ? 2 : 1,
      ),
    );
    
    // Special case for Unternehmen card with static image
    if (key == "Unternehmen") {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: cardDecoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card header
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.business,
                              color: isImpacted ? Colors.green.shade700 : Colors.blue.shade700,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        if (isImpacted)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Text(
                              'Impacted',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Static image - Changed to Company.png
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Color(0xFFF7F9FC),
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Image.asset(
                      'lib/images/Company.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Icon based on category type
    IconData categoryIcon;
    Color categoryColor;
    
    switch (key) {
      case "Stakeholder":
        categoryIcon = Icons.people;
        categoryColor = Colors.blue.shade700;
        break;
      case "Interaktionsthemen":
        categoryIcon = Icons.settings_input_component;
        categoryColor = Colors.orange.shade700;
        break;
      case "Umweltsphaeren":
        categoryIcon = Icons.public;
        categoryColor = Colors.green.shade700;
        break;
      default:
        categoryIcon = Icons.category;
        categoryColor = Colors.grey.shade700;
    }
    
    // Regular cards for other categories
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
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
              child: Row(
                children: [
                  Icon(
                    categoryIcon,
                    color: isImpacted ? Colors.green.shade700 : categoryColor,
                    size: 22,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap to explore ${content['children']?.length ?? 0} elements',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isImpacted)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        'Impacted',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 16),
                    Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Ask about the business model...",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          style: TextStyle(fontSize: 16),
                          textAlignVertical: TextAlignVertical.center,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _isLoading 
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.send, color: Colors.white),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                // Business model components directly without a title
                // First, show Stakeholder
                _data.containsKey('Stakeholder') 
                  ? _buildCard("Stakeholder", _data['Stakeholder'] ?? {})
                  : SizedBox.shrink(),
                  
                // Second, show Unternehmen with the Company image
                _data.containsKey('Unternehmen') 
                  ? _buildCard("Unternehmen", _data['Unternehmen'] ?? {})
                  : SizedBox.shrink(),
                
                // Then show other components
                _data.containsKey('Interaktionsthemen') 
                  ? _buildCard("Interaktionsthemen", _data['Interaktionsthemen'] ?? {})
                  : SizedBox.shrink(),
                  
                _data.containsKey('Umweltsphaeren') 
                  ? _buildCard("Umweltsphaeren", _data['Umweltsphaeren'] ?? {})
                  : SizedBox.shrink(),
                  
                // Bottom padding to ensure everything is visible
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
