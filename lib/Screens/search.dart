import 'package:flutter/material.dart';
import 'package:vezigo/Api_Models/list_products.dart';
import 'package:vezigo/Models/colors.dart';
import 'package:vezigo/Screens/item_details.dart';

class SearchScreen extends StatefulWidget {
  final List<Product> productList;

  const SearchScreen({super.key, required this.productList});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String searchText = _searchController.text.toLowerCase();
    if (searchText.isNotEmpty) {
      setState(() {
        _filteredProducts = widget.productList
            .where(
                (product) => product.title.toLowerCase().contains(searchText))
            .toList();
      });
    } else {
      setState(() {
        _filteredProducts = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: AppColors.appbarColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for products',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchController.text.isEmpty
                ? const Center(
                    child: Text('Start typing to search for products'),
                  )
                : (_filteredProducts.isEmpty
                    ? const Center(
                        child: Text('No products found'),
                      )
                    : ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return ListTile(
                            leading: Container(
                              width: 50,
                              height: 150,
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.lightTheme,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(product.title),
                            subtitle: Text('₹${product.marketPrice}'),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => ItemDetailsScreen(
                                      productId: product.id)));
                            },
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }
}
