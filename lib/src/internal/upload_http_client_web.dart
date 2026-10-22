import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

Dio createUploadClient(bool withCredentials) => Dio()
  ..httpClientAdapter = BrowserHttpClientAdapter(
    withCredentials: withCredentials,
  );
