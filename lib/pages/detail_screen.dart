import 'package:byteclub/pages/3D_page.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text(parentCategory),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Add 3D viewer at the top if this is a top-level category
          if (parentCategory == "Company" || parentCategory == "Business Model")
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Building3DViewer(
                modelPath: 'assets/models/building.obj',
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: details.keys
                  .map((key) => _buildDetailCard(context, key, details[key]))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String key, Map<String, dynamic> content) {
    final String name = content['name'] ?? key;
    final bool isImpacted = impactedParts.contains(name);
    final String description = content['description'] ?? 'No description available';
    final Map<String, dynamic> subDetails = content['children'] ?? {};

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      color: isImpacted ? Colors.green[100] : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isImpacted ? Colors.green : Colors.grey.shade300,
          width: isImpacted ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: subDetails.isNotEmpty
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      parentCategory: name,
                      details: subDetails,
                      impactedParts: impactedParts,
                    ),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (subDetails.isNotEmpty)
                    Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              if (isImpacted) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Impacted',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}