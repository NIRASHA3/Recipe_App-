// lib/presentation/home/add_category_dialog.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add New Category',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: _categoryController,
        decoration: InputDecoration(
          hintText: 'Enter category name',
          prefixIcon: Icon(Icons.category, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            final categoryName = _categoryController.text.trim();
            if (categoryName.isNotEmpty) {
              Navigator.pop(context, categoryName);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a category name')),
              );
            }
          },
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
