import 'dart:convert';
import 'package:flutter/services.dart';

class ToolsData {
  static Map<String, List<Map<String, dynamic>>> _toolsCache = {};
  
  static Future<Map<String, List<Map<String, dynamic>>>> getTools() async {
    if (_toolsCache.isNotEmpty) return _toolsCache;  // <-- FIXED
    
    try {
      // Load the JSON file from assets
      final String response = await rootBundle.loadString('assets/data/tools.json');
      final data = await json.decode(response);
      
      // Convert to the right format
      _toolsCache = {};
      
      data.forEach((areaName, tools) {
        _toolsCache[areaName] = List<Map<String, dynamic>>.from(
          tools.map((tool) => Map<String, dynamic>.from(tool))
        );
      });
      
      return _toolsCache;
    } catch (e) {
      print('Error loading tools data: $e');
      return {};
    }
  }
  
  static Future<List<Map<String, dynamic>>> getToolsForArea(String areaName) async {
    try {
      final tools = await getTools();
      return tools[areaName] ?? [];
    } catch (e) {
      print('Error fetching tools for $areaName: $e');
      return [];
    }
  }
  
  // Helper method to find tools by keywords in area name
  static Future<List<Map<String, dynamic>>> getToolsForAreaByKeywords(String areaName) async {
    try {
      final tools = await getTools();
      
      // Direct match
      if (tools.containsKey(areaName)) {
        return tools[areaName] ?? [];
      }
      
      // Look for partial matches in area names
      final List<Map<String, dynamic>> result = [];
      final String lowerAreaName = areaName.toLowerCase();
      
      tools.forEach((key, value) {
        if (key.toLowerCase().contains(lowerAreaName) || 
            lowerAreaName.contains(key.toLowerCase())) {
          result.addAll(value);
        }
      });
      
      return result;
    } catch (e) {
      print('Error finding tools by keywords for $areaName: $e');
      return [];
    }
  }
  
  // Update the flexible matching method to better handle German terms:

  static Future<List<Map<String, dynamic>>?> getToolsForAreaFlexible(String areaName, String parentCategory) async {
    try {
      final allTools = await getTools();
      print("Searching tools for area: $areaName");
      
      // Normalize area names
      String normalizeText(String text) {
        return text.toLowerCase()
            .replaceAll('ä', 'ae')
            .replaceAll('ö', 'oe')
            .replaceAll('ü', 'ue')
            .replaceAll('ß', 'ss')
            .replaceAll(' ', '')
            .replaceAll('-', '')
            .replaceAll('_', '');
      }
      
      // Check for exact matches first
      if (allTools.containsKey(areaName)) {
        print("Found exact match: $areaName");
        return allTools[areaName];
      }
      
      // Try parent category
      if (allTools.containsKey(parentCategory)) {
        print("Found parent category match: $parentCategory");
        return allTools[parentCategory];
      }
      
      // Try with normalized names
      String normalizedAreaName = normalizeText(areaName);
      
      // Try all variations with normalized text
      for (var key in allTools.keys) {
        String normalizedKey = normalizeText(key);
        
        // Check for exact normalized match
        if (normalizedKey == normalizedAreaName) {
          print("Found normalized match: $areaName → $key");
          return allTools[key];
        }
        
        // Check if area name is contained in a key or vice versa
        if (normalizedKey.contains(normalizedAreaName) || 
            normalizedAreaName.contains(normalizedKey)) {
          print("Found partial match: $areaName → $key");
          return allTools[key];
        }
      }
      
      // Special case mappings for common terms
      Map<String, String> specialMappings = {
        "geschaeftsprozesse": "Geschaeftsprozesse",
        "geschäftsprozesse": "Geschaeftsprozesse", 
        "geschäftsmodell": "Geschaeftsmodelle",
        "geschaeftsmodell": "Geschaeftsmodelle",
        "management": "Managementprozesse",
        "strategie": "Strategie",
        "swot": "Strategie",
        "porter": "Konkurrenz",
        "pestel": "Wirtschaft",
        "kosten": "Unterstützungsprozesse",
        "nutzen": "Unterstützungsprozesse",
      };
      
      for (var entry in specialMappings.entries) {
        if (normalizedAreaName.contains(entry.key)) {
          print("Found special mapping: $areaName → ${entry.value}");
          return allTools[entry.value] ?? [];
        }
      }
      
      print("No matching tools found for: $areaName");
      return [];
    } catch (e) {
      print("Error in flexible tool matching: $e");
      return [];
    }
  }
}