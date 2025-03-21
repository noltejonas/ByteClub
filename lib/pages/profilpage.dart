import 'package:flutter/material.dart';
import 'package:byteclub/pages/tools_overview_page.dart';

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;

  // User profile data
  Map<String, dynamic> _userData = {
    'name': 'Alexander Miller',
    'role': 'Innovation Manager',
    'avatar': 'https://i.pravatar.cc/300?img=8',
    'email': 'alex.miller@company.com',
    'phone': '+1 (555) 123-4567',
    'department': 'Research & Development',
    'location': 'San Francisco, CA',
    'bio':
        'Passionate about driving innovation and leading cross-functional teams to develop cutting-edge solutions. 8+ years of experience in product development and strategic planning.',
    'expertise': [
      'Strategic Planning',
      'Agile Development',
      'Digital Transformation',
      'Team Leadership',
    ],
    'stats': {
      'ideas': 14,
      'contributions': 27,
      'implementations': 9,
      'followers': 132,
    },
    'recentActivity': [
      {
        'type': 'comment',
        'content':
            'Great idea! I think we should consider implementing this in Q3.',
        'target': 'AI-Powered Customer Support',
        'time': '2 days ago',
      },
      {
        'type': 'idea',
        'content': 'Virtual Reality Training Program for New Employees',
        'likes': 24,
        'time': '1 week ago',
      },
      {
        'type': 'implementation',
        'content': 'Led the implementation of the new CRM system',
        'result': 'Increased customer satisfaction by 18%',
        'time': '3 weeks ago',
      },
      {
        'type': 'comment',
        'content': 'I\'d be interested in joining this project team.',
        'target': 'Blockchain for Supply Chain',
        'time': '1 month ago',
      },
    ],
    'achievements': [
      {
        'title': 'Innovation Champion',
        'description':
            'Awarded for leading 5+ successful innovation initiatives',
        'icon': Icons.emoji_events,
        'date': 'June 2024',
      },
      {
        'title': 'Idea Generator',
        'description': 'Contributed 10+ implemented ideas',
        'icon': Icons.lightbulb,
        'date': 'March 2024',
      },
      {
        'title': 'Team Collaborator',
        'description': 'Participated in 15+ cross-functional projects',
        'icon': Icons.groups,
        'date': 'January 2024',
      },
    ],
    'savedIdeas': [
      {
        'title': 'AI-Powered Predictive Maintenance',
        'category': 'Operations',
        'creator': 'Emily Chen',
        'date': 'May 15, 2024',
      },
      {
        'title': 'Customer Feedback Integration System',
        'category': 'Customer Experience',
        'creator': 'David Rodriguez',
        'date': 'April 22, 2024',
      },
      {
        'title': 'Gamified Learning Platform',
        'category': 'HR & Training',
        'creator': 'Sarah Johnson',
        'date': 'April 10, 2024',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 290,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  // Move Tools button to leading position
                  leading: IconButton(
                    icon: Icon(Icons.build_outlined),
                    tooltip: 'Tools Overview',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ToolsOverviewPage(),
                        ),
                      );
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(_isEditing ? Icons.check : Icons.edit),
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                          if (!_isEditing) {
                            // Save changes logic would go here
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Profile updated successfully'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.settings_outlined),
                      onPressed: () {
                        // Navigate to settings
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildProfileHeader(),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue.shade700,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: Colors.blue.shade700,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Activity'),
                      Tab(text: 'Saved'),
                    ],
                  ),
                ),
              ],
          // Fixed bottom overflow by using a constrained height content container
          body: Container(
            // Constrain the height to prevent overflow
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight -
                50, // Account for TabBar height
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildActivityTab(),
                _buildSavedTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: 20),
          // Profile image
          GestureDetector(
            onTap:
                _isEditing
                    ? () {
                      // Photo selection logic
                    }
                    : null,
            child: Stack(
              children: [
                Hero(
                  tag: 'profile-image',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_userData['avatar']),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 18,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Name and role
          _isEditing
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    TextField(
                      controller: TextEditingController(
                        text: _userData['name'],
                      ),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(
                        text: _userData['role'],
                      ),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Text(
                    _userData['name'],
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _userData['role'],
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                ],
              ),

          SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(_userData['stats']['ideas'].toString(), 'Ideas'),
              _buildStatDivider(),
              _buildStatItem(
                _userData['stats']['contributions'].toString(),
                'Contributions',
              ),
              _buildStatDivider(),
              _buildStatItem(
                _userData['stats']['implementations'].toString(),
                'Implemented',
              ),
              _buildStatDivider(),
              _buildStatItem(
                _userData['stats']['followers'].toString(),
                'Followers',
              ),
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildOverviewTab() {
    // Reduce bottom padding to avoid overflow
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      children: [
        // Contact information card
        _buildSectionCard(
          title: 'Contact Information',
          icon: Icons.contact_mail_outlined,
          child: _isEditing ? _buildEditableContactInfo() : _buildContactInfo(),
        ),

        SizedBox(height: 16),

        // Bio section
        _buildSectionCard(
          title: 'About',
          icon: Icons.person_outline,
          child:
              _isEditing
                  ? TextField(
                    controller: TextEditingController(text: _userData['bio']),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tell us about yourself...',
                      isDense: true,
                      contentPadding: EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                  : Text(
                    _userData['bio'],
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
        ),

        SizedBox(height: 16),

        // Areas of expertise
        _buildSectionCard(
          title: 'Areas of Expertise',
          icon: Icons.trending_up,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _isEditing
                    ? [
                      ..._userData['expertise']
                          .map<Widget>(
                            (expertise) => _buildExpertiseChip(expertise, true),
                          )
                          .toList(),
                      ActionChip(
                        avatar: Icon(Icons.add, size: 16, color: Colors.blue),
                        label: Text('Add'),
                        onPressed: () {
                          // Show dialog to add expertise
                        },
                      ),
                    ]
                    : _userData['expertise']
                        .map<Widget>(
                          (expertise) => _buildExpertiseChip(expertise, false),
                        )
                        .toList(),
          ),
        ),

        SizedBox(height: 16),

        // Achievements section
        _buildSectionCard(
          title: 'Achievements',
          icon: Icons.emoji_events_outlined,
          child: Column(
            children:
                _userData['achievements'].map<Widget>((achievement) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          achievement == _userData['achievements'].last
                              ? 0
                              : 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            achievement['icon'] as IconData,
                            color: Colors.amber.shade800,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      achievement['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    achievement['date'],
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                achievement['description'],
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableContactInfo() {
    return Column(
      children: [
        TextField(
          controller: TextEditingController(text: _userData['email']),
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: TextEditingController(text: _userData['phone']),
          decoration: InputDecoration(
            labelText: 'Phone',
            prefixIcon: Icon(Icons.phone_outlined),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: TextEditingController(text: _userData['department']),
          decoration: InputDecoration(
            labelText: 'Department',
            prefixIcon: Icon(Icons.business_outlined),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: TextEditingController(text: _userData['location']),
          decoration: InputDecoration(
            labelText: 'Location',
            prefixIcon: Icon(Icons.location_on_outlined),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.email_outlined, color: Colors.blue.shade700),
          title: Text(
            'Email',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          subtitle: Text(
            _userData['email'],
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.phone_outlined, color: Colors.blue.shade700),
          title: Text(
            'Phone',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          subtitle: Text(
            _userData['phone'],
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.business_outlined, color: Colors.blue.shade700),
          title: Text(
            'Department',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          subtitle: Text(
            _userData['department'],
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        Divider(),
        ListTile(
          leading: Icon(
            Icons.location_on_outlined,
            color: Colors.blue.shade700,
          ),
          title: Text(
            'Location',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          subtitle: Text(
            _userData['location'],
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ],
    );
  }

  Widget _buildExpertiseChip(String expertise, bool removable) {
    return Chip(
      label: Text(
        expertise,
        style: TextStyle(fontSize: 13, color: Colors.blue.shade800),
      ),
      backgroundColor: Colors.blue.shade50,
      padding: EdgeInsets.symmetric(horizontal: 4),
      deleteIcon: removable ? Icon(Icons.close, size: 16) : null,
      onDeleted:
          removable
              ? () {
                // Remove expertise logic
              }
              : null,
    );
  }

  Widget _buildActivityTab() {
    // Reduce bottom padding to avoid overflow
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _userData['recentActivity'].length,
      itemBuilder: (context, index) {
        final activity = _userData['recentActivity'][index];

        IconData activityIcon;
        Color iconColor;

        switch (activity['type']) {
          case 'idea':
            activityIcon = Icons.lightbulb_outline;
            iconColor = Colors.amber.shade700;
            break;
          case 'comment':
            activityIcon = Icons.comment_outlined;
            iconColor = Colors.blue.shade700;
            break;
          case 'implementation':
            activityIcon = Icons.rocket_launch;
            iconColor = Colors.green.shade700;
            break;
          default:
            activityIcon = Icons.star_outline;
            iconColor = Colors.grey.shade700;
        }

        return Container(
          margin: EdgeInsets.only(
            bottom: index == _userData['recentActivity'].length - 1 ? 0 : 16,
          ),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(activityIcon, color: iconColor, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                activity['type'].substring(0, 1).toUpperCase() +
                                    activity['type'].substring(1),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: iconColor,
                                ),
                              ),
                              Text(
                                activity['time'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          if (activity['target'] != null) ...[
                            SizedBox(height: 4),
                            Text(
                              'On: ${activity['target']}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                          SizedBox(height: 8),
                          Text(
                            activity['content'],
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                          if (activity['result'] != null) ...[
                            SizedBox(height: 8),
                            Text(
                              'Result: ${activity['result']}',
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                          if (activity['likes'] != null) ...[
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 14,
                                  color: Colors.red.shade400,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${activity['likes']} likes',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedTab() {
    // Reduce bottom padding to avoid overflow
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _userData['savedIdeas'].length,
      itemBuilder: (context, index) {
        final idea = _userData['savedIdeas'][index];

        return Container(
          margin: EdgeInsets.only(
            bottom: index == _userData['savedIdeas'].length - 1 ? 0 : 16,
          ),
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
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              idea['title'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      idea['creator'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      idea['date'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    idea['category'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.bookmark, color: Colors.amber),
              onPressed: () {
                // Remove from bookmarks
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed from saved ideas'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            onTap: () {
              // View idea details
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.blue.shade700),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
