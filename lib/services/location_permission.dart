// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Location Permission Required"),
      content:
          Text("Please grant permission to access your device's location."),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            // Request permission to access the device's location
            LocationPermission permission =
                await Geolocator.requestPermission();
            // Check the permission status
            if (permission == LocationPermission.denied ||
                permission == LocationPermission.deniedForever) {
              // The user denied or denied forever permission,
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Location Permission Denied"),
                    content: Text(
                        "You have denied the permission to access your device's location."),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                },
              );
            } else if (permission == LocationPermission.whileInUse ||
                permission == LocationPermission.always) {}
          },
          child: Text("OK"),
        ),
      ],
    );
  }
}
