// lib/screens/riwayat_screen.dart
import 'dart:io';

import 'package:absensi_app/models/absensi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RiwayatScreen extends StatefulWidget {
  final List<Absensi> absensiList;

  const RiwayatScreen({super.key, required this.absensiList});

  @override
  _RiwayatScreenState createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  // Filter variables
  String _selectedMonth = "Semua";
  int _selectedYear = DateTime.now().year;
  List<Absensi> _filteredAbsensiList = [];
  bool _isFiltered = false;

  @override
  void initState() {
    super.initState();
    _filteredAbsensiList = widget.absensiList;
    _filterData();
  }

  void _filterData() {
    setState(() {
      if (_selectedMonth == "Semua" && _selectedYear == 0) {
        _filteredAbsensiList = widget.absensiList;
        _isFiltered = false;
      } else {
        _filteredAbsensiList = widget.absensiList.where((absensi) {
          bool monthMatch;
          if (_selectedMonth == "Semua") {
            monthMatch = true;
          } else {
            // Konversi nama bulan ke angka
            final monthIndex = _getMonths().indexOf(_selectedMonth) + 1;
            monthMatch = absensi.date.month == monthIndex;
          }

          bool yearMatch =
              _selectedYear == 0 || absensi.date.year == _selectedYear;

          return monthMatch && yearMatch;
        }).toList();

        _isFiltered = _selectedMonth != "Semua" || _selectedYear != 0;
      }
    });
  }

  void _showFilterDialog() {
    final currentDate = DateTime.now();
    final months = _getMonths();
    months.insert(0, "Semua");

    final years = List<int>.generate(6, (i) => currentDate.year - (5 - i));
    years.add(currentDate.year + 1);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Riwayat Absensi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMonth,
              items: months.map((month) {
                return DropdownMenuItem(value: month, child: Text(month));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Bulan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedYear,
              items: years.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Tahun',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _filterData();
              Navigator.of(context).pop();
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  List<String> _getMonths() {
    return [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
  }

  String _formatDateIndonesian(DateTime date) {
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final months = _getMonths();

    final dayName = days[date.weekday % 7];
    final monthName = months[date.month - 1];

    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter riwayat',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isFiltered)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blueGrey[50],
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Filter: ${_selectedMonth == "Semua" ? "Semua Bulan" : _selectedMonth} $_selectedYear',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = "Semua";
                        _selectedYear = DateTime.now().year;
                        _filterData();
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: _filteredAbsensiList.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada riwayat absensi dengan filter yang dipilih',
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredAbsensiList.length,
                    itemBuilder: (context, index) {
                      final absensi = _filteredAbsensiList[index];
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            leading: absensi.photoPath.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.file(
                                      File(absensi.photoPath),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: const Icon(Icons.person),
                                  ),
                            title: Text(
                              _formatDateIndonesian(absensi.date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('HH:mm').format(absensi.date),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      absensi.locationValid
                                          ? Icons.location_on
                                          : Icons.location_off,
                                      color: absensi.locationValid
                                          ? Colors.green
                                          : Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      absensi.locationValid
                                          ? 'Lokasi Valid'
                                          : 'Lokasi Tidak Valid',
                                      style: TextStyle(
                                        color: absensi.locationValid
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Colors.grey,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
