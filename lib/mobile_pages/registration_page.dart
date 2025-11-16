import 'package:alamanah/model/user';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _ageController = TextEditingController();

  String? _gender;
  File? _pickedImage;
  bool _isSaving = false;

  // pick image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  void _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    _formKey.currentState!.save();

    User newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // temp ID
      name: _nameController.text.trim(),
      gender: _gender!,
      email: _emailController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      contactMobile: _mobileController.text.trim(),
      imageUrl: _pickedImage?.path, // or upload to server
    );

    await Future.delayed(Duration(milliseconds: 300)); // simulate save

    if (!mounted) return;
    // Navigator.pop(context, newUser);
    setState(() => _isSaving = false);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register User")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile image
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage:
                        _pickedImage != null ? FileImage(_pickedImage!) : null,
                    child: _pickedImage == null
                        ? const Icon(Icons.camera_alt, size: 32)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Name'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name cannot be empty' : null,
                ),
                const SizedBox(height: 10),

                // Gender + Age
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _gender,
                        decoration: _inputDecoration('Gender'),
                        items: ['Male', 'Female', 'Other']
                            .map((g) =>
                                DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) => _gender = v,
                        validator: (v) =>
                            v == null ? 'Please select gender' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Age'),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Age required" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration('Email'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Email cannot be empty' : null,
                ),
                const SizedBox(height: 10),

                // Mobile
                TextFormField(
                  controller: _mobileController,
                  decoration: _inputDecoration('Mobile'),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isSaving
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _registerUser,
                            child: const Text("Register"),
                          ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => (),
                      child: const Text('Cancel'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
