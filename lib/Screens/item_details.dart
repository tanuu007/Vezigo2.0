import 'package:flutter/material.dart';
import 'package:vezigo/models/colors.dart';
import 'package:vezigo/Providers/item_provider.dart';
import 'package:provider/provider.dart';
import 'package:vezigo/models/cart_item.dart';
import 'package:badges/badges.dart' as badges;
import 'cart_screen.dart';
import '../Api_Models/product_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ItemDetailsScreen extends StatefulWidget {
  
  final String productId;

  const ItemDetailsScreen({super.key, required this.productId});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}
class _ItemDetailsScreenState extends State<ItemDetailsScreen> {

  late Future<ProductResponse> _productFuture;
  Package? _selectedPackage; 
  int _quantity = 1;   
  int _calculateTotalPrice() {
    if (_selectedPackage != null) {
      return _selectedPackage!.price * _quantity;
    }
    return 0;
  }

  @override
  void initState() {
    _productFuture = fetchProductDetails();
    super.initState();
  }

  Future<ProductResponse> fetchProductDetails() async {
    final response = await http.get(Uri.parse('${AppColors.api}/products/${widget.productId}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return ProductResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to load product');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<Cart>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        centerTitle: true,
        title: const Text(
          'Details',
          style: TextStyle(fontSize: 20, color: AppColors.textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          badges.Badge(
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.white,
            ),
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            badgeAnimation: const badges.BadgeAnimation.fade(
              animationDuration: Duration(milliseconds: 300),
            ),
            showBadge: cartProvider.items.isNotEmpty,
            badgeContent: Text(
              cartProvider.items.length.toString(),
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
            child: IconButton(
              tooltip: 'cart',
              icon: const Icon(Icons.shopping_cart, size: 30, color: Colors.black),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
          ),
        ],
      ),
       body: FutureBuilder<ProductResponse>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final product = snapshot.data!.data;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Image.network(
  product.imageUrl,
  fit: BoxFit.cover,
  width: MediaQuery.of(context).size.width, 
),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title, 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(product.category, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 10),
                        if(product.description.isNotEmpty)
                        Text(product.description, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                         Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                               style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                            minimumSize: const Size(30, 30),
                          ),
                              onPressed: () {
                                setState(() {
                                  if (_quantity > 1) {
                                    _quantity--;
                                  }
                                });
                              },
                              icon: const Icon(Icons.remove),
                              label:const Text(''),
                            ),
                          const  SizedBox(width: 10,),
                            Text(
                              _quantity.toString(),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                             const  SizedBox(width: 10,),
                            ElevatedButton.icon(
                               style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                            minimumSize: const Size(30, 30),
                          ),
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                              icon: const Icon(Icons.add,color: Colors.white,),
                              label:const Text(''),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.3,),
                            Row(
                              children: [
                                Text(
                                  product.packages.isNotEmpty
                                  ? '₹${product.packages.first.price}/${product.packages.first.unit}'
                                  : '₹${product.marketPrice}', 
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 25,),
                       
                        const Text('Available Packages:'),
                        const SizedBox(height: 12),
                        if(product.packages.isNotEmpty)
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 10.0,
                          children: product.packages.map((package) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPackage = package;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedPackage == package
                                      ? AppColors.buttonColor
                                      : Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ), 
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${package.quantity} ${package.unit}',
                                      style: TextStyle(
                                        color: _selectedPackage == package
                                            ? Colors.white
                                            : Colors.black,
                                      ),
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
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
      bottomNavigationBar: FutureBuilder<ProductResponse>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final product = snapshot.data!.data;

            return Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.15,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '₹${_calculateTotalPrice().toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
               ElevatedButton(
                 style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              padding:const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              textStyle:const TextStyle(fontSize: 16),
            ),
  onPressed: () {
    if (_selectedPackage != null) {
      Provider.of<Cart>(context, listen: false).addItem(
        CartItem(
          name: product.title,
          price: _selectedPackage!.price.toDouble(),
          quantity: _quantity,
          image: product.imageUrl,
          package: _selectedPackage!, 
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.title} added to cart!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a package before adding to cart!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  },
  child: const Text('Add to Cart',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
),


                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

