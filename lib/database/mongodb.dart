import 'dart:async';

import 'package:alamanah/model/user';
import 'package:mongo_dart/mongo_dart.dart';

const MONGO_URL =
    "mongodb+srv://admin:admin2025@cluster1.jctpg02.mongodb.net/manpower?appName=Cluster1&retryWrites=true&w=majority";
const COLLECTION_NAME = "users";

class MongoDatabase {
  static Db? _db;
  static DbCollection? _collection;

  /// Connect to MongoDB with error handling
  static Future<void> connect() async {
    try {
      _db = await Db.create(MONGO_URL);
      // ⏱️ Add timeout to open()
      await _db!.open().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException("Connection to MongoDB timed out.");
        },
      );
      _collection = _db!.collection(COLLECTION_NAME);
      print("Connected to MongoDB");
    } on TimeoutException catch (e) {
      print("⏰ Timeout: $e");
      rethrow;
    } catch (e) {
      print("❌ Connection failed: $e");
      rethrow;
    }
  }

  static Future<List<User>> getUsers() async {
    try {
      await connect();
      final usersData = await _collection!.find().toList();
      return usersData.map((doc) => User.fromMap(doc)).toList();
    } catch (e) {
      throw Exception("Failed to load users: $e");
    }
  }

  static Future<bool> updateUser(User user) async {
    try {
      await connect();

      String idValue = user.id;

      // If the value looks like: ObjectId("6912d7ebe31a0793a2000000")
      final match = RegExp(
        r'ObjectId\("([a-fA-F0-9]{24})"\)',
      ).firstMatch(idValue);
      if (match != null) {
        idValue = match.group(1)!; // extract the 24-char hex
      }

      final objectId = ObjectId.fromHexString(idValue);

      final result = await _collection!.updateOne(
        where.eq('_id', objectId),
        modify
            .set('name', user.name)
            .set('age', user.age)
            .set('contact_mobile', user.contactMobile)
            .set('email', user.email)
            .set('gender', user.gender)
            .set('nationality', 'Philippine') // hardcoded for now
            .set('image_url', user.imageUrl),
      );

      return result.isSuccess;
    } catch (e) {
      print("Failed to search users: $e");
      throw Exception("Failed to update user: $e");
    }
  }

  static Future<List<User>> searchUsers(String query) async {
    try {
      await connect();

      // Use a Map with $or and $regex
      final usersData = await _collection!.find({
        r'$or': [
          {
            'name': {r'$regex': query, r'$options': 'i'},
          },
          {
            'email': {r'$regex': query, r'$options': 'i'},
          },
        ],
      }).toList();

      return usersData.map((doc) => User.fromMap(doc)).toList();
    } catch (e) {
      throw Exception("Failed to search users: $e");
    }
  }

  static Future<bool> deleteUser(String email) async {
    try {
      await connect();
      final result = await _collection!.deleteOne(where.eq('email', email));
      return result.isSuccess;
    } catch (e) {
      throw Exception("Failed to delete user: $e");
    }
  }

  // static connection() async {
  //   var db = await Db.create(MONGO_URL);
  //   await db.open();
  //   inspect(db);

  //   var collection = db.collection(COLLECTION_NAME);

  //   // await collection.insertOne({
  //   //   'name': 'Mario Garces',
  //   //   'email': 'mario@yahoo.com',
  //   //   'age': 30,
  //   //   'contact_mobile': '898-456-7890',
  //   // });

  //   // await collection.update(
  //   //   where.eq('name', 'Mr Lukies Luke'),
  //   //   modify.set('age', 41),
  //   // );

  //   // await collection.deleteOne(where.eq('name', 'Mr Lukies Luke'));

  //   print(await collection.find().toList());
  // }
}
