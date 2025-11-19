import 'package:alamanah/database/mongodb.dart';
import 'package:alamanah/mobile_pages/delete_user_page.dart';
import 'package:alamanah/mobile_pages/edit_user_page.dart';
import 'package:alamanah/model/user';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<User>> _futureUsers;
  String searchQuery = '';
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _futureUsers = MongoDatabase.getUsers();
    print('initState user_pro;');
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      // Update the future to the search results
      if (searchQuery.isEmpty) {
        _futureUsers = MongoDatabase.getUsers();
      } else {
        _futureUsers = MongoDatabase.searchUsers(searchQuery);
      }
    });
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _futureUsers = MongoDatabase.getUsers();
    });
  }

  void _editUser(User user, int index) async {
    final updatedUser = await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditUserPage(user: user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide in from right
          final enter = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation);

          // Slide out to right when popping
          final exit = Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(1.0, 0.0),
          ).animate(secondaryAnimation);

          return SlideTransition(
            position: enter,
            child: SlideTransition(position: exit, child: child),
          );
        },
      ),
    );

    // Handle updated user if returned
    if (updatedUser != null && updatedUser is User) {
      setState(() {
        _futureUsers = MongoDatabase.getUsers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔹 Top Container with Search Box
          Container(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(child: userList()),
        ],
      ),
    );
  }

  FutureBuilder<List<User>> userList() {
    return FutureBuilder<List<User>>(
      future: _futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off,
                  size: 60,
                  color: Color.fromARGB(255, 243, 5, 5),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Connection failed.\nPlease check your internet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _refreshUsers,
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No users found."));
        }

        final users = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _refreshUsers,
          child: SlidableAutoCloseBehavior(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return HomeItemView(
                  user: user,
                  index: index,
                  refreshUsers: _refreshUsers,
                  editUser: _editUser,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class HomeItemView extends StatelessWidget {
  final User user;
  final int index;
  final Function refreshUsers;
  final Function editUser;

  const HomeItemView({
    super.key,
    required this.user,
    required this.index,
    required this.refreshUsers,
    required this.editUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slidable(
          key: ValueKey(user.email),
          // 👇 Swipe from right to left
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => editUser(user, index),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (context) async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteUserPage(selectedUser: user),
                    ),
                  ).then((value) {
                    if (value == true) {
                      refreshUsers();
                    }
                  });
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),

          child: Padding(
            padding: EdgeInsetsGeometry.fromLTRB(12, 0, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage('assets/images/id_male.jpg'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.contactMobile, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/id_male.jpg',
                  fit: BoxFit.cover,
                ),
              ),
             
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_up_alt_outlined),
                  ),
                  const SizedBox(width: 4),
                  const Text("Like"),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.comment_outlined),
                  ),
                  const SizedBox(width: 4),
                  const Text("Comment"),
                ],
              ),
            ],
          ),
        ),

        // 🔹 Divider here
        Divider(thickness: 2),
      ],
    );
  }
}
