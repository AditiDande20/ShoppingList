import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/model/category.dart';
import 'package:shopping_list_app/model/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  String _enteredName = "";
  int _enteredQuality = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();

      final url = Uri.https('shoppinglist-914de-default-rtdb.firebaseio.com',
          'shopping-list.json');
      try {
        final response = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'name': _enteredName,
              'quantity': _enteredQuality,
              'category': _selectedCategory.title
            }));

        final Map<String, dynamic> reponseData = json.decode(response.body);

        if (!context.mounted) {
          return;
        }

        Navigator.pop(
            context,
            GroceryItem(
                id: reponseData['name'],
                name: _enteredName,
                quantity: _enteredQuality,
                category: _selectedCategory));
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(
                        label: Text(
                      'Name',
                      style: TextStyle(fontSize: 16),
                    )),
                    validator: (value) {
                      if (value == null ||
                          value.toString().trim().isEmpty ||
                          value.toString().trim().length <= 1 ||
                          value.toString().trim().length > 50) {
                        return 'Must be between 1 and 50 characters';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _enteredName = newValue!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Price', style: TextStyle(fontSize: 16)),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null ||
                          value.toString().trim().isEmpty ||
                          int.tryParse(value) == null ||
                          int.tryParse(value)! <= 0) {
                        return 'Must be a valid positive number';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _enteredQuality = int.parse(newValue!);
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(category.value.title)
                                ],
                              ))
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      }),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  _formKey.currentState!.reset();
                                },
                          child: const Text('Reset')),
                      const SizedBox(
                        width: 16,
                      ),
                      ElevatedButton(
                          onPressed: _isLoading ? null : _saveItem,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(),
                                )
                              : const Text('Add Item'))
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }
}
