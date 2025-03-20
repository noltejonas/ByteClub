import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String parentCategory;
  final Map<String, dynamic> details;

  DetailScreen({
    required this.parentCategory,
    required this.details,
  });

  Widget _buildSubCategoryCard(BuildContext context, String subCategory, Map<String, dynamic> subDetails) {
    return Card(
      child: InkWell(
        onTap: () {
          if (subDetails.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  parentCategory: subCategory,
                  details: subDetails,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(subCategory, style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$parentCategory"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: details.keys.map<Widget>((key) {
            return _buildSubCategoryCard(context, key, details[key]);
          }).toList(),
        ),
      ),
    );
  }
}