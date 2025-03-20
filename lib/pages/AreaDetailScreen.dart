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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.areaName),
        elevation: 0,
      ),
      body: Container(
        color: widget.isImpacted ? Colors.green.withOpacity(0.05) : null,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bold heading and impact badge
              
              
              // Impact badge and Tools button in the same row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.isImpacted)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      margin: EdgeInsets.only(right: 10),
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
                  // Tools button - only show if tools are available
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
              
              SizedBox(height: 12),
              
              if (false) // Set to true during debugging, false for production
                _buildDebugButton(),

              // Impact Analysis section
              Text(
                "Impact Analysis",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 16),
              
              // ChatGPT response
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
                  : Container(
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
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                _impactDescription.isEmpty ? "No impact analysis available." : _impactDescription,
                                style: TextStyle(
                                  fontSize: 18,
                                  height: 1.6,
                                ),
                              ),
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
              ),
            ],
          ),
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
}