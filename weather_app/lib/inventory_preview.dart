import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:csv/csv.dart';

class InventoryPreview {
  Future<List<List<dynamic>>> loadCsvFile() async {
    final completer = Completer<List<List<dynamic>>>();
    final input = FileUploadInputElement()..accept = '.csv';
    input.click();

    input.onChange.listen((e) {
      final reader = FileReader();
      reader.readAsText(input.files!.first);
      reader.onLoadEnd.listen((e) {
        final csvData = reader.result as String;
        final List<List<dynamic>> data = const CsvToListConverter().convert(csvData);
        completer.complete(data);
      });
    });

    return completer.future;
  }
}
