// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class ShopDetailsWidget extends StatelessWidget {
//   final DocumentSnapshot doc;

//   const ShopDetailsWidget(this.doc, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SliverToBoxAdapter(
//       child: Column(
//         children: [
//           ListTile(
//             leading: SizedBox(
//               height: 60,
//               width: 60,
//               child: ClipRRect(
//                 child: Image.network(
//                   (doc.data() as Map<String, dynamic>)['imageUrl'],
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             title: Text(
//               (doc.data() as Map<String, dynamic>)['shopName'],
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//             subtitle: Text(
//               (doc.data() as Map<String, dynamic>)['address'],
//               style: const TextStyle(color: Colors.grey),
//               maxLines: 1,
//             ),
//           ),
//           // const CodToggleSwitch(),
//         ],
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class ShopDetailsWidget extends StatelessWidget {
//   final DocumentSnapshot doc;

//   const ShopDetailsWidget(this.doc, {Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Check if doc.data() is not null before accessing its properties
//     Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

//     if (data == null) {
//       // Handle the case when data is null
//       return Container(
//         child: Text('Data is null'),
//       );
//     }

//     return SliverToBoxAdapter(
//       child: Column(
//         children: [
//           ListTile(
//             leading: SizedBox(
//               height: 60,
//               width: 60,
//               child: ClipRRect(
//                 child: Image.network(
//                   data['imageUrl'] ??
//                       '', // Use a default value if imageUrl is null
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             title: Text(
//               data['shopName'] ?? '', // Use a default value if shopName is null
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//             subtitle: Text(
//               data['address'] ?? '', // Use a default value if address is null
//               style: const TextStyle(color: Colors.grey),
//               maxLines: 1,
//             ),
//           ),
//           // const CodToggleSwitch(),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShopDetailsWidget extends StatelessWidget {
  final DocumentSnapshot doc;

  const ShopDetailsWidget(this.doc, {super.key});

  @override
  Widget build(BuildContext context) {
    // Check if doc.data() is not null before accessing its properties
    final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      // Handle the case when data is null
      return const SliverToBoxAdapter(
        child: Center(
          child: Text('Shop details not available'),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          ListTile(
            leading: SizedBox(
              height: 60,
              width: 60,
              child: ClipRRect(
                child: data['imageUrl'] != null
                    ? Image.network(
                        data['imageUrl'],
                        fit: BoxFit.cover,
                      )
                    : Container(), // Handle the case when imageUrl is null
              ),
            ),
            title: Text(
              data['shopName'] ??
                  'Shop Name Not Available', // Provide a default value if shopName is null
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              data['address'] ??
                  'Address Not Available', // Provide a default value if address is null
              style: const TextStyle(color: Colors.grey),
              maxLines: 1,
            ),
          ),
          // const CodToggleSwitch(),
        ],
      ),
    );
  }
}
