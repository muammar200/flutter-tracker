import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tb/page/map_page.dart';
import 'package:tb/service/realtime_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Stream<DatabaseEvent> _locationStream;

  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  @override
  void initState() {
    super.initState();
    _locationStream = _databaseService.getLocationStream();

    Timer.periodic(const Duration(seconds: 5), (timer) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      await _databaseService.getCurrentLocationAndSave();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geolocation Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: StreamBuilder<DatabaseEvent>(
                stream: _locationStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Text('No data found');
                  }

                  dynamic data = snapshot.data!.snapshot.value;
                  if (data is Map<dynamic, dynamic>) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Current Location From Firebase:',
                          style: TextStyle(fontSize: 24),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Latitude: ${data['latitude']}',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Longitude: ${data['longitude']}',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPage(
                                  lat: data['latitude'].toString(),
                                  long: data['longitude'].toString(),
                                ),
                              ),
                            );
                          },
                          child: const Text("Open Map"),
                        ),
                      ],
                    );
                  } else {
                    return const Text('Unexpected data format');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
