import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class Page1 extends StatelessWidget {
  final PageController _pageController = PageController();

  final List<String> cardTexts = [
    'Quantum Computing for Drug Discovery\n\nQuantum computing can revolutionize drug discovery by simulating molecular interactions at an unprecedented scale and speed.',
    'AI-Powered Diagnostics\n\nArtificial intelligence (AI) is transforming diagnostics by analyzing medical images and patient data.',
    'Wearable Health Devices\n\nWearable health devices monitor vital signs like heart rate, blood pressure, and oxygen levels in real-time.',
    'Telemedicine and Remote Monitoring\n\nTelemedicine platforms allow healthcare providers to conduct virtual consultations with patients.',
    'Personalized Medicine\n\nPersonalized medicine tailors treatments based on an individual\'s genetic makeup, lifestyle, and environment.',
  ];

  final List<String> imagePaths = [
    'lib/images/inno1.png',
    'lib/images/inno2.jpeg',
    'lib/images/inno3.jpeg',
    'lib/images/inno4.png',
    'lib/images/inno5.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 60),
          Expanded(
            flex: 1,
            child: PageView(
              controller: _pageController,
              children: List.generate(5, (index) => buildCard(index)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => buildIndicator(index)),
          ),
          // Use a Container without Expanded to control space
          Container(
            margin: EdgeInsets.only(
              top: 10,
              bottom: 60,
            ), // Add bottom margin for space
            child: buildAddInnovationCard(context),
          ),
        ],
      ),
    );
  }

  Widget buildCard(int index) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              image: DecorationImage(
                image: AssetImage(imagePaths[index]),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardTexts[index].split('\n\n')[0],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 6,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  cardTexts[index].split('\n\n')[1],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 6,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 10,
            child: Column(
              mainAxisSize:
                  MainAxisSize
                      .min, // Minimiert den vertikalen Platz, den die Column beansprucht
              children: [
                IconButton(
                  padding:
                      EdgeInsets
                          .zero, // Entfernt jeglichen zusätzlichen Abstand
                  iconSize: 23,
                  icon: Icon(
                    Icons.thumb_up,
                    color: const Color.fromARGB(255, 186, 185, 185),
                  ),
                  onPressed: () {
                    // Handle upvote action
                  },
                ),
                IconButton(
                  padding:
                      EdgeInsets
                          .zero, // Entfernt jeglichen zusätzlichen Abstand
                  iconSize: 23,
                  icon: Icon(
                    Icons.thumb_down,
                    color: const Color.fromARGB(255, 186, 185, 185),
                  ),
                  onPressed: () {
                    // Handle downvote action
                  },
                ),
                IconButton(
                  padding:
                      EdgeInsets
                          .zero, // Entfernt jeglichen zusätzlichen Abstand
                  iconSize: 23,
                  icon: Icon(
                    Icons.share,
                    color: const Color.fromARGB(255, 186, 185, 185),
                  ),
                  onPressed: () {
                    // Handle share action
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIndicator(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double selectedness =
            _pageController.page == null
                ? 0
                : (_pageController.page! - index).abs().clamp(0.0, 1.0);
        return Container(
          width: 10.0,
          height: 10.0,
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(selectedness == 0 ? 1.0 : 0.5),
          ),
        );
      },
    );
  }

  Widget buildAddInnovationCard(BuildContext context) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.black, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Your Innovation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
