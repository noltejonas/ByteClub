import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class Page1 extends StatelessWidget {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.network(
                  'https://via.placeholder.com/150',
                  height: 100,
                  width: 100,
                ),
                Text('Card ${index + 1}', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {
                      // Handle upvote action
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_down),
                    onPressed: () {
                      // Handle downvote action
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
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
