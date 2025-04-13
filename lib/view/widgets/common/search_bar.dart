import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final Function(String)? onSearch;
  final String? hintText;
  final bool autoFocus;

  const CustomSearchBar({
    super.key, 
    this.onSearch,
    this.hintText = 'Search',
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autoFocus,
      onChanged: onSearch != null ? onSearch! : (_) {},
      onSubmitted: onSearch != null ? onSearch! : (_) {},
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }
}
