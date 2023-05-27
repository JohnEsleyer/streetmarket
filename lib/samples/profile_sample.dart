import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:streetmarket/custom_widgets/small_widgets.dart';

import '../models/UserData.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late String _name = "Name";
  String? _id = '';

  late User? user;

  final storage = FirebaseStorage.instance;

  String profileURL = "";
  late File imageFile = File.fromUri(Uri.http(
      'https://static.vecteezy.com/system/resources/previews/018/753/399/non_2x/naruto-chibi-icon-cute-free-vector.jpg'));

  @override
  void initState() {
    super.initState();

    // Initialize Firebase Authentication
    FirebaseAuth auth = FirebaseAuth.instance;

    // Get the current user
    setState(() {
      user = auth.currentUser;
    });

    // Get the reference to the image from Firebase Storage
    Reference imageRef =
        FirebaseStorage.instance.ref().child('users/${user?.uid}/profile.jpg');

    // Get the download URL for the image
    imageRef.getDownloadURL().then((url) {
      setState(() {
        // Create an Image widget with the download URL
        profileURL = url;
      });
    });
  }

  Future<DocumentSnapshot> getSnapshot(DocumentReference doc) async {
    return await doc.get();
  }

  Future<void> uploadImage(String? userId) async {
    print("upload Image executed!");
    if (imageFile == null) {
      // Handle the case where no image file is available
      return;
    }

    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('users/$_id/profile.jpg');
      await storageRef.putFile(imageFile!);

      storageRef.getDownloadURL().then((url) {
        setState(() {
          // Create an Image widget with the download URL
          profileURL = url;
        });
      });

      print('Image uploaded successfully!');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> pickImage(UserModel model) async {
    print("pressed");
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      imageFile = File(pickedImage.path);

      uploadImage(model.getUserCred.user?.uid);

      // Perform any additional actions with the image file, if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<UserModel>(context, listen: false);
    var doc = model.getUserDoc;
    doc.get().then((documentSnapshot) {
      // var data = documentSnapshot.data();

      setState(() {
        _name = (documentSnapshot.data()! as Map<String, dynamic>)['name']
            as String;

        _id = model.getId;
      });
    });

    return Scaffold(
      drawer: Drawer(),
      appBar: StreetMarketAppBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Background image
              Image.asset(
                'assets/background.jpg',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.25,
                width: double.infinity,
              ),
              // User profile
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Circular image
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(profileURL),
                      ),
                      GestureDetector(
                        onTap: () {
                          pickImage(model);
                        },
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ],
                  ),
                  Text(
                    "$_name",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      pickImage(model);
                    },
                    child: Icon(Icons.edit),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "My Product Posts",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
        onPressed: () {},
      ),
    );
  }
}
