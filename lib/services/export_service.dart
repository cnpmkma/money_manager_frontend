import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';

Future<void> exportTransactionsToExcel(List<dynamic> transactions) async {
  var excel = Excel.createExcel(); // tạo Excel mới
  Sheet sheet = excel['Transactions'];

  // Thêm header
  sheet.appendRow([
    TextCellValue('Ngày'),
    TextCellValue('Loại'),
    TextCellValue('Danh mục'),
    TextCellValue('Ghi chú'),
    TextCellValue('Số tiền'),
  ]);

  // Thêm dữ liệu
  for (var t in transactions) {
    DateTime date;
    try {
      date = DateTime.parse(t['date']);
    } catch (_) {
      date = DateTime.now();
    }

    double amount;
    if (t['amount'] is num) {
      amount = (t['amount'] as num).toDouble();
    } else {
      amount = double.tryParse(t['amount'].toString()) ?? 0;
    }

    sheet.appendRow([
      DateCellValue(year: date.year, month: date.month, day: date.day),
      TextCellValue(t['category']['type'] ?? ''),
      TextCellValue(t['category']['category_name'] ?? ''),
      TextCellValue(t['note'] ?? ''),
      DoubleCellValue(amount),
    ]);
  }

  // Lưu file vào Downloads
  Directory? downloadsDir;
  if (Platform.isAndroid) {
    downloadsDir =
        await getExternalStorageDirectory(); // Android external storage
    // Nếu muốn vào chính xác thư mục Downloads:
    downloadsDir = Directory('/storage/emulated/0/Download');
  } else if (Platform.isIOS) {
    downloadsDir = await getDownloadsDirectory(); // iOS/macOS
  } else {
    downloadsDir = await getTemporaryDirectory(); // fallback
  }

  var file = File(join(downloadsDir!.path, 'transactions.xlsx'))
    ..createSync(recursive: true)
    ..writeAsBytesSync(excel.save()!);

  print('Excel đã được xuất tại: ${file.path}');
}
