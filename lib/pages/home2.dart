import 'package:flutter/material.dart';
import 'package:byteclub/pages/3D_page.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:byteclub/gpt_service.dart';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'detail_screen.dart';
import 'package:byteclub/pages/AreaDetailScreen.dart';
import 'package:flutter_cube/flutter_cube.dart';

class Home2Screen extends StatefulWidget {
  @override
  _Home2ScreenState createState() => _Home2ScreenState();
}

class _Home2ScreenState extends State<Home2Screen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Map<String, dynamic> _data = {};
  List<String> _impactedParts = [];
  Map<String, dynamic>? _selectedElement;
  String _selectedCategory = '';
  bool _isLoading = true;
  bool _isChatOpen = false;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<Map<String, String>> _chatMessages = [];
final gptService = GPTService(
    apiKey: "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",
    model: "gpt-4o",
  );  
  bool _isSendingMessage = false;
  
  // 3D Model objects
  Object? _companyModel;
  late Scene _scene;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for subtle movements
    _animationController = AnimationController(
      duration: Duration(seconds: 60),
      vsync: this,
    );
    
    _animationController.repeat();
    
    // Load data
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString('lib/data/data.json');
      final data = await json.decode(response);
      setState(() {
        _data = data['StGallenModel'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Business Ecosystem',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          // Chat button in AppBar
          IconButton(
            icon: Icon(_isChatOpen ? Icons.close : Icons.chat_bubble_outline),
            onPressed: () {
              _toggleChatWindow();
            },
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              // Main content - grid layout
              _isChatOpen 
                ? _buildChatWindow() 
                : _buildBusinessModelView(size),
            ],
          ),
    );
  }
  
  // Build the main business model visualization
  Widget _buildBusinessModelView(Size size) {
    return Column(
      children: [
        // Row of stakeholders (top)
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: _buildStakeholderRow(size),
        ),
        
        // Center row with 3D model
        Container(
          height: size.width * 0.5,
          child: Stack(
            children: [
              // 1. Connection lines FIRST (to be in background)
              CustomPaint(
                size: Size(size.width, size.width * 0.5),
                painter: ConnectionsPainter(
                  centerX: size.width / 2,
                  centerY: size.width * 0.25,
                  stakeholders: _getStakeholders(),
                  interactionThemes: _getInteractionThemes(),
                  environmentSpheres: _getEnvironmentSpheres(),
                  selectedElement: _selectedElement,
                  selectedCategory: _selectedCategory,
                ),
              ),
              
              // 2. 3D Company Model SECOND (appears on top of connections)
              Positioned.fill(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedElement = {'name': 'Unternehmen', 'data': _data['Unternehmen']};
                        _selectedCategory = 'Unternehmen';
                      });
                    },
                    child: Container(
                      width: size.width * 0.35,
                      height: size.width * 0.35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _build3DModel(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // First row below company - Interaktionsthemen (cards)
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: _buildCardRow('Interaktionsthemen', size),
        ),
        
        // Second row below - Umweltsphaeren (cards)
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildCardRow('Umweltsphaeren', size),
        ),
        
        // Detail panel at bottom when element selected
        if (_selectedElement != null)
          Expanded(
            child: _buildDetailPanel(),
          ),
      ],
    );
  }
  
  // Build the 3D model using flutter_cube
  Widget _build3DModel() {
    return Cube(
      onSceneCreated: (Scene scene) {
        scene.world.add(Object(
          fileName: 'lib/models/building.obj',
          scale: Vector3(5.0, 5.0, 5.0),
          position: Vector3(0, 0, 0),
          rotation: Vector3(0, 30, 0),
        ));
        
        scene.camera.zoom = 5;
        scene.light.position.setFrom(Vector3(0, 10, 10));
        
        scene.update();
        _scene = scene;
        
        // Animate rotation
        _animationController.addListener(() {
          if (scene.world.children.isNotEmpty) {
            final company = scene.world.children.first;
            company.rotation.y = _animationController.value * 2 * math.pi;
            scene.update();
          }
        });
      },
    );
  }
  
  // Build a row of stakeholder circles at the top
  Widget _buildStakeholderRow(Size size) {
    List<Map<String, dynamic>> stakeholders = _getStakeholders();
    
    // Calculate equal spacing
    double itemWidth = 80.0; // Fixed width for stakeholder circles
    double totalWidth = itemWidth * stakeholders.length;
    double spacing = 8.0; // Default spacing
    
    // Ensure proper spacing fits on screen
    if (totalWidth + (spacing * (stakeholders.length + 1)) <= size.width) {
      // Calculate even spacing if there's room
      spacing = (size.width - totalWidth) / (stakeholders.length + 1);
    } else {
      // Otherwise use a horizontal scroll
      totalWidth += (spacing * (stakeholders.length + 1));
    }
    
    return Container(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stakeholders.length,
        physics: totalWidth > size.width 
            ? AlwaysScrollableScrollPhysics()
            : NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: spacing),
        itemBuilder: (context, index) {
          return Container(
            width: itemWidth,
            margin: EdgeInsets.symmetric(horizontal: spacing),
            child: _buildStakeholderCircle(stakeholders[index]),
          );
        },
      ),
    );
  }
  
  // Build a row of cards (for Interaktionsthemen or Umweltsphaeren)
  Widget _buildCardRow(String category, Size size) {
    List<Map<String, dynamic>> items = 
        category == 'Interaktionsthemen' ? _getInteractionThemes() : _getEnvironmentSpheres();
    
    double cardWidth = category == 'Interaktionsthemen' 
        ? (size.width / math.min(3, items.length)) - 20 // 3 cards with spacing
        : (size.width / math.min(4, items.length)) - 18; // 4 cards with spacing
        
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          return Container(
            width: cardWidth,
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: _buildCard(items[index], category),
          );
        },
      ),
    );
  }
  
  // Build a stakeholder circle
  Widget _buildStakeholderCircle(Map<String, dynamic> stakeholder) {
    final bool isImpacted = _impactedParts.contains(stakeholder['name']);
    final bool isSelected = _selectedElement != null && 
                          _selectedElement!['name'] == stakeholder['name'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedElement = stakeholder;
          _selectedCategory = 'Stakeholder';
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(isSelected ? 0.4 : 0.2),
              blurRadius: isSelected ? 15 : 8,
              spreadRadius: isSelected ? 3 : 0,
            ),
          ],
          border: isSelected || isImpacted 
            ? Border.all(
                color: isImpacted ? Colors.green : Colors.blue,
                width: 3,
              ) 
            : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              color: Colors.blue,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              stakeholder['name'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  // Build a card for Interaktionsthemen or Umweltsphaeren
  Widget _buildCard(Map<String, dynamic> item, String category) {
    final bool isImpacted = _impactedParts.contains(item['name']);
    final bool isSelected = _selectedElement != null && 
                          _selectedElement!['name'] == item['name'];
    
    Color cardColor = category == 'Interaktionsthemen' 
        ? Colors.orange.withOpacity(0.1) 
        : Colors.green.withOpacity(0.1);
    
    Color borderColor = category == 'Interaktionsthemen' 
        ? Colors.orange
        : Colors.green;
    
    IconData cardIcon = category == 'Interaktionsthemen' 
        ? Icons.settings_input_component
        : Icons.public;
        
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedElement = item;
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? cardColor.withOpacity(0.3) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(isSelected ? 0.4 : 0.2),
              blurRadius: isSelected ? 10 : 5,
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
          border: isSelected || isImpacted 
            ? Border.all(
                color: isImpacted ? Colors.green : borderColor,
                width: 2,
              ) 
            : Border.all(
                color: borderColor.withOpacity(0.2),
                width: 1,
              ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cardIcon,
                    color: borderColor,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      item['name'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build the detail panel that appears when an element is selected
  Widget _buildDetailPanel() {
    if (_selectedElement == null) return Container();
    
    final element = _selectedElement!;
    final category = _selectedCategory;
    
    // Set color and icon based on category
    Color panelColor;
    IconData panelIcon;
    
    switch(category) {
      case 'Stakeholder':
        panelColor = Colors.blue;
        panelIcon = Icons.people;
        break;
      case 'Interaktionsthemen':
        panelColor = Colors.orange;
        panelIcon = Icons.settings_input_component;
        break;
      case 'Umweltsphaeren':
        panelColor = Colors.green;
        panelIcon = Icons.public;
        break;
      default:
        panelColor = Colors.indigo;
        panelIcon = Icons.business;
    }
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                panelIcon,
                color: panelColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  element['name'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (_impactedParts.contains(element['name']))
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Impacted',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: panelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: panelColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: panelColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _selectedElement = null;
                    _selectedCategory = '';
                  });
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                splashRadius: 20,
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Show subcategories if available
          if (element['data'] != null && element['data']['children'] is Map)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contains:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...((element['data']['children'] as Map).entries.map((entry) {
                            final childName = entry.value['name'] ?? entry.key;
                            final isChildImpacted = _impactedParts.contains(childName);
                            
                            return ActionChip(
                              label: Text(childName),
                              backgroundColor: isChildImpacted ? Colors.green.withOpacity(0.1) : panelColor.withOpacity(0.1),
                              side: BorderSide(
                                color: isChildImpacted ? Colors.green : panelColor.withOpacity(0.3),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AreaDetailScreen(
                                      areaName: childName,
                                      isImpacted: isChildImpacted,
                                      parentCategory: element['name'],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList())
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (category == 'Unternehmen') {
                  // For company, show full 3D model
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: Text('Business Model')),
                        body: Building3DViewer(
                          modelPath: 'lib/models/building.obj',
                          height: MediaQuery.of(context).size.height,
                        ),
                      ),
                    ),
                  );
                } else {
                  // For other categories, navigate to detail screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        parentCategory: element['name'],
                        details: element['data']['children'] ?? {},
                        impactedParts: _impactedParts,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: panelColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Explore Details'),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper methods to get specific data lists
  List<Map<String, dynamic>> _getStakeholders() {
    List<Map<String, dynamic>> stakeholders = [];
    
    if (_data.containsKey('Stakeholder') && 
        _data['Stakeholder'].containsKey('children')) {
      Map<String, dynamic> children = _data['Stakeholder']['children'];
      
      children.forEach((key, child) {
        stakeholders.add({
          'name': child['name'] ?? key,
          'data': child,
        });
      });
    }
    
    return stakeholders;
  }
  
  List<Map<String, dynamic>> _getInteractionThemes() {
    List<Map<String, dynamic>> themes = [];
    
    if (_data.containsKey('Interaktionsthemen') && 
        _data['Interaktionsthemen'].containsKey('children')) {
      Map<String, dynamic> children = _data['Interaktionsthemen']['children'];
      
      children.forEach((key, child) {
        themes.add({
          'name': child['name'] ?? key,
          'data': child,
        });
      });
    }
    
    return themes;
  }
  
  List<Map<String, dynamic>> _getEnvironmentSpheres() {
    List<Map<String, dynamic>> spheres = [];
    
    if (_data.containsKey('Umweltsphaeren') && 
        _data['Umweltsphaeren'].containsKey('children')) {
      Map<String, dynamic> children = _data['Umweltsphaeren']['children'];
      
      children.forEach((key, child) {
        spheres.add({
          'name': child['name'] ?? key,
          'data': child,
        });
      });
    }
    
    return spheres;
  }
  
  // Chat-related methods
  Widget _buildChatWindow() {
    return Column(
      children: [
        // Chat header
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'AI Business Consultant',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: _chatScrollController,
            padding: EdgeInsets.all(16),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final message = _chatMessages[index];
              final bool isUser = message['role'] == 'user';
              
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser)
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        radius: 16,
                        child: Icon(Icons.assistant, color: Colors.blue.shade700, size: 16),
                      ),
                      
                    SizedBox(width: isUser ? 0 : 8),
                    
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          message['content'] ?? '',
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: isUser ? 8 : 0),
                    
                    if (isUser)
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 16,
                        child: Icon(Icons.person, color: Colors.white, size: 16),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Typing indicator
        if (_isSendingMessage)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16, 
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'AI is thinking...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        
        // Chat input
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Ask about your business model...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) => _sendChatMessage(value),
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: () => _sendChatMessage(_chatController.text),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _toggleChatWindow() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
  }
  
  Future<void> _sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;
    
    setState(() {
      _chatMessages.add({
        'role': 'user',
        'content': message,
      });
      _isSendingMessage = true;
      _chatController.clear();
    });
    
    // Scroll to bottom
    _scrollToBottom();
    
    try {
      // Create conversation history
      List<Map<String, String>> conversation = [
        {"role": "system", "content": "You are an AI business model consultant helping to analyze the St. Gallen Business Model."},
      ];
      
      // Add previous chat for context
      conversation.addAll(_chatMessages.where((msg) => msg['role'] != null && msg['content'] != null)
          .map((msg) => {"role": msg['role']!, "content": msg['content']!}));
      
      // Send to GPT service
      final response = await gptService.sendMessage(
        message,
        conversation,
        {"context": "Business Model Analysis"}
      );
      
      setState(() {
        _chatMessages.add({
          'role': 'assistant',
          'content': response.trim(),
        });
        _isSendingMessage = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      print("Error sending message: $e");
      setState(() {
        _chatMessages.add({
          'role': 'assistant',
          'content': "I'm sorry, I couldn't process your question. Please try again.",
        });
        _isSendingMessage = false;
      });
      _scrollToBottom();
    }
  }
  
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Business Ecosystem View'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Top row: Seven stakeholders as circles'),
            Text('• Center: Company 3D model'),
            Text('• First bottom row: Interaction themes as cards'),
            Text('• Second bottom row: Environmental spheres as cards'),
            Text('• Click any element to see details'),
            Text('• Use the chat button to ask questions'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          )
        ],
      ),
    );
  }
}

