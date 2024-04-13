import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please fill out the form correctly");
      return;
    }
    User? user = FirebaseAuth.instance.currentUser;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/${user!.uid}");

    if (_imageFile != null) {
      String filePath = 'user_profiles/${user.uid}/${DateTime.now().millisecondsSinceEpoch.toString()}';
      await tryUpload(_imageFile!, filePath, 3);
    }

    // Update other user data
    await ref.update({
      "username": _usernameController.text,
      "bio": _bioController.text,
      // Update imageUrl only if image was successfully uploaded
      if (_imageFile != null) "profileImageUrl": await FirebaseStorage.instance.ref('user_profiles/${user.uid}/${_imageFile!.path.split('/').last}').getDownloadURL(),
    }).then((_) {
      Fluttertoast.showToast(msg: "Profile Updated Successfully!");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Error updating profile: $error");
    });
  }

  Future<void> tryUpload(File file, String filePath, int retries) async {
    try {
      await FirebaseStorage.instance.ref(filePath).putFile(file);
    } catch (e) {
      if (retries > 0) {
        await Future.delayed(Duration(seconds: 2)); // wait for 2 seconds before retrying
        await tryUpload(file, filePath, retries - 1);
      } else {
        Fluttertoast.showToast(msg: "Failed to upload image after retries: $e");
        throw e; // throw error after retries are exhausted
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateProfile,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              ListTile(
                title: TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) => value!.isEmpty ? 'Please enter a username' : null,
                ),
              ),
              ListTile(
                title: TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(labelText: 'Biiio'),
                  validator: (value) => value!.isEmpty ? 'Please enter a bio' : null,
                ),
              ),
              ListTile(
                title: Text('Profile Image'),
                trailing: IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _pickImage,
                ),
              ),
              if (_imageFile != null) Image.file(_imageFile!),
            ],
          ),
        ),
      ),
    );
  }
}
