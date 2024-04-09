import 'dart:io';

import 'package:buyers/screens/main_screen.dart';
import 'package:buyers/services/user_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateProfileAfterLoginScreen extends StatefulWidget {
  const UpdateProfileAfterLoginScreen({Key? key}) : super(key: key);
  static const String id = 'update-afterlogin-screen';

  @override
  State<UpdateProfileAfterLoginScreen> createState() =>
      _UpdateProfileAfterLoginScreenState();
}

class _UpdateProfileAfterLoginScreenState
    extends State<UpdateProfileAfterLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  final UserServices _user = UserServices();
  var firstName = TextEditingController();
  var lastName = TextEditingController();
  var mobile = TextEditingController();
  var email = TextEditingController();
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'firstName': firstName.text,
        'lastName': lastName.text,
        'email': email.text,
        'profilePicture': profilePictureUrl,
        'number': "+63${mobile.text}",
      });

      // Update local state
      setState(() {
        // Update local image reference if available
        if (profilePictureUrl != null) {
          // If profile picture was updated, set the new image URL
          _image = null; // Reset local image reference
        }
      });

      EasyLoading.showSuccess('Data saved successfully!');
    } catch (e) {
      EasyLoading.showError('Failed to update profile: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Set email controller text with user's email
    email.text = user!.email ?? '';
    // Disable email field
    // Fetch and set other user details
    _user.getUserById(user!.uid).then((value) {
      if (mounted) {
        setState(() {
          firstName.text = (value.data() as Map<String, dynamic>)['firstName'];
          lastName.text = (value.data() as Map<String, dynamic>)['lastName'];
          // Check if phoneNumber is null
          if ((value.data() as Map<String, dynamic>)
              .containsKey('phoneNumber')) {
            mobile.text = (value.data() as Map<String, dynamic>)['phoneNumber'];
          }
        });
      }
    });
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
            // Only navigate if the form is valid
            // Check if phoneNumber is not empty before navigating
            if (mobile.text.isNotEmpty) {
              Navigator.pushNamed(context, MainScreen.id);
            }
          }
        },
        child: Container(
          width: double.infinity,
          height: 50,
          color: Colors.purple.shade900,
          child: const Center(
            child: Text(
              'Proceed',
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Your Phone Number';
                            }
                            return null;
                          },
                          controller: mobile,
                          maxLength: 10,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixText: '+63',
                            labelText: 'Enter Your Phone Number',
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    enabled: false,
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
