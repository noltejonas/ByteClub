import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class Page3 extends StatefulWidget {
  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedPosition = 'Software Engineer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Handle save action
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100], // Set a light background color
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150',
                ),
                backgroundColor: Colors.grey,
              ),
              SizedBox(height: 20),
              buildTextField(_nameController, 'Name', 'John Doe'),
              buildDropdownField(),
              buildTextField(_emailController, 'Email', 'johndoe@example.com'),
              buildTextField(_phoneController, 'Phone', '+123 456 7890'),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label,
    String placeholder,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.black45),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: _selectedPosition,
        items:
            <String>[
              'Software Engineer',
              'Product Manager',
              'Designer',
              'Data Scientist',
              'Marketing Specialist',
              'HR Manager',
              'Finance Manager',
              'Intern',
              'CEO',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: Colors.black)),
              );
            }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedPosition = newValue!;
          });
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
        dropdownColor: Colors.white,
      ),
    );
  }
}
