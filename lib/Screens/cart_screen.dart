import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'checkout.dart';
import 'package:vezigo/Models/colors.dart';
import 'package:vezigo/Models/dash_line.dart';
import 'package:vezigo/Providers/item_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
   void _increaseQuantity(String name) {
    final cart = Provider.of<Cart>(context, listen: false);
    final item = cart.items.firstWhere((i) => i.name == name);
    cart.updateItemQuantity(name, item.quantity + 1,item.package.id);
  }

  void _decreaseQuantity(String name) {
    final cart = Provider.of<Cart>(context, listen: false);
    final item = cart.items.firstWhere((i) => i.name == name);
    if (item.quantity > 1) {
      cart.updateItemQuantity(name, item.quantity - 1,item.package.id);
    }
  }
  @override
  void initState() {
     final cart = Provider.of<Cart>(context, listen: false);
  cart.loadCart(); 
    super.initState();
  }

 void _clearCart() {
  final cart = Provider.of<Cart>(context, listen: false);

  if (cart.items.isEmpty) {
    return; 
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to empty the cart?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart(); 
              Navigator.of(context).pop(); 
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      backgroundColor:AppColors.backgroundColor,
      appBar: AppBar(
       actions: [
          IconButton(
            tooltip: 'Empty Cart',
            icon: const Icon(Icons.delete_rounded),
            onPressed: () {
              _clearCart();
            },
          )
        ],
        centerTitle: true,
        backgroundColor:AppColors.appbarColor,
        title: const Text(
          'Cart',
          style: TextStyle(color: AppColors.textColor),
        ),
        
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cart.items.isEmpty)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white,
                    width: 15,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 3,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sub Total'),
                        Text('₹${cart.totalAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Charges'),
                        Text('₹0.00'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount'),
                        Text('₹0.00'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const DashedLine(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Final Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (cart.items.isNotEmpty)
            Expanded(
              child: ListView.builder(
  itemCount: cart.items.length,
  itemBuilder: (context, index) {
    final item = cart.items[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade500,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 100,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightTheme,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    Text('${item.package.quantity} ${item.package.unit} x ${item.quantity} = ${item.price}',style: TextStyle(
                      color: Colors.grey.shade700,fontWeight: FontWeight.w500
                    ),),
                    Row(
                      
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                            minimumSize: const Size(30, 30),
                          ),
                          onPressed: () => _decreaseQuantity(item.name),
                          child: const Text(
                            '-',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                       
                        Text(
                          '${item.quantity} ',
                          style: const TextStyle(fontSize: 15),
                        ),
                      
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                            minimumSize: const Size(30, 30),
                          ),
                          onPressed: () => _increaseQuantity(item.name),
                          child: const Text(
                            '+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  cart.removeItem(item.name,item.package.id);
                },
              ),
            )
          ],
        ),
      ),
    );
  },
),

),
          if (cart.items.isNotEmpty)
        
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white,
                    width: 15,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 3,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sub Total'),
                        Text('₹${cart.totalAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Charges'),
                        Text('₹0.00'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount'),
                        Text('₹0.00'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const DashedLine(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Final Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const  SizedBox(height: 20
         ,)
        ],
      ),
    
     
       bottomNavigationBar: Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height * 0.15,
      padding:const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const  Text(
                  'Total Price',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18,color: AppColors.textColor),
                ),
                Text(
                  '₹${cart.totalAmount.toStringAsFixed(2)}',
                  style:const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor),
                ),
              ],
            ),
          ),
        const  SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              padding:const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              textStyle:const TextStyle(fontSize: 16),
            ),
            onPressed: () {
              
                  Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => const CheckoutScreen(),
                    ),
                  );
                
            },
            child:const Text(
              'Add Address',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
     ),
    );
  }
}
