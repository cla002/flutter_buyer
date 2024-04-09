import 'dart:io';

import 'package:buyers/services/user_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key? key}) : super(key: key);
  static const String id = 'update-profile-screen';

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  final UserServices _user = UserServices();
  var firstName = TextEditingController();
  var lastName = TextEditingController();
  var mobile = TextEditingController();
  var email = TextEditingController();
  var number = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      // Upload image to Firebase Storage
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user!.uid}.jpg');
      await firebaseStorageRef.putFile(imageFile);

      // Get download URL
      return await firebaseStorageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  Future<void> updateProfile() async {
    // Upload image if available
    String? profilePictureUrl;
    if (_image != null) {
      profilePictureUrl = await uploadImageToFirebase(_image!);
      if (profilePictureUrl == null) {
        EasyLoading.showError('Failed to upload image.');
        return;
      }
    }

    // Update profile data in Firestore
    try {
      String? phoneNumber = mobile.text.isNotEmpty ? mobile.text : number.text;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'firstName': firstName.text,
        'lastName': lastName.text,
        'email': email.text,
        'profilePicture': profilePictureUrl,
        'phoneNumber': phoneNumber,
      });

      // Update local state
      setState(() {
        // Update local image reference if available
        if (profilePictureUrl != null) {
          // If profile picture was updated, set the new image URL
          _image = null; // Reset local image reference
        }
      });

      EasyLoading.showSuccess('Profile updated successfully!');
      Navigator.pop(context);
    } catch (e) {
      EasyLoading.showError('Failed to update profile: $e');
    }
  }

  @override
  void initState() {
    _user.getUserById(user!.uid).then((value) {
      if (mounted) {
        setState(() {
          firstName.text = (value.data() as Map<String, dynamic>)['firstName'];
          lastName.text = (value.data() as Map<String, dynamic>)['lastName'];
          email.text = (value.data() as Map<String, dynamic>)['email'];
          mobile.text =
              (value.data() as Map<String, dynamic>).containsKey('phoneNumber')
                  ? (value.data() as Map<String, dynamic>)['phoneNumber']
                  : '';
          number.text =
              (value.data() as Map<String, dynamic>).containsKey('number')
                  ? (value.data() as Map<String, dynamic>)['number']
                  : '';
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade900,
        centerTitle: true,
        title: const Text('Update Profile'),
        foregroundColor: Colors.white,
      ),
      bottomSheet: InkWell(
        onTap: () {
          if (_formKey.currentState!.validate()) {
            EasyLoading.show(status: 'Updating Profile...');
            updateProfile();
          }
        },
        child: Container(
          width: double.infinity,
          height: 50,
          color: Colors.purple.shade900,
          child: const Center(
            child: Text(
              'Update',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: getImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: firstName,
                          decoration: const InputDecoration(
                            labelText: 'Firstname',
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Your Firstname';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: lastName,
                          decoration: const InputDecoration(
                            labelText: 'Lastname',
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Your Lastname';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Your Email Address';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
