import 'package:flutter/material.dart';
import 'dart:ui'; // For BackdropFilter

class Page1 extends StatelessWidget {
  final PageController _pageController = PageController();

  final List<String> cardTexts = [
    'Quantum Computing for Drug Discovery\n\nQuantum computing can revolutionize drug discovery by simulating molecular interactions at an unprecedented scale and speed. This technology can help identify potential drug candidates more efficiently, reducing the time and cost associated with bringing new medications to market.',
    'AI-Powered Diagnostics\n\nArtificial intelligence (AI) is transforming diagnostics by analyzing medical images and patient data to detect diseases earlier and more accurately. AI algorithms can assist radiologists in identifying anomalies in X-rays, MRIs, and CT scans, leading to faster and more precise diagnoses.',
    'Wearable Health Devices\n\nWearable health devices, such as smartwatches and fitness trackers, monitor vital signs like heart rate, blood pressure, and oxygen levels in real-time. These devices provide continuous health data, enabling proactive management of chronic conditions and early detection of potential health issues.',
    'Telemedicine and Remote Monitoring\n\nTelemedicine platforms allow healthcare providers to conduct virtual consultations with patients, improving access to care, especially in remote areas. Remote monitoring technologies enable continuous tracking of patients\' health status, reducing the need for frequent in-person visits.',
    'Personalized Medicine\n\nPersonalized medicine tailors treatments based on an individual\'s genetic makeup, lifestyle, and environment. Advances in genomics and biotechnology enable healthcare providers to develop customized treatment plans that are more effective and have fewer side effects.',
  ];

  final List<String> imagePaths = [
    'lib/images/inno1.jpeg',
    'lib/images/inno2.jpeg',
    'lib/images/inno3.jpeg',
    'lib/images/inno4.jpeg',
    'lib/images/inno5.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20), // Add spacing to avoid top overlap
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
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Other Content Here', style: TextStyle(fontSize: 24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(int index) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Stack(
        children: [
          Container(
            height: 300, // Adjust card height to fit content
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePaths[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardTexts[index].split('\n\n')[0], // Headline
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  cardTexts[index].split('\n\n')[1], // Beginning of the text
                  style: TextStyle(fontSize: 14, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up, color: Colors.white),
                    onPressed: () {
                      // Handle upvote action
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_down, color: Colors.white),
                    onPressed: () {
                      // Handle downvote action
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      // Handle share action
                    },
                  ),
                ],
              ),
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
        double zoom = 1.0 + (1.0 - selectedness) * 0.5;
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
}
