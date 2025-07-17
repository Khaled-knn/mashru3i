import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/color.dart'; // تأكد من أن هذا المسار صحيح

class ExtraItemsSection extends StatefulWidget {
  final int maxItems;
  final Function(List<Map<String, dynamic>>) onItemsChanged;
  final List<Map<String, dynamic>>? initialItems; // **البراميتر الجديد**

  const ExtraItemsSection({
    super.key,
    this.maxItems = 3,
    required this.onItemsChanged,
    this.initialItems, // **يجب أن يكون هنا**
  });

  @override
  State<ExtraItemsSection> createState() => _ExtraItemsSectionState();
}

class _ExtraItemsSectionState extends State<ExtraItemsSection> {
  // نغير طريقة تعريف _items عشان نحتفظ بالـ TextEditingController
  final List<Map<String, TextEditingController>> _items = [];

  @override
  void initState() {
    super.initState();
    // تهيئة الـ controllers بالبيانات الأولية إذا كانت موجودة
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      for (var itemData in widget.initialItems!) {
        _items.add({
          'name': TextEditingController(text: itemData['name']?.toString() ?? ''),
          'price': TextEditingController(text: itemData['price']?.toString() ?? ''),
        });
      }
    } else {
      // إذا لا يوجد بيانات أولية، نبدأ بعنصر واحد فارغ
      _addItem();
    }
    _notifyParent(); // إبلاغ الـ parent بالقيم الأولية بعد التهيئة
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final item in _items) {
      item['name']?.dispose();
      item['price']?.dispose();
    }
  }

  void _addItem() {
    if (_items.length < widget.maxItems) {
      setState(() {
        _items.add({
          'name': TextEditingController(),
          'price': TextEditingController(),
        });
      });
      _notifyParent();
    }
  }

  void _removeItem(int index) {
    if (_items.length > 1) { // يمكنك تعديل هذا الشرط للسماح بحذف كل العناصر إذا أردت
      setState(() {
        _items[index]['name']?.dispose();
        _items[index]['price']?.dispose();
        _items.removeAt(index);
      });
      _notifyParent();
    } else if (_items.length == 1 && index == 0) {
      // If it's the last item, clear its content instead of removing it
      setState(() {
        _items[0]['name']?.clear();
        _items[0]['price']?.clear();
      });
      _notifyParent();
    }
  }

  void _notifyParent() {
    widget.onItemsChanged(_getItems());
  }

  List<Map<String, dynamic>> _getItems() {
    return _items.map((item) {
      return {
        'name': item['name']?.text ?? '',
        'price': double.tryParse(item['price']?.text ?? '') ?? 0.0,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          LocaleKeys.youCanAdd3ExtraIngredients.tr(namedArgs: {'count': widget.maxItems.toString()}),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        // عرض حقول الإدخال لكل عنصر
        ..._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: item['name'],
                    decoration: InputDecoration(
                      labelText: LocaleKeys.itemName.tr(), // يمكن يكون LocaleKeys.ingredientName.tr()
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (_) => _notifyParent(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: item['price'],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.price.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (_) => _notifyParent(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    _items.length > 1 ? Icons.remove_circle_outline : Icons.close, // Change icon for last item to clear
                    color: Colors.red,
                  ),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
          );
        }),
        if (_items.length < widget.maxItems)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: Icon(Icons.add, color: textColor,),
              label: Text(LocaleKeys.addItem.tr(), style: TextStyle(color: textColor)),
              onPressed: _addItem,
            ),
          ),
      ],
    );
  }
}