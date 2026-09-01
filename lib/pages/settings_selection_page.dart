import 'package:flutter/material.dart';
import 'package:vu_schedule_app/styles/colors.dart';

class SettingsSelectionPage<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final T? selected;
  final void Function(T item) onSelected;

  const SettingsSelectionPage({
    super.key,
    required this.title,
    required this.items,
    required this.labelBuilder,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: textColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor
        ),),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) {
          return const SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          final item = items[index];

          final isSelected = selected == item;

          return Material(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                onSelected(item);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        labelBuilder(item),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: accentColor,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}