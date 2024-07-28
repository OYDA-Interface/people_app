import 'package:flutter/material.dart';
import 'package:oydadb/oydadb.dart';
import 'package:oydadb/src/oyda_interface.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "People Page",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PeoplePage(),
    );
  }
}

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  Future<List<Map<String, dynamic>>> _fetchPeople() async {
    var result = await OydaInterface().selectTable('people');
    return result;
  }

  Future<void> _addPerson(
      String firstname, String lastname, String role) async {
    await OydaInterface().insertRow('people', {
      'firstname': firstname,
      'lastname': lastname,
      'role': role,
    });
  }

  Future<void> _updatePerson(
      String firstname, String lastname, String role) async {
    await OydaInterface().updateRow('people', {
      'firstname': firstname,
      'lastname': lastname,
      'role': role,
    }, [
      Condition('lastname', '=', lastname),
    ]);
  }

  Future<void> _deletePerson(String firstname) async {
    await OydaInterface().deleteRow('people', [
      Condition('firstname', '=', firstname),
    ]);
  }

  void _showPersonDialog(
      {String? firstname,
      String? lastname,
      String? role,
      bool isEdit = false}) {
    _firstnameController.text = firstname ?? '';
    _lastnameController.text = lastname ?? '';
    _roleController.text = role ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Person' : 'Add Person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _firstnameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastnameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (isEdit) {
                  await _updatePerson(
                    _firstnameController.text,
                    _lastnameController.text,
                    _roleController.text,
                  );
                } else {
                  await _addPerson(
                    _firstnameController.text,
                    _lastnameController.text,
                    _roleController.text,
                  );
                }
                Navigator.pop(context);
                setState(() {}); // Refresh the list
              },
              child: Text(isEdit ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
      ),
      body: FutureBuilder(
        future: _fetchPeople(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No data available'),
            );
          }
          List<Map<String, dynamic>> documents = snapshot.data!;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> data = documents[index];
              String firstname = data['firstname'];
              String lastname = data['lastname'];
              String name = '$firstname $lastname';
              String role = data['role'];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(firstname[0]),
                  ),
                  title:
                      Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(role),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showPersonDialog(
                            firstname: firstname,
                            lastname: lastname,
                            role: role,
                            isEdit: true,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Delete Person'),
                                content: const Text(
                                    'Are you sure you want to delete this person?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _deletePerson(firstname);
                                      Navigator.pop(context);
                                      setState(() {}); // Refresh the list
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPersonDialog(isEdit: false);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
