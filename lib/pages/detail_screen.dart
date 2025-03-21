import 'package:flutter/material.dart';
import 'package:byteclub/pages/AreaDetailScreen.dart';

class DetailScreen extends StatelessWidget {
  final String parentCategory;
  final Map<String, dynamic> details;
  final List<String> impactedParts;

  const DetailScreen({
    Key? key,
    required this.parentCategory,
    required this.details,
    required this.impactedParts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          parentCategory,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          // Display header image for top-level categories
          if (parentCategory == "Company" ||
              parentCategory == "Unternehmen" ||
              parentCategory == "Business Model")
            Container(
              margin: EdgeInsets.only(bottom: 16, top: 8),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset('lib/images/Company.png', fit: BoxFit.contain),
            ),

          // Render all child items
          ...details.keys
              .map((key) => _buildDetailCard(context, key, details[key]))
              .toList(),

          // Bottom padding
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    String key,
    Map<String, dynamic> content,
  ) {
    final String name = content['name'] ?? key;
    final bool isImpacted = impactedParts.contains(name);
    final String description =
        content['description'] ?? 'No description available';
    final Map<String, dynamic> subDetails = content['children'] ?? {};

    // Select icon based on category or subcategory
    IconData cardIcon;
    Color cardColor;

    if (parentCategory == "Stakeholder" || name.contains("Stakeholder")) {
      cardIcon = Icons.people;
      cardColor = Colors.blue.shade700;
    } else if (parentCategory == "Interaktionsthemen" ||
        name.contains("Interaktion")) {
      cardIcon = Icons.settings_input_component;
      cardColor = Colors.orange.shade700;
    } else if (parentCategory == "Umweltsphaeren" || name.contains("Umwelt")) {
      cardIcon = Icons.public;
      cardColor = Colors.green.shade700;
    } else if (parentCategory == "Unternehmen" ||
        name.contains("Unternehmen")) {
      cardIcon = Icons.business;
      cardColor = Colors.blue.shade700;
    } else {
      cardIcon = Icons.category;
      cardColor = Colors.grey.shade700;
    }

    // Use the same card styling as the homepage
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isImpacted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (subDetails.isNotEmpty) {
                // Navigate to next level of details if there are children
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => DetailScreen(
                          parentCategory: name,
                          details: subDetails,
                          impactedParts: impactedParts,
                        ),
                  ),
                );
              } else {
                // Navigate to Area Detail Screen for leaf nodes
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AreaDetailScreen(
                          areaName: name,
                          isImpacted: isImpacted,
                          parentCategory: parentCategory,
                        ),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        cardIcon,
                        color: isImpacted ? Colors.green.shade700 : cardColor,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (isImpacted)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
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
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                  if (description != 'No description available') ...[
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 34.0),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                  if (subDetails.isNotEmpty) ...[
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 34.0),
                      child: Text(
                        'Contains ${subDetails.length} elements',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
