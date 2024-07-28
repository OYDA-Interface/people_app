import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oydadb/src/oyda_interface.dart';

void main() async {
  group('OYDAInterface', () {
    test('selectTable', () async {
      await dotenv.load(fileName: ".env");
      var table = await OydaInterface().selectTable('test_table');
      print(table);
    });
  });
}
