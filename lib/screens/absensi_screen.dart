import 'dart:io';
import 'dart:math';

import 'package:absensi_app/models/absensi.dart';
import 'package:absensi_app/screens/riwayat_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class AbsensiScreen extends StatefulWidget {
  const AbsensiScreen({super.key});

  @override
  _AbsensiScreenState createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen>
    with TickerProviderStateMixin {
  String _userName = '';
  String _currentDateTime = '';
  String _locationStatus = 'Mendapatkan lokasi...';
  String _formattedLocation = '';
  bool _hasAbsenToday = false;
  bool _isLocationValid = false;
  File? _selfieImage;
  List<Absensi> _absensiList = [];
  bool _isLocationLoading = true;
  bool _isSubmitting = false;

  final double _officeLat = -6.200000;
  final double _officeLng = 106.816666;
  final double _radius = 100.0;

  // animasi controllers
  late AnimationController _locationController;
  late Animation<double> _locationScaleAnimation;
  late AnimationController _contentController;

  @override
  void initState() {
    super.initState();

    _locationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _locationScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _locationController, curve: Curves.easeOutBack),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _loadUserData();
    _updateDateTime();
    _checkLocationServices();
    _loadAbsensi();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Pengguna';
    });
  }

  void _updateDateTime() {
    try {
      final now = DateTime.now();
      final days = [
        'Minggu',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
      ];
      final months = [
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

      final dayName = days[now.weekday % 7];
      final monthName = months[now.month - 1];

      setState(() {
        _currentDateTime = '$dayName, ${now.day} $monthName ${now.year}';
      });

      Future.delayed(const Duration(seconds: 60), _updateDateTime);
    } catch (e) {
      setState(() {
        _currentDateTime = DateFormat(
          'yyyy-MM-dd HH:mm',
        ).format(DateTime.now());
      });
    }
  }

  Future<void> _checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationStatus = 'Layanan lokasi tidak aktif';
        _isLocationLoading = false;
      });

      _showLocationServicesDialog();
      return;
    }

    _getLocation();
  }

  void _showLocationServicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Layanan Lokasi'),
        content: const Text(
          'Harap aktifkan layanan lokasi untuk menggunakan fitur absensi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text('Aktifkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationStatus = 'Mendapatkan lokasi...';
    });

    bool granted = await _handlePermission(Permission.location, 'lokasi');
    if (!granted) {
      setState(() {
        _isLocationLoading = false;
        _locationStatus = 'Izin lokasi ditolak';
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      double distance = _calculateDistance(
        position.latitude,
        position.longitude,
        _officeLat,
        _officeLng,
      );

      setState(() {
        _formattedLocation =
            'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
        _isLocationValid = distance <= _radius;
        _locationStatus = _isLocationValid
            ? 'Lokasi valid (dalam radius kantor)'
            : 'Lokasi tidak valid (luar radius kantor)';
        _isLocationLoading = false;

        _locationController.reset();
        _locationController.forward();
      });
    } catch (e) {
      setState(() {
        _isLocationLoading = false;
        _locationStatus = 'Gagal mendapatkan lokasi';
      });

      if (e is PlatformException && e.code == 'location_unavailable') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perangkat tidak dapat mendeteksi lokasi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000; 
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  Future<bool> _handlePermission(Permission permission, String feature) async {
    var status = await permission.status;
    if (status.isGranted) {
      return true;
    }

    status = await permission.request();
    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Izin $feature ditolak secara permanen. Buka pengaturan aplikasi.',
          ),
          action: SnackBarAction(
            label: 'Buka Pengaturan',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return false;
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Izin $feature ditolak. Harap izinkan untuk melanjutkan.',
          ),
        ),
      );
      return false;
    }

    return status.isGranted;
  }

  Future<void> _takeSelfie() async {
    bool granted = await _handlePermission(Permission.camera, 'kamera');
    if (!granted) return;

    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _selfieImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto')));
    }
  }

  Future<void> _absenNow() async {
    if (!_isLocationValid || _selfieImage == null || _hasAbsenToday) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final photoPath =
          '${directory.path}/selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _selfieImage!.copy(photoPath);

      final absensi = Absensi(
        date: DateTime.now(),
        locationValid: _isLocationValid,
        photoPath: photoPath,
      );

      _absensiList.add(absensi);
      await _saveAbsensi();

      setState(() {
        _hasAbsenToday = true;
        _isSubmitting = false;
      });

      // Show success animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Absensi berhasil disimpan!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 20,
            right: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan absensi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadAbsensi() async {
    final prefs = await SharedPreferences.getInstance();
    final absensiJson = prefs.getStringList('absensi') ?? [];

    // Get today's date in local timezone for comparison
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      _absensiList = absensiJson.map((json) => Absensi.fromJson(json)).toList();

      // Check if user has already absen today (timezone-safe)
      _hasAbsenToday = _absensiList.any((a) {
        final absenDate = DateTime(a.date.year, a.date.month, a.date.day);
        return absenDate.isAtSameMomentAs(today);
      });
    });
  }

  Future<void> _saveAbsensi() async {
    final prefs = await SharedPreferences.getInstance();
    final absensiJson = _absensiList.map((a) => a.toJson()).toList();
    await prefs.setStringList('absensi', absensiJson);
  }

  Widget _buildLocationIndicator() {
    return ScaleTransition(
      scale: _locationScaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isLocationValid
              ? Colors.green.withOpacity(0.15)
              : Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isLocationValid
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isLocationValid ? Icons.location_on : Icons.location_off,
              color: _isLocationValid ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _locationStatus,
                    style: TextStyle(
                      color: _isLocationValid ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_formattedLocation.isNotEmpty)
                    Text(
                      _formattedLocation,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(179, 117, 117, 117),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (_isLocationLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Color.fromARGB(179, 117, 117, 117),
              ),
              onPressed: _isLocationLoading ? null : _getLocation,
              tooltip: 'Refresh lokasi',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfieSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ambil Selfie',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_selfieImage == null)
            GestureDetector(
              onTap: _takeSelfie,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 48,
                      color: const Color.fromARGB(179, 0, 0, 0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ketuk untuk mengambil selfie',
                      style: TextStyle(
                        color: const Color.fromARGB(179, 0, 0, 0),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sebagai bukti kehadiran',
                      style: TextStyle(
                        color: const Color.fromARGB(137, 0, 0, 0),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selfieImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.7),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _selfieImage = null),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton() {
    String buttonText;
    Color? backgroundColor;
    bool isEnabled = false;

    if (_hasAbsenToday) {
      buttonText = 'Anda sudah absen hari ini';
      backgroundColor = Colors.grey;
    } else if (!_isLocationValid) {
      buttonText = 'Lokasi tidak valid';
      backgroundColor = Colors.red;
    } else if (_selfieImage == null) {
      buttonText = 'Ambil selfie terlebih dahulu';
      backgroundColor = Colors.orange;
    } else {
      buttonText = 'ABSEN SEKARANG';
      backgroundColor = const Color(0xFF00D2FF);
      isEnabled = true;
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: _isSubmitting
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: isEnabled ? _absenNow : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                shadowColor: backgroundColor?.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Absensi Kehadiran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RiwayatScreen(absensiList: _absensiList),
                ),
              );
            },
            tooltip: 'Riwayat Absensi',
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _contentController,
                  curve: Curves.easeOut,
                ),
              ),
          // FIXED: Wrap Column in SingleChildScrollView to enable scrolling
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(
              bottom: 20,
            ), // Add bottom padding for small screens
            child: Column(
              children: [
                // User Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $_userName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currentDateTime,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Location Status
                _buildLocationIndicator(),
                const SizedBox(height: 20),

                // Selfie Section
                _buildSelfieSection(),
                const SizedBox(height: 20),

                // Attendance Button
                _buildAttendanceButton(),

                // Status Info
                if (_hasAbsenToday)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      'Anda telah melakukan absensi hari ini',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
