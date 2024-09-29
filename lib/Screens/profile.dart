import 'package:flutter/material.dart';
import 'package:vezigo/Auth/login.dart';
import 'package:vezigo/Models/bottom_bar.dart';
import 'package:vezigo/Models/colors.dart';
import 'package:vezigo/Models/profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vezigo/Providers/profiles_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

Future<void> _logout(BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
      const  SnackBar(content: Text('No refresh token found')),
      );
      return;
    }

    const String logoutApiUrl = 'https://api.vezigo.in/v1/auth/logout';

    final response = await http.post(
      Uri.parse(logoutApiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        
      },
      body: jsonEncode(<String, String>{
        'refreshToken': refreshToken,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('Refresh token: $refreshToken');

    if (response.statusCode == 200) {
     
      await prefs.remove('refreshToken');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: ${response.reasonPhrase}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


 @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
       
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const BottomBars()), 
          (route) => false,
        );
        return false; 
      },
      child: Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.appbarColor,
        title: const Text('Profile', style: TextStyle(color:AppColors.textColor,)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileHeader(),
              const SizedBox(height: 20),
              const ProfileOption(
                icon: Icons.account_circle_outlined,
                title: 'Update Profile',
                subtitle: 'Update Your Profile',
              ),
              const ProfileOption(
                icon: Icons.person_add_alt_1_outlined,
                title: 'Orders',
                subtitle: 'You can see Your orders here',
              ),
              const ProfileOption(
                icon: Icons.account_balance_outlined,
                title: 'Address',
                subtitle: 'Change address',
              ),
              const ProfileOption(
                icon: Icons.devices_outlined,
                title: 'Terms & Conditions',
                subtitle: 'Manage your device credentials',
              ),
              const ProfileOption(
                icon: Icons.devices_outlined,
                title: 'Privacy Policy',
                subtitle: 'Manage your device credentials',
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.black54),
                title: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                contentPadding: EdgeInsets.zero,
                onTap: () => _showLogoutConfirmationDialog(context),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'), 
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: (){_logout(context);},
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
     WidgetsBinding.instance.addPostFrameCallback((_) {
      profileProvider.fetchProfile();
    });

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(40.0),
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/image.png'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
    profileProvider.name,
    style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
    ),
),
              const SizedBox(height: 4),
              Text(
                'Last Login: ${profileProvider.lastLogin}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
