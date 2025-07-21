import 'package:flutter/material.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';

Widget buildDateTab(DreamFilterViewModel vm) {
  return Column(
    children: [
      SwitchListTile(
        title: const Text('Trier par date'),
        value: vm.isSortedByDate,
        onChanged: (value) {
          vm.toggleSortByDate(value);
        },
      ),
      // Autres options de tri...
    ],
  );
}
