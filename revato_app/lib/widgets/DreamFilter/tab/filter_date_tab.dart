import 'package:flutter/material.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';

Widget buildDateTab(BuildContext context, DreamFilterViewModel vm) {
  final isRecent = vm.isSortedByDate;
  final label =
      isRecent
          ? 'Je filtre sur les plus récents'
          : 'Je filtre sur les plus anciens';
  final icon = isRecent ? Icons.arrow_downward : Icons.arrow_upward;

  // Ajoute ces deux variables dans ton ViewModel pour stocker la période
  final DateTime? start = vm.filterStartDate;
  final DateTime? end = vm.filterEndDate;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Text(
          'Trier par',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C3AED),
          ),
        ),
      ),
      SizedBox(height: 12),
      Center(
        child: GestureDetector(
          onTap: () => vm.toggleSortByDate(!isRecent),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Color(0xFF7C3AED).withOpacity(0.08),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Color(0xFF7C3AED), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Color(0xFF7C3AED)),
                SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
        child: Text(
          'Filtrer par période',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C3AED),
          ),
        ),
      ),
      SizedBox(height: 12),
      Center(
        child: GestureDetector(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(Duration(days: 365)),
              initialDateRange:
                  (start != null && end != null)
                      ? DateTimeRange(start: start, end: end)
                      : null,
            );
            if (picked != null) {
              vm.setFilterPeriod(picked.start, picked.end);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
              SizedBox(width: 12),
              Text(
                'Sélectionner une période',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      if (start != null && end != null)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Center(
            child: Text(
              'Du ${_formatDate(start)} au ${_formatDate(end)}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
    ],
  );
}

// Utilitaire pour formater la date
String _formatDate(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year}";
}
