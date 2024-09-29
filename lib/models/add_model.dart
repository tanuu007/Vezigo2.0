class Address {
  final String addressType;
  final String houseNumber;
  final String landmark;
  final String yourName;
  final String phoneNumber;
  final String alternatePhoneNumber;
  final String notes;
  final double? latitude; 
  final double? longitude;

  Address({
    required this.addressType,
    required this.houseNumber,
    required this.landmark,
    required this.yourName,
    required this.phoneNumber,
    required this.alternatePhoneNumber,
    required this.notes,
    this.latitude,
    this.longitude,
  });
}
