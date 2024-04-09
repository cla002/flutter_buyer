// ignore_for_file: unused_local_variable, unnecessary_this, prefer_function_declarations_over_variables, use_build_context_synchronously

import 'package:buyers/providers/location_provider.dart';
import 'package:buyers/screens/after_login_screen.dart';
import 'package:buyers/services/user_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String smsOtp;
  late String verificationId;
  String error = '';
  final UserServices _userServices = UserServices();
  bool loading = false;
  LocationProvider locationData = LocationProvider();
  DocumentSnapshot? snapshot;

  Future<void> verifyPhone({
    BuildContext? context,
    String? number,
    double? longitude,
    double? latitude,
    String? address,
  }) async {
    // Set default values for latitude, longitude, and address if they are null
    latitude ??= 0.0;
    longitude ??= 0.0;
    address ??= '';

    this.loading = true;
    notifyListeners();

    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      this.loading = false;
      notifyListeners();
      await _auth.signInWithCredential(credential);
    };
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      this.loading = false;
      print(e.code);
      this.error = e.toString();
      notifyListeners();
    };
    final PhoneCodeSent smsOtpSend = (String verId, int? resendToken) async {
      this.verificationId = verId;
      await smsOtpDialog(context!, number!, latitude!, longitude!, address!);
    };
    try {
      _auth.verifyPhoneNumber(
        phoneNumber: number!,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsOtpSend,
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationId = verId;
        },
      );
    } catch (e) {
      print(e);
      this.error = 'Error: $e';
      notifyListeners();
    }
  }

  Future<void> smsOtpDialog(BuildContext context, String number,
      double latitude, double longitude, String address) async {
    String? smsCode = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(
            children: [
              Text('Verification Code'),
              SizedBox(height: 10),
              Text(
                'Enter the 6 digit code sent to your mobile number',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          content: SizedBox(
            height: 85,
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (value) {
                this.smsOtp = value;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  PhoneAuthCredential phoneAuthCredential =
                      PhoneAuthProvider.credential(
                          verificationId: this.verificationId,
                          smsCode: this.smsOtp);

                  final User? user =
                      (await _auth.signInWithCredential(phoneAuthCredential))
                          .user;
                  if (user != null) {
                    if (locationData.selectedAddress != null) {
                      updateUser(
                          id: user.uid,
                          // number: user.phoneNumber,
                          latitude: locationData.latitude,
                          longitude: locationData.longitude,
                          address: locationData.selectedAddress!.addressLine);
                    } else {
                      _createUser(
                          id: user.uid,
                          number: user.phoneNumber,
                          latitude: latitude,
                          longitude: longitude,
                          address: address);
                    }
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(
                        context, SetYourLocationScreen.id);
                  } else {
                    print('Login Failed');
                  }
                } catch (e) {
                  print('Error caught during phone authentication: $e');
                  _showMessageOverlay(
                      context, 'Invalid OTP. Please try again. (TAP to CLOSE)');
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  void _createUser({
    String? id,
    String? number,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    _userServices.createUserData(
      {
        'id': id,
        'number': number,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      },
    );
    this.loading = false;
    notifyListeners();
  }

  void updateUser({
    String? id,
    // String? number,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    _userServices.updateUserData(
      {
        'id': id,
        // 'number': number,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      },
    );
    this.loading = false;
    notifyListeners();
  }

  void _showMessageOverlay(BuildContext context, String message) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => MessageOverlay(
        message: message,
        onClose: () {
          // Remove the overlay entry after a delay
          Future.delayed(const Duration(seconds: 1), () {
            overlayEntry?.remove();
          });
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  Future<DocumentSnapshot?> getUserDetails() async {
    try {
      DocumentSnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      this.snapshot = result;
      notifyListeners();
      return result;
    } catch (e) {
      print("Error fetching user details: $e");
      return null; // Return null if there's an error
    }
  }
}

class MessageOverlay extends StatelessWidget {
  final String message;
  final Function()? onClose;

  const MessageOverlay({super.key, required this.message, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              onClose?.call();
            },
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
