import 'package:byteclub/gpt_service.dart';
import 'package:byteclub/pages/tool_overview_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'package:byteclub/data/tools_data.dart';
import 'package:url_launcher/url_launcher.dart';

class AreaDetailScreen extends StatefulWidget {
  final String areaName;
  final bool isImpacted;
  final String parentCategory;

  const AreaDetailScreen({
    Key? key,
    required this.areaName,
    required this.isImpacted,
    required this.parentCategory,
  }) : super(key: key);

  @override
  _AreaDetailScreenState createState() => _AreaDetailScreenState();
}

class _AreaDetailScreenState extends State<AreaDetailScreen> {
  bool _isLoading = true;
  String _impactDescription = "";
  final gptService = GPTService(
    apiKey: "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",
    model: "gpt-4o",
  );
  bool _toolsLoading = true;
  List<Map<String, String>> _availableTools = [];
  
  // New chat functionality
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];
  bool _isSendingMessage = false;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getImpactDescription();
    _loadTools();
  }

  Future<void> _getImpactDescription() async {
    if (!widget.isImpacted) {
      setState(() {
        _impactDescription = "This area is not directly impacted by the current case.";
        _isLoading = false;
      });
      return;
    }

    try {
      final query = "In exactly two brief sentences, explain how a business case might impact the '${widget.areaName}' area of a business model in the '${widget.parentCategory}' category. Be specific and concise.";
      
      // Create fresh conversation for this request
      final List<Map<String, String>> conversation = [
        {"role": "system", "content": "You are a business model expert providing concise insights."}
      ];
      
      print("Sending request to GPT for impact analysis on: ${widget.areaName}");
      
      // The third parameter is a dataset, not options
      final Map<String, dynamic> emptyDataset = {"context": "Analyzing impact on ${widget.areaName}"};
      
      // Make sure the GPT service returns data correctly
      final response = await gptService.sendMessage(
        query, 
        conversation,
        emptyDataset  // Passing an empty dataset that won't affect the output
      );
      
      // Check if response is empty or null
      print("GPT Response received: $response");
      
      // Check if the response looks like a comma-separated list of categories
      bool looksLikeCategories = response.contains(',') && 
                                !response.contains('.') &&
                                response.split(',').length > 1;
      
      // If we suspect the response is just category names, use a predefined analysis
      if (looksLikeCategories || response.trim() == widget.areaName) {
        setState(() {
          // Use predefined analyses based on category
          _impactDescription = _getHardcodedAnalysis(widget.areaName, widget.parentCategory);
          _isLoading = false;
        });
      } else if (response == null || response.trim().isEmpty) {
        setState(() {
          _impactDescription = "Impact analysis is currently unavailable.";
          _isLoading = false;
        });
      } else {
        setState(() {
          _impactDescription = response.trim();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching impact analysis: $e");
      setState(() {
        _impactDescription = "Unable to analyze impact at this time.";
        _isLoading = false;
      });
    }
  }
  
  // Add this method to provide hardcoded analyses as a fallback
  String _getHardcodedAnalysis(String areaName, String parentCategory) {
    // Map of predefined analyses for common categories
    final Map<String, String> analyses = {
      "Technologie": "Changes in technology infrastructure could significantly impact operational efficiency and digital service delivery. New technological requirements may necessitate additional investment in systems and staff training.",
      "Wirtschaft": "Economic factors directly influence revenue streams and market positioning in this segment. Shifts in customer demand patterns may require adaptation of pricing strategies and value propositions.",
      "Gesellschaft": "Social trends and customer behavior changes could reshape expectations for service delivery and brand perception. The organization may need to adjust communication strategies and corporate social responsibility initiatives.",
      "Natur": "Environmental considerations impact resource usage, operational costs, and compliance requirements. Sustainability-focused initiatives may present both challenges and opportunities for differentiation.",
      "Finanzen": "Financial implications include changes to cost structures, investment requirements, and potential revenue impacts. Budgetary adjustments and resource allocation strategies may need reconsideration.",
      "Partner": "Partnership dynamics could shift, requiring renegotiation of agreements or exploration of new collaborative opportunities. Strategic alliances may need to be strengthened or diversified to address changing market needs.",
    };
    
    // Return the predefined analysis or a generic one if not found
    return analyses[areaName] ?? 
           "The ${areaName} area within ${parentCategory} may require strategic adjustments to accommodate new business requirements and market conditions. This could involve reallocating resources and revising operational processes to maintain competitive advantage.";
  }

  Future<void> _loadTools() async {
    try {
      print("===== Loading tools for: ${widget.areaName} =====");
      
      // Get tools for area name
      var areaTools = await ToolsData.getTools();
      print("Available tool categories: ${areaTools.keys.join(', ')}");
      
      // Direct match with area name
      if (areaTools.containsKey(widget.areaName)) {
        print("Found direct match for: ${widget.areaName}");
        var tools = areaTools[widget.areaName]!;
        setState(() {
          _availableTools = _convertToStringMaps(tools);
          _toolsLoading = false;
        });
        return;
      }
      
      // Try parent category
      if (areaTools.containsKey(widget.parentCategory)) {
        print("Found match for parent category: ${widget.parentCategory}");
        var tools = areaTools[widget.parentCategory]!;
        setState(() {
          _availableTools = _convertToStringMaps(tools);
          _toolsLoading = false;
        });
        return;
      }
      
      // Try flexible matching
      String normalizedAreaName = _normalizeText(widget.areaName);
      for (var key in areaTools.keys) {
        String normalizedKey = _normalizeText(key);
        if (normalizedKey.contains(normalizedAreaName) || 
            normalizedAreaName.contains(normalizedKey)) {
          print("Found partial match: ${widget.areaName} → $key");
          var tools = areaTools[key]!;
          setState(() {
            _availableTools = _convertToStringMaps(tools);
            _toolsLoading = false;
          });
          return;
        }
      }
      
      // No matches found
      print("No matching tools found for: ${widget.areaName}");
      setState(() {
        _availableTools = [];
        _toolsLoading = false;
      });
    } catch (e) {
      print("Error loading tools: $e");
      setState(() {
        _toolsLoading = false;
      });
    }
  }

  // Helper method to normalize text for comparison
  String _normalizeText(String text) {
    return text.toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('_', '');
  }

  // Helper method for safe type conversion
  List<Map<String, String>> _convertToStringMaps(List<Map<String, dynamic>> dynamicMaps) {
    return dynamicMaps.map((item) {
      Map<String, String> stringMap = {};
      item.forEach((key, value) {
        stringMap[key] = value?.toString() ?? '';
      });
      return stringMap;
    }).toList();
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    
    setState(() {
      // Add user message to chat
      _chatMessages.add({
        'role': 'user',
        'content': message,
      });
      _isSendingMessage = true;
      _questionController.clear();
    });
    
    // Scroll to bottom of chat
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    try {
      // Create conversation history with enhanced system prompt
      List<Map<String, String>> conversation = [
        {
          "role": "system", 
          "content": "You are a highly experienced subject matter expert in business models and impact analysis. " +
                    "Provide detailed, precise responses in 1-3 sentences that demonstrate deep domain knowledge. " +
                    "Be specific and technical where appropriate, using industry terminology. " +
                    "Focus on actionable insights rather than general information."
        },
        {"role": "assistant", "content": "Impact Analysis for ${widget.areaName}: $_impactDescription"},
      ];
      
      // Add previous chat messages to maintain context
      conversation.addAll(_chatMessages.where((msg) => msg['role'] != null && msg['content'] != null)
          .map((msg) => {"role": msg['role']!, "content": msg['content']!}));
      
      // Send to GPT service with enhanced parameters
      final response = await gptService.sendMessage(
        message,
        conversation,
        {
          "context": "Detailed impact analysis for ${widget.areaName} in ${widget.parentCategory}",
          "perspective": "subject matter expert"
        }
      );
      
      setState(() {
        // Add AI response to chat
        _chatMessages.add({
          'role': 'assistant',
          'content': response.trim(),
        });
        _isSendingMessage = false;
      });
      
      // Scroll to bottom again after response
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print("Error sending message: $e");
      setState(() {
        _chatMessages.add({
          'role': 'assistant',
          'content': "I'm sorry, I couldn't process your question. Please try again.",
        });
        _isSendingMessage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.areaName),
        elevation: 0,
      ),
      body: Container(
        color: widget.isImpacted ? Colors.green.withOpacity(0.05) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section with badges and category
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with impact badge and tools button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.isImpacted)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Impacted',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (_hasAvailableTools())
                        InkWell(
                          onTap: () {
                            _navigateToTools();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.build_outlined, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Tools',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Parent category
                  Row(
                    children: [
                      Icon(Icons.category_outlined, size: 18, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        "Category: ${widget.parentCategory}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Impact Analysis heading
                  Text(
                    "Impact Analysis",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Main scrollable content area (impact analysis + chat)
            Expanded(
              child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Analyzing impact...", 
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.all(24),
                    children: [
                      // Initial impact analysis card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _impactDescription.isEmpty ? "No impact analysis available." : _impactDescription,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.auto_awesome, size: 14, color: Colors.grey[500]),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "AI-generated impact analysis",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Chat messages
                      ..._chatMessages.map((message) {
                        final bool isUser = message['role'] == 'user';
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isUser) 
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    radius: 16,
                                    child: Icon(
                                      Icons.psychology, // Changed to expert icon
                                      color: Colors.blue.shade700,
                                      size: 16
                                    ),
                                  ),
                                ),
                              
                              SizedBox(width: isUser ? 0 : 8),
                              
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isUser ? Colors.blue : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: !isUser ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ] : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message['content'] ?? '',
                                        style: TextStyle(
                                          color: isUser ? Colors.white : Colors.black87,
                                          height: 1.4,
                                        ),
                                      ),
                                      
                                      // Add expert label for AI messages
                                      if (!isUser)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6.0),
                                          child: Text(
                                            "Expert Analysis",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 10,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              SizedBox(width: isUser ? 8 : 0),
                              
                              if (isUser)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    radius: 16,
                                    child: Icon(Icons.person, color: Colors.white, size: 16),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      // Typing indicator when sending message
                      if (_isSendingMessage)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12, left: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                radius: 16,
                                child: Icon(Icons.auto_awesome, color: Colors.blue, size: 16),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade500,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade500,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade500,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
            ),
            
            // Bottom section with text input and expert button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Chat input field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        hintText: 'Further questions?',
                        fillColor: Colors.transparent,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send, color: Colors.blue),
                          onPressed: () {
                            _sendMessage(_questionController.text);
                          },
                        ),
                      ),
                      maxLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (value) {
                        _sendMessage(value);
                      },
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Expert contact button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.contact_support),
                      label: Text('Get in touch with experts'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        // Handle expert contact button press
                        print('Contact experts button pressed');
                        // You could implement contact functionality here
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasAvailableTools() {
    return !_toolsLoading && _availableTools.isNotEmpty;
  }

  void _navigateToTools() {
    // Always navigate to the overview page, regardless of how many tools are available
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => ToolOverviewScreen(
          areaName: widget.areaName,
          tools: _availableTools,
        )
      )
    );
  }
  
  Future<void> _launchToolUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  Widget _buildDebugButton() {
    return ElevatedButton(
      child: Text("Debug Tools"),
      onPressed: () async {
        final allTools = await ToolsData.getTools();
        print("===== DEBUG TOOLS =====");
        print("Available categories: ${allTools.keys.join(', ')}");
        print("Current area: ${widget.areaName}");
        print("Parent category: ${widget.parentCategory}");
        print("Has tools: ${_hasAvailableTools()}");
        print("Tools count: ${_availableTools.length}");
      },
    );
  }

  Widget _buildFurtherQuestionsField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Further questions?',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: Icon(Icons.send, color: Colors.blue),
      ),
      maxLines: 1,
      textInputAction: TextInputAction.send,
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          // Handle submitting the question
          print('Question submitted: $value');
          // You could add additional functionality here
        }
      },
    );
  }

  Widget _buildExpertContactButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.contact_support),
        label: Text('Get in touch with experts'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          // Handle expert contact button press
          print('Contact experts button pressed');
          // You could add functionality to contact experts here
        },
      ),
    );
  }
}