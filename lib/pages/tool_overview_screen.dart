import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolOverviewScreen extends StatelessWidget {
  final String areaName;
  final List<Map<String, String>> tools;

  const ToolOverviewScreen({
    Key? key,
    required this.areaName,
    required this.tools,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if we should use grid layout based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final useGrid = screenWidth > 600; // Use grid for tablets and larger screens
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Tools for ${areaName}'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Tools',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'These tools can help you address impacts in the ${areaName} area',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: tools.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No tools available for this area',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : useGrid
                      // Grid view for larger screens
                      ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: tools.length,
                          itemBuilder: (context, index) {
                            final tool = tools[index];
                            return _buildToolCard(context, tool);
                          },
                        )
                      // List view for phones
                      : ListView.builder(
                          itemCount: tools.length,
                          itemBuilder: (context, index) {
                            final tool = tools[index];
                            return _buildToolCard(context, tool);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, Map<String, String> tool) {
    return Card(
      margin: EdgeInsets.only(bottom: 24),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias, // Important for the image to respect the card's rounded corners
      child: InkWell(
        onTap: () => _launchUrl(tool['link'] ?? ''),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large tool image at the top
            AspectRatio(
              aspectRatio: 16 / 9, // 16:9 aspect ratio for images
              child: Image.asset(
                tool['image'] ?? 'lib/images/icon.png',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.blue.shade100,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 50,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Tool details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tool name
                  Text(
                    tool['name'] ?? 'Tool',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  // Tool description
                  Text(
                    tool['description'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Open tool button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: Icon(Icons.open_in_new, size: 16),
                        label: Text('Open Tool'),
                        onPressed: () => _launchUrl(tool['link'] ?? ''),
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('Could not launch $url');
    }
  }
}