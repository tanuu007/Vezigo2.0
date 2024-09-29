import 'package:flutter/material.dart';
import 'package:vezigo/models/colors.dart';
import '../Providers/item_provider.dart';
import '../Providers/fav_provider.dart';
import 'package:provider/provider.dart';
import 'item_details.dart';
import 'package:badges/badges.dart' as badges;
import 'cart_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Api_Models/list_products.dart';

class CategoriesScreen extends StatefulWidget {
  final String categoryTitle;
  const CategoriesScreen({super.key, required this.categoryTitle});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
Future<List<Product>> fetchProducts() async {
  final response = await http.get(Uri.parse('https://api.vezigo.in/v1/products?category=${widget.categoryTitle}'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseMap = json.decode(response.body);
    final Map<String, dynamic> dataMap = responseMap['data'];
    final List<dynamic> productList = dataMap['results'];

    return productList.map((json) => Product.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}


  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final cartProvider = Provider.of<Cart>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
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
              icon: const Icon(Icons.shopping_cart, size: 30, color: AppColors.textColor),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: AppColors.appbarColor,
        title: Text(widget.categoryTitle, style: const TextStyle(color: AppColors.textColor)),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Product>>(
          future: _futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No products available'));
            } else {
              final products = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.99,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isFavorite = favoriteProvider.isFavorite(product);
        
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsScreen(productId: product.id),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white,
                              width: 5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                      child: Container(
                                        color: AppColors.lightTheme,
                                        child: Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: '₹${product.marketPrice}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.priceColor,
                                                ),
                                              ),
                                             
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.lightTheme,
                                    shape: const CircleBorder(),
                                  ),
                                  child: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: AppColors.buttonColor,
                                  ),
                                  onPressed: () {
                                    favoriteProvider.toggleFavorite(product);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
