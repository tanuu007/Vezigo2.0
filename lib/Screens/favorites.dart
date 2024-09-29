  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
import 'package:vezigo/models/bottom_bar.dart';
  import 'package:vezigo/models/colors.dart';
  import 'package:vezigo/Providers/fav_provider.dart';

  class FavoritesScreen extends StatefulWidget {
    const FavoritesScreen({super.key});
    @override
    State<FavoritesScreen> createState() => _FavoritesScreenState();
  }

  class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final favorites = favoriteProvider.favoriteItems;

    return WillPopScope(
      onWillPop: () async {
       
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) =>const BottomBars()), 
          (route) => false,
        );
        return false; 
      }, 
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Center(
            child: Text(
              'Favorites',
              style: TextStyle(color: AppColors.textColor),
            ),
          ),
          backgroundColor: AppColors.appbarColor,
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.99,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final item = favorites[index];
            final isFavorite = favoriteProvider.isFavorite(item);
      
            return GestureDetector(
              onTap: () {
              },
              child: Card(
                elevation: 5,
                color: Colors.white,
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
                                  item.imageUrl,
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
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                               
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '₹${item.marketPrice}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.priceColor,
                                          fontWeight: FontWeight.bold,
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
                            favoriteProvider.toggleFavorite(item);
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
      ),
    );
  }
}
