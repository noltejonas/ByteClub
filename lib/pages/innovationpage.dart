import 'package:flutter/material.dart';

class Page1 extends StatefulWidget {
  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final PageController _pageController = PageController();
  final PageController _ideasController = PageController();
  int _currentPage = 0;
  int _currentIdeaPage = 0;

  final List<Map<String, dynamic>> innovations = [
    {
      'title': 'Quantum Computing for Drug Discovery',
      'description': 'Quantum computing can revolutionize drug discovery by...',
      'image': 'lib/images/inno1.png',
      'likes': 24,
      'category': 'Healthcare'
    },
    {
      'title': 'AI-Powered Diagnostics Tools',
      'description': 'Artificial intelligence (AI) is transforming diagnostics by...',
      'image': 'lib/images/inno2.jpeg',
      'likes': 18,
      'category': 'Healthcare'
    },
    {
      'title': 'Wearable Health Devices and Sensors',
      'description': 'Wearable health devices monitor vital signs like heart rate,...',
      'image': 'lib/images/inno3.jpeg',
      'likes': 31,
      'category': 'Technology'
    },
    {
      'title': 'Telemedicine and Remote Monitoring',
      'description': 'Telemedicine platforms allow healthcare providers to...',
      'image': 'lib/images/inno4.png',
      'likes': 15,
      'category': 'Healthcare'
    },
    {
      'title': 'Personalized Medicine and Genomics',
      'description': 'Personalized medicine tailors treatments based on an...',
      'image': 'lib/images/inno5.png',
      'likes': 27,
      'category': 'Research'
    },
  ];
  
  // Customer ideas for improving the company
  final List<Map<String, dynamic>> customerIdeas = [
    {
      'name': 'Emma Thompson',
      'avatar': 'https://i.pravatar.cc/150?img=5',
      'title': 'Sustainable Supply Chain Initiative',
      'description': 'I believe we should implement a fully transparent supply chain tracking system using blockchain technology. This would allow customers to see the environmental impact of every product and boost our sustainability credentials.',
      'likes': 42,
      'date': '3 days ago'
    },
    {
      'name': 'Michael Chen',
      'avatar': 'https://i.pravatar.cc/150?img=12',
      'title': 'AI-Powered Customer Support',
      'description': 'We should develop an AI chatbot that can handle routine customer inquiries 24/7. This would reduce wait times significantly and allow human agents to focus on more complex issues that require personal attention.',
      'likes': 31,
      'date': '1 week ago'
    },
    {
      'name': 'Sarah Johnson',
      'avatar': 'https://i.pravatar.cc/150?img=20',
      'title': 'Employee Wellness Program',
      'description': 'I suggest implementing a comprehensive wellness program that includes mental health resources, fitness incentives, and flexible working arrangements. Happy employees lead to better customer service and innovation!',
      'likes': 29,
      'date': '2 weeks ago'
    },
    {
      'name': 'David Rodriguez',
      'avatar': 'https://i.pravatar.cc/150?img=7',
      'title': 'Cross-Departmental Innovation Teams',
      'description': 'We should create small innovation teams that include members from different departments. These teams would work on short-term projects aimed at solving specific business challenges, fostering collaboration and fresh thinking.',
      'likes': 37,
      'date': '5 days ago'
    },
    {
      'name': 'Olivia Kim',
      'avatar': 'https://i.pravatar.cc/150?img=23',
      'title': 'Community Engagement Platform',
      'description': 'Let\'s develop a platform where customers can share ideas, provide feedback, and even participate in product testing. This direct engagement would give us valuable insights and make customers feel like true stakeholders.',
      'likes': 45,
      'date': '4 days ago'
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int page = _pageController.page!.round();
      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });
      }
    });
    
    _ideasController.addListener(() {
      int page = _ideasController.page!.round();
      if (_currentIdeaPage != page) {
        setState(() {
          _currentIdeaPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ideasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA), // Light gray background
      appBar: AppBar(
        title: Text(
          'Innovation Hub',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured innovations section
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Featured Innovations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            // Featured innovations carousel
            Container(
              height: 450,
              child: PageView.builder(
                controller: _pageController,
                itemCount: innovations.length,
                itemBuilder: (context, index) {
                  return _buildFeatureCard(innovations[index], index);
                },
              ),
            ),
            
            // Page indicators for top carousel
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(innovations.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index 
                        ? Colors.blue 
                        : Colors.grey.withOpacity(0.3),
                  ),
                );
              }),
            ),
            
            SizedBox(height: 32),
            
            // Customer ideas section title
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Ideas from the Team',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            // Customer ideas carousel
            Container(
              height: 250,
              child: PageView.builder(
                controller: _ideasController,
                itemCount: customerIdeas.length,
                itemBuilder: (context, index) {
                  return _buildCustomerIdeaCard(customerIdeas[index], index);
                },
              ),
            ),
            
            // Page indicators for customer ideas carousel
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(customerIdeas.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIdeaPage == index 
                        ? Colors.orange 
                        : Colors.grey.withOpacity(0.3),
                  ),
                );
              }),
            ),
            
            SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open form to add idea
          _showAddIdeaDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> innovation, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with overlay gradient
              Stack(
                children: [
                  Image.asset(
                    innovation['image'],
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Category badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        innovation['category'],
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Content section
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      innovation['title'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      innovation['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Interaction row
                    Row(
                      children: [
                        // Likes counter
                        Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.red.shade300, size: 20),
                            SizedBox(width: 4),
                            Text(
                              '${innovation['likes']}',
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        // Action buttons
                        _buildActionButton(Icons.thumb_up_outlined, 'Like'),
                        SizedBox(width: 12),
                        _buildActionButton(Icons.comment_outlined, 'Comment'),
                        SizedBox(width: 12),
                        _buildActionButton(Icons.share_outlined, 'Share'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCustomerIdeaCard(Map<String, dynamic> idea, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info row with avatar
                Row(
                  children: [
                    // User avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(idea['avatar']),
                    ),
                    SizedBox(width: 12),
                    // User name and date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          idea['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          idea['date'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    // Highlighted tag
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        'Idea',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Idea title
                Text(
                  idea['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                SizedBox(height: 8),
                
                // Idea description
                Expanded(
                  child: Text(
                    idea['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Interaction row at bottom
                Row(
                  children: [
                    // Likes counter
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red.shade300, size: 18),
                        SizedBox(width: 4),
                        Text(
                          '${idea['likes']}',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    // Action buttons
                    _buildActionButton(Icons.thumb_up_outlined, 'Support'),
                    SizedBox(width: 12),
                    _buildActionButton(Icons.comment_outlined, 'Comment'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.black54),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddIdeaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Share Your Idea',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Title',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe your idea...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Your idea has been submitted!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
