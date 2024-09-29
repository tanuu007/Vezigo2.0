import 'package:flutter/material.dart';
import 'package:vezigo/Api_Models/order_detailss.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key, required this.id});
  final String id;
  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
// Future<String> getAddressFromLatLng(double lat, double lng) async {
//   final String apiKey = 'AIzaSyAGEtunBXnzTCQkBaUJI4mzBQpw3X_C_6c';
//   final String apiUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

//   try {
//     final response = await http.get(Uri.parse(apiUrl));
//     if (response.statusCode == 200) {
//       final decodedData = jsonDecode(response.body);
//       if (decodedData['results'].isNotEmpty) {
//         return decodedData['results'][0]['formatted_address'];
//       } else {
//         return 'No address found';
//       }
//     } else {
//       throw Exception('Failed to load address');
//     }
//   } catch (e) {
//     print('Error fetching address: $e');
//     return 'Error fetching address';
//   }
// }
  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<OrderDetailRes> fetchOrderDetails() async {
    final String apiUrl = "https://api.vezigo.in/v1/app/orders/${widget.id}";
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        print(response.body);
        OrderDetailRes orderDetailRes = OrderDetailRes.fromJson(decodedData);
        print(orderDetailRes);
        return orderDetailRes;
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.black),
              Spacer(),
            ],
          ),
          backgroundColor: Colors.yellow,
          elevation: 0,
        ),
        body: FutureBuilder<OrderDetailRes>(
            future: fetchOrderDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final orders = snapshot.data!.data;
                DateTime parsedDate =
                    DateTime.parse(orders.createdAt.toString());
                String formattedDate =
                    DateFormat("d MMM, yyyy").format(parsedDate);

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Ordered by ${orders.userDetails.name} on $formattedDate",
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ordered Items',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: orders.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 5,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.title,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Quantity: ${item.quantity}'),
                                            Text(
                                                'Total: ₹${item.pack.price}.00',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Payment',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Mode'),
                                  Text('Offline'),
                                ],
                              ),
                              const SizedBox(height: 5),
                              const Divider(thickness: 0.5),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total'),
                                  Text('₹${orders.billAmount}.00',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Customer',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(orders.userDetails.name),
                              Text(orders.userDetails.phoneNumber),
                              const Divider(
                                thickness: 0.5,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Address',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(orders.userDetails.address),
                              const Divider(
                                thickness: 0.5,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Notes',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(orders.userDetails.notes),
                            ],
                          ),
                        ),
                      ),

                      // FutureBuilder<String>(
                      //   future: getAddressFromLatLng(orders.geo.lat, orders.geo.lng),
                      //   builder: (context, snapshot) {
                      //     if (snapshot.connectionState == ConnectionState.waiting) {
                      //       return CircularProgressIndicator();
                      //     } else if (snapshot.hasError) {
                      //       return Text('Error: ${snapshot.error}');
                      //     } else if (snapshot.hasData) {
                      //       return Text(snapshot.data ?? 'No address found');
                      //     } else {
                      //       return Text('No address found');
                      //     }
                      //   },
                      // ),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No data available'));
              }
            }));
  }
}

class OrderItemRow extends StatelessWidget {
  final String itemName;
  final int quantity;
  final String total;

  const OrderItemRow({
    super.key,
    required this.itemName,
    required this.quantity,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: Text(itemName)),
          const SizedBox(
            width: 100,
          ),
          Expanded(child: Text('$quantity')),
          Text(total),
        ],
      ),
    );
  }
}