// Connection painter to draw lines between elements
class ConnectionsPainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final List<Map<String, dynamic>> stakeholders;
  final List<Map<String, dynamic>> interactionThemes;
  final List<Map<String, dynamic>> environmentSpheres;
  final Map<String, dynamic>? selectedElement;
  final String selectedCategory;
  
  ConnectionsPainter({
    required this.centerX,
    required this.centerY,
    required this.stakeholders,
    required this.interactionThemes,
    required this.environmentSpheres,
    this.selectedElement,
    required this.selectedCategory,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Paint for regular connections
    final regularPaint = Paint()
      ..color = Colors.grey.withOpacity(0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
      
    // Paint for highlighted connections  
    final highlightPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    
    // Draw stakeholder connections
    _drawConnections(
      canvas, 
      stakeholders, 
      'Stakeholder', 
      size.width, 
      45, // stakeholder y-position
      regularPaint, 
      highlightPaint
    );
    
    // Draw interaction theme connections
    _drawConnections(
      canvas, 
      interactionThemes, 
      'Interaktionsthemen', 
      size.width, 
      size.height - 120, // first row below the center
      regularPaint, 
      highlightPaint,
      isCard: true
    );
    
    // Draw environment sphere connections
    _drawConnections(
      canvas, 
      environmentSpheres, 
      'Umweltsphaeren', 
      size.width, 
      size.height - 40, // second row below the center
      regularPaint, 
      highlightPaint,
      isCard: true
    );
  }
  
  void _drawConnections(
    Canvas canvas, 
    List<Map<String, dynamic>> elements, 
    String category, 
    double width, 
    double yPosition,
    Paint regularPaint,
    Paint highlightPaint,
    {bool isCard = false}
  ) {
    if (elements.isEmpty) return;
    
    // Calculate proper spacing
    final int count = elements.length;
    final double elementWidth = isCard ? width / (count <= 3 ? 3 : 4) - 16 : 80;
    final double totalContentWidth = elementWidth * count;
    final double availableSpace = width - totalContentWidth;
    final double spacing = math.max(8.0, availableSpace / (count + 1));
    
    // Draw connections from each element to the center
    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];
      
      // Calculate element position - evenly distribute across screen width
      double x;
      if (count <= 1) {
        x = width / 2; // Center single element
      } else {
        // Distribute elements evenly
        x = spacing + (i * ((width - (2 * spacing)) / (count - 1)));
      }
      double y = yPosition;
      
      // Select paint based on selection status
      final bool isSelected = selectedElement != null && 
                            selectedElement!['name'] == element['name'];
      final bool isSelectedCategory = selectedCategory == category ||
                                   selectedCategory == 'Unternehmen';
      Paint paint;
      
      if (isSelected) {
        // This specific element is selected
        paint = Paint()
          ..color = Colors.blue.withOpacity(0.6)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;
      } else if (isSelectedCategory && selectedCategory == 'Unternehmen') {
        // Company is selected - highlight all connections
        paint = Paint()
          ..color = category == 'Stakeholder' ? Colors.blue.withOpacity(0.3) :
                   category == 'Interaktionsthemen' ? Colors.orange.withOpacity(0.3) :
                   Colors.green.withOpacity(0.3)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
      } else if (isSelectedCategory) {
        // Category is selected - highlight all elements in this category
        paint = highlightPaint;
        paint.color = category == 'Stakeholder' ? Colors.blue.withOpacity(0.3) :
                     category == 'Interaktionsthemen' ? Colors.orange.withOpacity(0.3) :
                     Colors.green.withOpacity(0.3);
      } else {
        // Regular connection
        paint = regularPaint;
      }
      
      // Calculate radius for circles or cards
      double elementRadius = isCard ? 0 : 40; // For cards, we connect to the top/bottom edge
      double companyRadius = width * 0.175; // Company circle radius
      
      // Calculate angle from element to center
      double angle = math.atan2(centerY - y, centerX - x);
      
      // Calculate start and end points based on whether it's a circle or card
      double startX, startY, endX, endY;
      
      if (isCard) {
        // For cards, connect to top/bottom edge center
        startX = x;
        startY = yPosition < centerY ? y + 10 : y - 10; // Bottom of top cards or top of bottom cards
      } else {
        // For circles, calculate perimeter points
        startX = x + elementRadius * math.cos(angle);
        startY = y + elementRadius * math.sin(angle);
      }
      
      // Company circle perimeter point
      endX = centerX - companyRadius * math.cos(angle);
      endY = centerY - companyRadius * math.sin(angle);
      
      // Draw curved line
      Path path = Path();
      path.moveTo(startX, startY);
      
      // Determine control point for curve
      double controlX = startX + (endX - startX) * 0.3;
      double controlY = startY + (endY - startY) * 0.3;
      
      path.quadraticBezierTo(
        controlX, 
        controlY,
        endX, 
        endY
      );
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}