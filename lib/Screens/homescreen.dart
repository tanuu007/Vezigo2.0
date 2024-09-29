import 'package:flutter/material.dart';
import 'package:vezigo/Api_Models/banner.dart';
import 'package:vezigo/Screens/categories.dart';
import 'package:vezigo/Models/colors.dart';
import 'package:vezigo/Screens/cart_screen.dart';
import 'package:vezigo/Providers/item_provider.dart';
import 'package:provider/provider.dart';
import 'package:vezigo/Models/category.dart';
import 'dart:async';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as http;
import 'package:vezigo/Screens/search.dart';
import 'dart:convert';
import '../Api_Models/list_products.dart';
import '../Providers/fav_provider.dart';
import 'item_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}
class _MyHomeScreenState extends State<MyHomeScreen> {
  int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _appBarTitle = 'Vezigo';
  bool _isSearchVisible = false;
 final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final cartProvider = Provider.of<Cart>(context, listen: false);
    cartProvider.loadCart();
    _futureProducts = fetchProducts();
    _futureBanners = fetchbanner();
    _scrollController.addListener(_scrollListener);
  _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
  if (_pageController.hasClients) {
    if (_currentPage < 2) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
});

  }
  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  void _scrollListener() {
    double offset = _scrollController.offset;
    if (offset > 400) {
      setState(() {
        _appBarTitle = 'Fruits';
      });
    } else {
      setState(() {
        _appBarTitle = 'Vezigo';
      });
    }
  }
  Future<List<Product>> fetchProducts() async {
  final response = await http.get(Uri.parse('${AppColors.api}/products'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> responseMap = json.decode(response.body);
    final Map<String, dynamic> dataMap = responseMap['data'];
    final List<dynamic> productList = dataMap['results'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> productIds = productList.map((json) => Product.fromJson(json).id).toList();
    await prefs.setStringList('productIds', productIds);
    return productList.map((json) => Product.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}

//Banner Api
Future<List<BannerItem>> fetchbanner() async{
  final response = await http.get(Uri.parse('${AppColors.api}/app/banners'));
  if(response.statusCode == 200){
    final Map<String, dynamic> responseMap = json.decode(response.body);
    final Map<String, dynamic> dataMap = responseMap['data'];
    final List<dynamic> bannerData = dataMap['results'];
    return bannerData.map((json) => BannerItem.fromJson(json)).toList();

  } else {
    throw Exception('Failed to load banners');
  }
}
late Future<List<Product>> _futureProducts;
late Future<List<BannerItem>> _futureBanners;
   @override
  Widget build(BuildContext context) {
     final favoriteProvider = Provider.of<FavoriteProvider>(context);
    return Scaffold(
        appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _appBarTitle,
          style: const TextStyle(color: AppColors.textColor),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appbarColor,
        scrolledUnderElevation: 0,
        leading: const SizedBox(width: 70),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
              });
            },
            icon: const Icon(Icons.search, size: 30, color: AppColors.textColor),
          ),
          Consumer<Cart>(
            builder: (context, cartProvider, child) {
              return badges.Badge(
                position: badges.BadgePosition.topEnd(top: 0, end: 3),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.white,
                ),
                badgeAnimation: const badges.BadgeAnimation.fade(
                  animationDuration: Duration(milliseconds: 300),
                ),
                showBadge: cartProvider.totalItemsInCart > 0,
                badgeContent: Text(
                  cartProvider.totalItemsInCart.toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
                child: IconButton(
                  tooltip: 'Cart',
                  icon: const Icon(Icons.shopping_cart, size: 30, color: AppColors.textColor),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     _appBarTitle,
      //     style: const TextStyle(color: AppColors.textColor),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: AppColors.appbarColor,
      //   scrolledUnderElevation: 0,
      //   leading: const SizedBox(width: 70),
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         setState(() {
      //           _isSearchVisible = !_isSearchVisible;
      //         });
      //       },
      //       icon: const Icon(Icons.search, size: 30, color: AppColors.textColor),
      //     ),
      //     badges.Badge(
      //       position: badges.BadgePosition.topEnd(top: 0, end: 3),
      //       badgeStyle:const badges.BadgeStyle(
      //         badgeColor: Colors.white,
      //       ),
      //       badgeAnimation: const badges.BadgeAnimation.fade(
      //         animationDuration: Duration(milliseconds: 300),
      //       ),
      //       showBadge: cartProvider.items.isNotEmpty,
      //       badgeContent: Text(
      //         cartProvider.items.length.toString(),
      //         style: const TextStyle(color: Colors.black, fontSize: 12),
      //       ),
      //       child: IconButton(
      //         tooltip: 'cart',
      //         icon: const Icon(Icons.shopping_cart, size: 30, color: AppColors.textColor),
      //         onPressed: () {
      //           Navigator.of(context).push(
      //             MaterialPageRoute(builder: (context) => const CartScreen()),
      //           );
      //         },
      //       ),
      //     ),
      //   ],
      // ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.appbarColor,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: _isSearchVisible,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                    child: TextField(
                      readOnly: true,
                      onTap: ()async {
                            List<Product> productList = await _futureProducts; 
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => SearchScreen(productList: productList)));
                      },
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Search Your Groceries',
                        suffixIcon: const Icon(Icons.search, color: AppColors.appbarColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                ),
                FutureBuilder<List<BannerItem>>(
                  future: _futureBanners,
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(),);
                    } else if (snapshot.hasError) {
                       return Center(child: Text('Error: ${snapshot.error}'));
                      }else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No products available'));
                       } else {
                        final banners = snapshot.data!;  
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Container(
  width: double.infinity,
  height: MediaQuery.of(context).size.height * 0.2,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    color: const Color.fromARGB(255, 249, 255, 249),
  ),
  child: PageView.builder(
    controller: _pageController,
    onPageChanged: (index) {
      setState(() {
        _currentPage = index;
      });
    },
    itemCount: banners.length,
    itemBuilder: (context, index) {
      return GestureDetector(
        
        onTap: () async {
              final url = Uri.parse(banners[index].url);
           if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $url')),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppColors.lightTheme,
          ),
          clipBehavior: Clip.hardEdge, 
          child: Image.network(
            banners[index].image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity, 
            
          ),
        ),
      );
    },
  ),
),
const SizedBox(height: 10),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: List.generate(banners.length, (index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? AppColors.buttonColor
            : Colors.green.shade200,
      ),
    );
  }),
),

                         const   SizedBox(height: 10,),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Categories',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                           Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CategoryItem(
                            title: 'Fruits',
                            imagePath: 'assets/images/orange.png',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                  builder: (context) =>const CategoriesScreen(
                    categoryTitle: 'fruit',
                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          CategoryItem(
                            title: 'Veggies',
                            imagePath: 'assets/images/veggies.png',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                  builder: (context) =>const CategoriesScreen(
                    categoryTitle: 'vegetable',
                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                  
                        ],
                      ),
                    ),
                  ),
                  
                            const SizedBox(height: 20),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Popular',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                           
                            FutureBuilder<List<Product>>(
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
                  
                          ],
                        ),
                      ),
                    ),
                  );
  }}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
