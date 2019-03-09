

import 'package:dio/dio.dart';

class Download {
  CancelToken cancelToken;
  double progress = 0;
  
  Download() {
    cancelToken = CancelToken();
  }

  void cancelar() {
    cancelToken.cancel();
  }

}