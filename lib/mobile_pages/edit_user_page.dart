import 'dart:async';

import 'package:alamanah/database/mongodb.dart';
import 'package:alamanah/model/user';
import 'package:flutter/material.dart';

class EditUserPage extends StatefulWidget {
  final User user;
  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formGlobalKey = GlobalKey<FormState>();
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _ageController = TextEditingController();
  late TextEditingController _mobileController = TextEditingController();
  late Gender _selectedGender;

  bool _isSaving = false; // show loading while saving

  String _name = '';
  String _email = '';
  int _age = 0;
  String _mobile = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _mobileController = TextEditingController(text: widget.user.contactMobile);
    _emailController = TextEditingController(text: widget.user.email);

    _selectedGender = Gender.values.firstWhere(
      (g) => g.sex.toLowerCase() == widget.user.gender.toLowerCase(),
      orElse: () => Gender.male, // fallback
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _formGlobalKey.currentState?.dispose();
    super.dispose();
  }

  Future<void> saveUser() async {
    if (!_formGlobalKey.currentState!.validate()) {
      return; // form is not valid
    } else {
      _formGlobalKey.currentState!.save();
    }

    setState(() {
      _isSaving = true;
    });

    final updatedUser = User(
      id: widget.user.id,
      name: _name,
      gender: _selectedGender.sex,
      email: _email,
      age: _age,
      contactMobile: _mobile,
    );

    try {
      bool success = await MongoDatabase.updateUser(updatedUser);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ User updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, updatedUser); // return updated user
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ No matching user found to update'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏰ Connection timed out. Please try again.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to update user: $e'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit User")),
      body: Form(
        key: _formGlobalKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                validator: (value) => value == null || value.isEmpty
                    ? 'Name cannot be empty'
                    : null,
                onSaved: (newValue) => _name = newValue!,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // rounded corners
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.grey, // default border color
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.blue, // border color when focused
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField(
                      initialValue: _selectedGender,
                      items: Gender.values.map((g) {
                        return DropdownMenuItem(value: g, child: Text(g.sex));
                      }).toList(),
                      onChanged: (newValue) {
                        _selectedGender = newValue!;
                      },
                      decoration: InputDecoration(
                        labelText: "Gender",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _ageController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Age cannot be empty'
                          : null,
                      onSaved: (newValue) => _age = int.parse(newValue!),
                      decoration: InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // rounded corners
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.grey, // default border color
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.blue, // border color when focused
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                validator: (value) => value == null || value.isEmpty
                    ? 'Email cannot be empty'
                    : null,
                onSaved: (newValue) => _email = newValue!,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // rounded corners
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.grey, // default border color
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.blue, // border color when focused
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _mobileController,
                onSaved: (newValue) => _mobile = newValue!,
                decoration: InputDecoration(
                  labelText: 'Mobile',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // rounded corners
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.grey, // default border color
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.blue, // border color when focused
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: saveUser,
                      child: const Text("Save"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
