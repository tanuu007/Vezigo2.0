import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vezigo/Models/colors.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:vezigo/Providers/add_provider.dart';
import '../Models/add_model.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:vezigo/Providers/signup_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmDeliveryLocationScreen extends StatefulWidget {
  const ConfirmDeliveryLocationScreen({super.key});

  @override
  State<ConfirmDeliveryLocationScreen> createState() =>
      _ConfirmDeliveryLocationScreenState();
}

class _ConfirmDeliveryLocationScreenState
    extends State<ConfirmDeliveryLocationScreen> {
  bool showSuggestions = true;

  Future<Map<String, String?>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString('name');
    final String? phoneNumber = prefs.getString('phoneNumber');
    return {
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }

  final TextEditingController _controller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];

  _onChanged() {
    if (_controller.text.isNotEmpty) {
      if (_sessionToken == '' || _sessionToken.isEmpty) {
        setState(() {
          _sessionToken = uuid.v4();
        });
      }
      getSuggestion(_controller.text);
    } else {
      setState(() {
        _placeList.clear();
      });
    }
  }

  void getSuggestion(String input) async {
    const String placesApi = "AIzaSyAGEtunBXnzTCQkBaUJI4mzBQpw3X_C_6c";
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$placesApi&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        _placeList = data['predictions'];
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  Future<void> getPlaceDetails(String placeId) async {
    const String placesApi = "AIzaSyAGEtunBXnzTCQkBaUJI4mzBQpw3X_C_6c";
    String request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$placesApi';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      double lat = data['result']['geometry']['location']['lat'];
      double lng = data['result']['geometry']['location']['lng'];

      LatLng selectedPosition = LatLng(lat, lng);
      _getAddressFromLatLng(selectedPosition);

      mapController
          .animateCamera(CameraUpdate.newLatLngZoom(selectedPosition, 15));

      setState(() {
        currentPinPosition = selectedPosition;
      });
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  bool showAddressDetails = false;
  String dynamicAddress = "Move the pin to your location";
  LatLng currentPinPosition = const LatLng(26.9124, 75.7873);

  late TextEditingController flatHouseController;
  late TextEditingController landmarkController;
  late GoogleMapController mapController;
  late TextEditingController yourNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController alternatePhoneNumberController;
  late TextEditingController notesController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedAddressType = "Home";

  @override
  void initState() {
    super.initState();

    flatHouseController = TextEditingController();
    landmarkController = TextEditingController();
    yourNameController = TextEditingController();
    phoneNumberController = TextEditingController();
    alternatePhoneNumberController = TextEditingController();
    notesController = TextEditingController();

    _getUserData().then((userData) {
      setState(() {
        yourNameController.text = userData['name'] ?? '';
        phoneNumberController.text = userData['phoneNumber'] ?? '';
      });
    });

    _controller.addListener(() {
      _onChanged();
    });

    final signupProvider = Provider.of<SignupProvider>(context, listen: false);
    if (signupProvider.signupRequest != null) {
      yourNameController.text = signupProvider.signupRequest!.name;
      phoneNumberController.text = signupProvider.signupRequest!.phoneNumber;
    }

    _getAddressFromLatLng(currentPinPosition);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        dynamicAddress =
            "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        flatHouseController.text = place.name ?? '';
        landmarkController.text = place.subLocality ?? '';
      });
    } catch (e) {
      setState(() {
        dynamicAddress = "Address not found";
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    FocusScope.of(context).unfocus();
    setState(() {
      showSuggestions = false;
      showAddressDetails = false;
    });
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled.")));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied.")));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Location permission is permanently denied.")));
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng userLocation = LatLng(position.latitude, position.longitude);
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: userLocation, zoom: 15)));
    setState(() {
      currentPinPosition = userLocation;
    });
    _getAddressFromLatLng(userLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        title: const Text("Confirm delivery location"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            showSuggestions = false;
            showAddressDetails = false;
          });
        },
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentPinPosition,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              onTap: (LatLng position) {
                FocusScope.of(context).unfocus();
                setState(() {
                  showSuggestions = false;
                });
              },
              onCameraMove: (CameraPosition position) {
                setState(() {
                  currentPinPosition = position.target;
                });
              },
              onCameraIdle: () {
                _getAddressFromLatLng(currentPinPosition);
              },
            ),
            const Center(
              child: Icon(Icons.location_pin, size: 50, color: Colors.red),
            ),
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Search your location here",
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.search_outlined,
                          color: AppColors.buttonColor),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _placeList.clear();
                            showSuggestions = false;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_placeList.isNotEmpty && showSuggestions)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _placeList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.location_on_outlined,
                                    color: AppColors.appbarColor),
                                title: Text(
                                  _placeList[index]["description"],
                                  style: const TextStyle(color: Colors.black),
                                ),
                                onTap: () async {
                                  String placeId =
                                      _placeList[index]["place_id"];
                                  await getPlaceDetails(placeId);
                                  setState(() {
                                    _controller.text =
                                        _placeList[index]["description"];
                                    _placeList.clear();
                                    showSuggestions = false;
                                  });
                                },
                              ),
                              const Divider(),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 180,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    showSuggestions = false;
                  });
                  _getCurrentLocation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  side:
                      const BorderSide(color: AppColors.appbarColor, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.my_location,
                        color: AppColors.appbarColor, size: 18),
                    SizedBox(width: 3),
                    Text(
                      "Use Current Location",
                      style:
                          TextStyle(color: AppColors.appbarColor, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: showAddressDetails ? 500 : 180,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dynamicAddress,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (!showAddressDetails)
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showAddressDetails = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text("Add more address details",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                      ),
                    if (showAddressDetails) buildAddressForm(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddressTypeSelector() {
    final List<Map<String, dynamic>> addressTypes = [
      {'label': 'HOME', 'icon': Icons.home_filled},
      {'label': 'OFFICE', 'icon': Icons.work},
      {'label': 'OTHER', 'icon': Icons.location_pin},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: addressTypes.map((type) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAddressType = type['label'];
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedAddressType == type['label']
                  ? AppColors.buttonColor
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  type['icon'],
                  color: _selectedAddressType == type['label']
                      ? Colors.white
                      : Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  type['label'],
                  style: TextStyle(
                    color: _selectedAddressType == type['label']
                        ? Colors.white
                        : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildAddressForm() {
    Future<void> submitAddress() async {
      if (_formKey.currentState!.validate()) {
        final Map<String, dynamic> requestBody = {
          'label': _selectedAddressType,
          'text': flatHouseController.text,
          'description': notesController.text,
        };

        try {
          final prefs = await SharedPreferences.getInstance();
          final accessToken = prefs.getString('accessToken');

          final response = await http.post(
            Uri.parse('https://api.vezigo.in/v1/app/address'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(requestBody),
          );

          if (response.statusCode == 201) {
            print('Address submitted successfully');
            print(response.body);

            final addressProvider =
                Provider.of<AddressProvider>(context, listen: false);

            addressProvider.addAddress(
              Address(
                addressType: _selectedAddressType,
                houseNumber: flatHouseController.text,
                landmark: landmarkController.text,
                yourName: yourNameController.text,
                phoneNumber: phoneNumberController.text,
                alternatePhoneNumber: alternatePhoneNumberController.text,
                notes: notesController.text,
                latitude: currentPinPosition.latitude,
                longitude: currentPinPosition.longitude,
              ),
            );

            print('Navigating back...');
            if (mounted) {
              Navigator.pop(context);
            }
          } else {
            print('Failed to submit address: ${response.body}');
          }
        } catch (e) {
          print('Error occurred: $e');
        }
      }
    }

    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: submitAddress,
      child: const Text("Confirm address",
          style: TextStyle(color: Colors.white, fontSize: 20)),
    );

    return Expanded(
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            buildAddressTypeSelector(),
            const SizedBox(height: 16),
            TextFormField(
              controller: flatHouseController,
              decoration: InputDecoration(
                labelText: "Flat / House No. / Floor / Building *",
                hintText: 'Flat/house No./ Floor/',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.streetAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: landmarkController,
              decoration: InputDecoration(
                hintText: 'Landmark',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                labelText: "Nearby landmark (optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your landmark.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: yourNameController,
              decoration: InputDecoration(
                labelText: "Your Name",
                hintText: 'Enter your name',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                hintText: '0000000000',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your mobile number.';
                }
                if (value.length != 10) {
                  return 'Mobile number should be exactly 10 digits.';
                }
                return null;
              },
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly
              ],
              // onChanged: (value) {
              //   authProvider.setMobileNumber(value);
              // },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: alternatePhoneNumberController,
              decoration: InputDecoration(
                labelText: "Alternate Phone Number (optional)",
                hintText: '0000000000',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: "Notes (optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Something about the order you want to add...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: submitAddress,
              // () {
              //   final addressProvider = Provider.of<AddressProvider>(context, listen: false);
              //     if (_formKey.currentState!.validate()){
              //        addressProvider.addAddress(
              //     Address(
              //       addressType: _selectedAddressType,
              //       houseNumber: flatHouseController.text,
              //       landmark: landmarkController.text,
              //       yourName: yourNameController.text,
              //       phoneNumber: phoneNumberController.text,
              //       alternatePhoneNumber: alternatePhoneNumberController.text,
              //       notes: notesController.text,
              //       latitude: currentPinPosition.latitude,
              //       longitude: currentPinPosition.longitude,
              //     ),
              //   );
              //   Navigator.pop(context);
              //     }

              child: const Text("Confirm address",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
