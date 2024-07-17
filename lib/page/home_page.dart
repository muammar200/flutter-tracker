import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tb/page/map_page.dart';
import 'package:tb/service/realtime_service.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../main.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'about_page.dart';

class MyHomePage extends StatefulWidget {
  final fba.FirebaseAuth? auth;

  const MyHomePage({Key? key, this.auth}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Stream<DatabaseEvent> _locationStream;
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  @override
  void initState() {
    super.initState();
    _locationStream = _databaseService.getUserLocationStream();
  }

  String _formatLatitude(double latitude) {
    String direction = latitude < 0 ? 'S' : 'N';
    return '${latitude.abs().toStringAsFixed(2)}° $direction';
  }

  String _formatLongitude(double longitude) {
    String direction = longitude < 0 ? 'W' : 'E';
    return '${longitude.abs().toStringAsFixed(2)}° $direction';
  }

  Future<void> _logout() async {
    await fba.FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => FirstScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = fba.FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'APP TRACKER',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              shadows: [
                Shadow(
                  offset: Offset(2.0, 2.0),
                  blurRadius: 3.0,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.blue, // Custom color
        actions: [
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.displayName ?? 'No Name',
                style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black),
              ),
              accountEmail: Text(
                user?.email ?? 'No Email',
                style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: themeProvider.isDarkMode
                    ? Colors.blueGrey[700]
                    : Colors.deepPurple[50],
                child: Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ?? 'U'),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Tracker'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutPage()));
              },
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: ListTile(
                        leading: Icon(Icons.exit_to_app),
                        title: Text('Log Out'),
                        onTap: _logout,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: StreamBuilder<DatabaseEvent>(
          stream: _locationStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Text('No data found');
            }

            dynamic data = snapshot.data!.snapshot.value;

            if (data is Map<dynamic, dynamic>) {
              double latitude = data['latitude'];
              double longitude = data['longitude'];

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      // height: 150,
                      child: Column(
                        children: [
                          Container(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        Icons.map,
                                        size: 48,
                                      ),
                                      title: Text('Latitude'),
                                      subtitle: Text(
                                        '${data['latitude']}',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        Icons.location_on,
                                        size: 48,
                                      ),
                                      title: Text('Longitude'),
                                      subtitle: Text(
                                        '${data['longitude']}',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${_formatLatitude(latitude)}, ',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                '${_formatLongitude(longitude)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapPage(
                                lat: latitude.toString(),
                                long: longitude.toString(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          child: Text(
                            "Open Map",
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ],
              );
            } else {
              return const Text('Unexpected data format');
            }
          },
        ),
      ),
    );
  }
}
