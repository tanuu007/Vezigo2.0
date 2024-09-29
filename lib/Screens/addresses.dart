import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vezigo/Models/colors.dart';
import 'package:vezigo/Providers/add_provider.dart';
import 'package:vezigo/Screens/delivery_loc.dart';
import 'package:vezigo/Models/radiobutton.dart';
import 'package:vezigo/Screens/edit_loc.dart';


class Addresses extends StatefulWidget {
  const Addresses({super.key});

  @override
  State<Addresses> createState() => _AddressState();
}

class _AddressState extends State<Addresses> {

  @override
  void initState() {
    super.initState();
    Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
  }

  int? _selectedAddressIndex;

  @override
  Widget build(BuildContext context) {
    final addresses = Provider.of<AddressProvider>(context).addresses;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.appbarColor,
        title: const Text('My Addresses', style: TextStyle(color: AppColors.textColor)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfirmDeliveryLocationScreen(),
                      ),
                    );
                  },
                  child: Text('Add New', style: TextStyle(color: AppColors.buttonColor)),
                ),
              ],
            ),
          ),
          if (addresses.isEmpty)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(address.addressType),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${address.houseNumber}, ${address.landmark}'),
                            const SizedBox(height: 3),
                            // Text('Name: ${address.yourName}'),
                            // Text('Phone: ${address.phoneNumber}'),
                          ],
                        ),
                        leading: CustomRadioButton(
                          isSelected: _selectedAddressIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedAddressIndex = index;
                            });
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditAddressScreen(
                                      address: address,
                                      index: index,
                                      id: address.phoneNumber,
                                    ),
                                  ),
                                );
                              },
                            ),
                          IconButton(
  icon: const Icon(Icons.delete_outline),
  onPressed: () async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            child: Text('No'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Provider.of<AddressProvider>(context, listen: false)
          .deleteAddress(address.phoneNumber);
    }
  },
),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
