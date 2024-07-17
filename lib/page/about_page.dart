import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../main.dart';
import 'home_page.dart';
import '../models/about_item.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;

class AboutPage extends StatelessWidget {
  final fba.FirebaseAuth? auth;

  const AboutPage({Key? key, this.auth}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await fba.FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FirstScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = fba.FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: Colors.blue, // Custom color
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
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
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              accountEmail: Text(
                user?.email ?? 'No Email',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: themeProvider.isDarkMode
                    ? Colors.blueGrey[700]
                    : Colors.deepPurple[50],
                child: Text(
                  user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                ),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Log Out'),
                  onTap: () =>
                      _logout(context), // Ensure _logout is called with context
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: aboutItems.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            child: ListTile(
              title: Text(aboutItems[index].title),
              subtitle: Text(aboutItems[index].subtitle),
            ),
          );
        },
      ),
    );
  }
}
