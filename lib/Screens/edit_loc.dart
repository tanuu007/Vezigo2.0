import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vezigo/Models/add_model.dart';
import 'package:vezigo/Models/colors.dart';
import 'package:vezigo/Providers/add_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAddressScreen extends StatefulWidget {
  final Address address;
  final int index;
  final String id;
  const EditAddressScreen(
      {super.key,
      required this.address,
      required this.index,
      required this.id});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late TextEditingController _houseNumberController;
  late TextEditingController _landmarkController;
  late GoogleMapController? mapController;
  late TextEditingController yourNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController alternatePhoneNumberController;
  bool isAddressFetching = false;
  late TextEditingController notesController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool showAddressDetails = false;
  String dynamicAddress = "Move the pin to your location";
  LatLng currentPinPosition = const LatLng(26.9124, 75.7873);
  String _selectedAddressType = "Home";

  final TextEditingController _controller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];

  Timer? debounceTimer;
  @override
  void initState() {
    super.initState();
    _houseNumberController =
        TextEditingController(text: widget.address.houseNumber);

    _landmarkController = TextEditingController(text: widget.address.landmark);
    _selectedAddressType = widget.address.addressType;
    yourNameController = TextEditingController(text: widget.address.yourName);
    phoneNumberController =
        TextEditingController(text: widget.address.phoneNumber);
    alternatePhoneNumberController =
        TextEditingController(text: widget.address.alternatePhoneNumber);
    notesController = TextEditingController(text: widget.address.notes);

    /// uncomment if it is necessary
    // currentPinPosition =
    //     LatLng(widget.address.latitude ?? 0, widget.address.longitude ?? 0);
    dynamicAddress =
        "${widget.address.houseNumber}, ${widget.address.landmark}";
    _getAddressFromLatLng(currentPinPosition);
    _editAddress();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedAddress = Address(
      houseNumber: _houseNumberController.text,
      landmark: _landmarkController.text,
      addressType: _selectedAddressType,
      latitude: currentPinPosition.latitude,
      longitude: currentPinPosition.longitude,
      yourName: yourNameController.text,
      phoneNumber: phoneNumberController.text,
      alternatePhoneNumber: alternatePhoneNumberController.text,
      notes: notesController.text,
    );

    Provider.of<AddressProvider>(context, listen: false)
        .updateAddress(widget.index, updatedAddress);
    Navigator.pop(context);
  }

  Future<void> _editAddress() async {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, dynamic> requestBody = {
        'label': _selectedAddressType,
        'text': _houseNumberController.text,
      };

      try {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString('accessToken');

        if (accessToken == null) {
          print('Access token is null. Please log in.');
          return;
        }

        final response = await http.patch(
          Uri.parse('https://api.vezigo.in/v1/app/address/${widget.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          print('Address submitted successfully');
          print(response.body);
          _saveChanges();
        } else {
          print('Failed to submit address: ${response.body}');
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      if (isAddressFetching) return;

      isAddressFetching = true;

      final latitude = position.latitude;
      final longitude = position.longitude;

      currentPinPosition = LatLng(latitude, longitude);
      debugPrint("Latitude : $latitude & longitude : $longitude");
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      Placemark place = placemarks[0];

      setState(() {
        debugPrint("Current Location : ${currentPinPosition.toString()}");
        dynamicAddress =
            "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        _houseNumberController.text = place.name ?? '';
        _landmarkController.text = place.subLocality ?? '';
      });
    } catch (e, s) {
      debugPrint("Location Error : $e with $s");

      setState(() {
        dynamicAddress = "Address not found";
      });
    } finally {
      isAddressFetching = false;
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled.")));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
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
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: userLocation, zoom: 15)));
    }
    setState(() {
      currentPinPosition = userLocation;
    });
    _getAddressFromLatLng(userLocation);
  }

  void _onChanged() {
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

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$placesApi&sessiontoken=$_sessionToken';

      var response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (kDebugMode) {
          print('Response data: $data');
        }

        setState(() {
          _placeList = data['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching suggestions: $e');
      }
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
      if (mapController != null) {
        mapController!
            .animateCamera(CameraUpdate.newLatLngZoom(selectedPosition, 15));
      }

      setState(() {
        currentPinPosition = selectedPosition;
      });
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "Latitude : Longitude : ${currentPinPosition.latitude} : ${currentPinPosition.longitude}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        title: const Text("Edit delivery location"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();

          setState(() {
            _placeList.clear();
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
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_placeList.isNotEmpty)
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
                                  });

                                  FocusScope.of(context).unfocus();
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
                onPressed: _getCurrentLocation,
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_pin, color: Colors.red),
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
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Add more address details",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ),
                        ),
                      if (showAddressDetails) buildAddressForm(),
                    ],
                  ),
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
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _selectedAddressType == type['label']
                  ? AppColors.buttonColor
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(type['icon'],
                    color: _selectedAddressType == type['label']
                        ? Colors.white
                        : Colors.black),
                const SizedBox(width: 8),
                Text(
                  type['label'],
                  style: TextStyle(
                      color: _selectedAddressType == type['label']
                          ? Colors.white
                          : Colors.black),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildAddressForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAddressTypeSelector(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _houseNumberController,
            decoration: InputDecoration(
              labelText: 'House Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'Enter your House Number',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your house number.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _landmarkController,
            decoration: InputDecoration(
              labelText: 'Landmark',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'Enter your landmark',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
              labelText: 'Your Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'Enter your name',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: phoneNumberController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'Enter your mobile number',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number.';
              }
              if (value.length != 10) {
                return 'Phone number should be exactly 10 digits.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: alternatePhoneNumberController,
            decoration: InputDecoration(
              labelText: 'Alternate Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'Enter alternate number',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your alternate phone number.';
              }
              if (value.length != 10) {
                return 'Alternate number should be exactly 10 digits.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: notesController,
            decoration: InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'Notes',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _editAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Save",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
