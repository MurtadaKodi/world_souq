// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class LocationPickerWidget extends StatefulWidget {
  
//   const LocationPickerWidget({
//     super.key,
//     this.initialLocation,
//   });
//   final LatLng? initialLocation;
//   // الحصول على الموقع الحالي
//   static Future<Position?> getCurrentLocation() async {
//     try {
//       var permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           return null;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         return null;
//       }

//       return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//     } catch (e) {
//       return null;
//     }
//   }

//   @override
//   State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
// }

// class _LocationPickerWidgetState extends State<LocationPickerWidget> {
//   GoogleMapController? _controller;
//   LatLng? _selectedLocation;
//   bool _isLoading = false;

//   // موقع افتراضي في الدوحة - قطر
//   static const LatLng _defaultLocation = LatLng(25.2854, 51.5310);

//   @override
//   void initState() {
//     super.initState();
//     _selectedLocation = widget.initialLocation ?? _defaultLocation;
//     _getCurrentLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     setState(() => _isLoading = true);
    
//     try {
//       // التحقق من الصلاحيات
//       var permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('يجب السماح بالوصول إلى الموقع')),
//           );
//           setState(() => _isLoading = false);
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('تم رفض صلاحيات الموقع نهائياً')),
//         );
//         setState(() => _isLoading = false);
//         return;
//       }

//       // الحصول على الموقع الحالي
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       final currentLocation = LatLng(position.latitude, position.longitude);
      
//       if (widget.initialLocation == null) {
//         setState(() => _selectedLocation = currentLocation);
//       }

//       // تحريك الكاميرا إلى الموقع الحالي
//       _controller?.animateCamera(
//         CameraUpdate.newLatLng(currentLocation),
//       );
//     } catch (e) {
//       debugPrint('Error getting location: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('خطأ في تحديد الموقع: $e')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _onMapTap(LatLng location) {
//     setState(() => _selectedLocation = location);
//   }

//   void _onConfirm() {
//     if (_selectedLocation != null) {
//       Navigator.of(context).pop(_selectedLocation);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('اختر موقع العقار'),
//         actions: [
//           IconButton(
//             onPressed: _getCurrentLocation,
//             icon: _isLoading 
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                   )
//                 : const Icon(Icons.my_location),
//             tooltip: 'موقعي الحالي',
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _selectedLocation ?? _defaultLocation,
//               zoom: 14,
//             ),
//             onMapCreated: (controller) => _controller = controller,
//             onTap: _onMapTap,
//             markers: _selectedLocation != null
//                 ? {
//                     Marker(
//                       markerId: const MarkerId('selected'),
//                       position: _selectedLocation!,
//                       draggable: true,
//                       onDragEnd: (newPosition) {
//                         setState(() => _selectedLocation = newPosition);
//                       },
//                       icon: BitmapDescriptor.defaultMarkerWithHue(
//                         BitmapDescriptor.hueRed,
//                       ),
//                     ),
//                   }
//                 : {},
//             myLocationEnabled: true,
//             myLocationButtonEnabled: false,
//             zoomControlsEnabled: false,
//             mapToolbarEnabled: false,
//           ),
          
//           // 🎮 عناصر التحكم بالتكبير والتصغير
//           Positioned(
//             right: 16,
//             bottom: 100,
//             child: Column(
//               children: [
//                 // زر التكبير
//                 Material(
//                   elevation: 4,
//                   borderRadius: BorderRadius.circular(8),
//                   child: InkWell(
//                     onTap: () async {
//                       if (_controller != null) {
//                         await _controller!.animateCamera(
//                           CameraUpdate.zoomIn(),
//                         );
//                       }
//                     },
//                     borderRadius: BorderRadius.circular(8),
//                     child: Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Icon(
//                         Icons.add,
//                         color: Colors.black87,
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
                
//                 // زر التصغير
//                 Material(
//                   elevation: 4,
//                   borderRadius: BorderRadius.circular(8),
//                   child: InkWell(
//                     onTap: () async {
//                       if (_controller != null) {
//                         await _controller!.animateCamera(
//                           CameraUpdate.zoomOut(),
//                         );
//                       }
//                     },
//                     borderRadius: BorderRadius.circular(8),
//                     child: Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Icon(
//                         Icons.remove,
//                         color: Colors.black87,
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // معلومات الموقع المختار
//           if (_selectedLocation != null)
//             Positioned(
//               top: 16,
//               left: 16,
//               right: 16,
//               child: Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.location_on, color: Colors.red, size: 20),
//                           SizedBox(width: 8),
//                           Text(
//                             'الموقع المختار:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'خط العرض: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
//                         style: const TextStyle(fontSize: 13),
//                       ),
//                       Text(
//                         'خط الطول: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
//                         style: const TextStyle(fontSize: 13),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         '💡 اضغط على الخريطة لتغيير الموقع',
//                         style: TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: _selectedLocation != null
//           ? FloatingActionButton.extended(
//               onPressed: _onConfirm,
//               icon: const Icon(Icons.check),
//               label: const Text('تأكيد الموقع'),
//             )
//           : null,
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
// }
