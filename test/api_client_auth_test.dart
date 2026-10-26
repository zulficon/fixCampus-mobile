import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixcampus_mobile/core/network/api_client.dart';

class RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString('{}', 200, headers: {
      Headers.contentTypeHeader: ['application/json']
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('API her istekte yenilenen tokenı kullanır; çıkışta başlığı kaldırır',
      () async {
    String? token = 'ilk-token';
    final adapter = RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = adapter;
    final api = ApiClient(dio: dio, tokenProvider: () => token);
    await api.dio.get('/api/profil');
    expect(adapter.requests.last.headers['Authorization'], 'Bearer ilk-token');
    token = 'yenilenmis-token';
    await api.dio.get('/api/profil');
    expect(adapter.requests.last.headers['Authorization'],
        'Bearer yenilenmis-token');
    token = null;
    await api.dio.get('/api/profil',
        options: Options(headers: {'authorization': 'Bearer eski'}));
    expect(
        adapter.requests.last.headers.keys
            .any((name) => name.toLowerCase() == 'authorization'),
        false);
    dio.close();
  });
}
