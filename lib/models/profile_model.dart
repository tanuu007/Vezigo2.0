import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vezigo/Screens/addresses.dart';
import 'package:vezigo/Screens/orders_list.dart';
import 'package:vezigo/Screens/update_profile.dart';

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
        ],
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
      onTap: () async {
        if (title == 'Orders') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>const OrdersScreen()),
          );
        } else if(title == 'Update Profile'){
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) =>const UpdateProfile()));
        }
         else if(title == 'Address'){
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) =>const Addresses()));
        }
        else if (title == 'Terms & Conditions' || title == 'Privacy Policy') {
          final url = Uri.parse('https://flutter.dev');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $url')),
            );
          }
        }
      },
    );
  }
}
