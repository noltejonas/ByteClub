import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolsOverviewPage extends StatefulWidget {
  @override
  _ToolsOverviewPageState createState() => _ToolsOverviewPageState();
}

class _ToolsOverviewPageState extends State<ToolsOverviewPage> {
  Map<String, dynamic> _toolsData = {};
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadToolsData();
  }
  
  Future<void> _loadToolsData() async {
    try {
      // Load JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/data/tools.json');
      
      // Parse JSON
      final Map<String, dynamic> data = json.decode(jsonString);
      
      setState(() {
        _toolsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load tools: $e";
        _isLoading = false;
      });
      print("Error loading tools data: $e");
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Tools Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'Error loading tools',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadToolsData();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Display each category and its tools
        ..._toolsData.entries.map((entry) {
          final categoryName = entry.key;
          final toolsList = entry.value as List<dynamic>;
          
          // Only show categories with tools
          if (toolsList.isEmpty) return SizedBox.shrink();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 12),
                child: Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              // Tools in this category
              ...toolsList.map<Widget>((tool) => _buildToolCard(tool)).toList(),
              
              // Divider between categories
              if (entry.key != _toolsData.keys.last)
                Divider(height: 32, thickness: 1),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildToolCard(Map<String, dynamic> tool) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _launchURL(tool['link']),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tool image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                tool['image'],
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            
            // Tool details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    tool['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.open_in_new, size: 16),
                        label: Text('Visit Website'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                        ),
                        onPressed: () => _launchURL(tool['link']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}