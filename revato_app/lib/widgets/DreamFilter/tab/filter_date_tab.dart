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
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color.fromARGB(255, 174, 174, 174),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.black),
                SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
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
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 228, 228).withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.07),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sélecteur date de début
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: start ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: end ?? DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) {
                      vm.setFilterPeriod(picked, end);
                    }
                  },
                  icon: Icon(
                    Icons.calendar_today,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  label: Text(
                    start != null
                        ? 'Du: ${_formatDate(start)}'
                        : 'Choisir début',
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(
                      255,
                      0,
                      0,
                      0,
                    ).withOpacity(0.08),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Sélecteur date de fin
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: end ?? DateTime.now(),
                      firstDate: start ?? DateTime(2000),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) {
                      vm.setFilterPeriod(start, picked);
                    }
                  },
                  icon: Icon(
                    Icons.calendar_today,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  label: Text(
                    end != null ? 'Au: ${_formatDate(end)}' : 'Choisir fin',
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(
                      255,
                      0,
                      0,
                      0,
                    ).withOpacity(0.08),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      if (vm.filterStartDate != null || vm.filterEndDate != null) ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {
                vm.setFilterPeriod(null, null);
              },
              icon: Icon(Icons.clear, color: Color.fromARGB(255, 0, 0, 0)),
              label: Text(
                'Réinitialiser la période',
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ],
      SizedBox(height: 24),
    ],
  );
}

// Utilitaire pour formater la date
String _formatDate(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year}";
}
