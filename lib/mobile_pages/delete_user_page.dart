import 'package:alamanah/database/mongodb.dart';
import 'package:alamanah/model/user';
import 'package:flutter/material.dart';

class DeleteUserPage extends StatelessWidget {
  final User selectedUser;

  const DeleteUserPage({super.key, required this.selectedUser});

  Future<void> _deleteUser(BuildContext context) async {
    try {
      final result = await MongoDatabase.deleteUser(selectedUser.email);
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedUser.name} deleted successfully.')),
        );
        Navigator.pop(context, true); // Return true to indicate deletion
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete user.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete User')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you sure you want to delete ${selectedUser.name}?',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context), // Cancel
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _deleteUser(context), // Delete
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
