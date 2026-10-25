import 'dart:io';

import 'package:fixcampus_mobile/services/api_service.dart';

Future<void> main(List<String> args) async {
  if (args.length > 1) {
    stderr.writeln('Kullanım: dart run tool/check_api.dart [API_ADRESI]');
    exitCode = 64;
    return;
  }
  final service = ApiService(
    config: ApiConfig(
      baseUrl: args.isEmpty ? 'http://127.0.0.1:5168' : args.single,
    ),
  );
  try {
    final status = await service.getStatus();
    final samples = await service.getSampleListings();
    stdout.writeln(
      'API: ${status.application} / ${status.status} / ${status.stage}',
    );
    stdout.writeln(
      'Örnek ilan: ${samples.items.length}; kaynak: ${samples.dataSource}; kalıcı: ${samples.isPersisted}',
    );
    for (final item in samples.items) {
      stdout.writeln('- ${item.type}: ${item.title}');
    }
    try {
      final listing = await service.getDatabaseDemoListing();
      stdout.writeln(
        'Veritabanı: ${listing.baslik}; kaynak: ${listing.dataSource}; kalıcı: ${listing.isPersisted}',
      );
    } on ApiException catch (error) {
      if (error.kind != ApiFailure.http ||
          ![404, 503].contains(error.statusCode)) {
        rethrow;
      }
      stdout.writeln(
        'Veritabanı demosu hazır değil (HTTP ${error.statusCode}); API ve örnek veri bağlantısı başarılı.',
      );
    }
  } on ApiException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } finally {
    service.close();
  }
}
