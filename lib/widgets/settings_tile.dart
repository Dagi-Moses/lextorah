import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 10.0),
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: Transform.scale(
          scale: 0.75, // Adjust this to your desired size
          child: Switch(value: value, onChanged: onChanged),
        ),
      ),
    );
  }
}
