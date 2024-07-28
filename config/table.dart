import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oydadb/src/oyda_interface.dart';

void main() async {
// Create a new table in the OydaBase
// Replace test_table with the name of the table you want to create in your oydabase
  await dotenv.load(fileName: '.env');
  await OydaInterface().createTable('people', {
    'firstname': 'VARCHAR(255)',
    'lastname': 'VARCHAR(255)',
    'role': 'VARCHAR(20)'
  });

// Drop an existing table from the OydaBase
// Replace test_table with the name of the table you want to drop
  // await OydaInterface().dropTable('test_table');
}
