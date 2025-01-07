import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constant.dart';
import '../data_manager.dart';
import '../model/contact_response/contact_response.dart';
import '../model/session_request_model/update_session_request.dart';
import '../model/widget_response/widget.dart';

class ApiManager {
  static final ApiManager _instance = ApiManager._internal();

  late Dio _apiServerHostClient;
  late Dio _contactTrackingHostClient;

  factory ApiManager() => _instance;

  ApiManager._internal();

  static ApiManager get instance => _instance;

  Dio _createDioClient() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        contentType: 'application/json',
        headers: {"Content-Type": 'application/json'},
        receiveDataWhenStatusError: true,
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("Response: ${response.statusCode} ${response.data}");
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          print("Error: ${error.message}");
          return handler.next(error);
        },
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ),
    );

    return dio;
  }

  Dio _configureRetrofitService(Dio dio, {required bool forContactTracking}) {
    final String baseUrl = _getBaseUrl(forContactTracking: forContactTracking);
    dio.options.baseUrl = baseUrl;
    return dio;
  }

  static String _getBaseUrl({required bool forContactTracking}) {
    String zfRegion = DataManager().getRegion();

    if (zfRegion.toUpperCase() == 'EU') {
      return forContactTracking
          ? 'https://e.zonkafeedback.com/api/v1/'
          : "${Constant.HTTPS}e${Constant.RETROFIT_URL}";
    } else if (zfRegion.toUpperCase() == 'IN') {
      return forContactTracking
          ? 'https://in.apis.zonkafeedback.com/'
          : "${Constant.HTTPS}in1${Constant.RETROFIT_URL}";
    } else {
      return forContactTracking
          ? 'https://us1.apis.zonkafeedback.com/'
          : "${Constant.HTTPS}us1${Constant.RETROFIT_URL}";
    }
  }

  Dio _getContactTrackingClient() {
    _contactTrackingHostClient = _configureRetrofitService(
      _createDioClient(),
      forContactTracking: true,
    );
    return _contactTrackingHostClient;
  }

  Dio _getApiServerClient() {
    _apiServerHostClient = _configureRetrofitService(
      _createDioClient(),
      forContactTracking: false,
    );
    return _apiServerHostClient;
  }

  Future<WidgetResponse?> hitSurveyActiveApi(String token) async {
    final dioClient = _getApiServerClient();
    Response value = await dioClient.get(
      'distribution/validateCode/returnResponse/$token',
    );
    return WidgetResponse.fromJson(value.data);
  }

  Future<ContactResponse> hitCreateContactApi(Map<String, dynamic> data) async {
    final dioClient = _getContactTrackingClient();

    Response value = await dioClient.post(
      'contacts/tracking',
      data: data,
    );
    print("contacttrackingapiresponse ${value.data} ${data}");
    return ContactResponse.fromJson(value.data);
  }

  Future<ContactResponse> hitCreateContactApiDynamic(
      Map<String, dynamic> data) async {
    return hitCreateContactApi(data);
  }

  Future<Response> sendEventToServer(Map<String, dynamic> eventRequest) async {
    final dioClient = _getApiServerClient();
    return await dioClient.post(
      'surveys/logInteraction',
      data: eventRequest,
    );
  }

  Future<Response> updateSessionToServer(
      String token, UpdateSessionRequest sessionRequest) async {
    final dioClient = _getApiServerClient();
    return await dioClient.post(
      'contacts/sessionsUpdate/$token',
      data: sessionRequest.toJson(),
    );
  }
}
