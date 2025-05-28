import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_appwrite/dart_appwrite.dart';

class FContext {
  static FContext? _sl;
  static FContext get sl =>
      _sl != null ? _sl! : throw Exception("FContext not initialized yet !");

  final dynamic _ctx;
  late final FRequest req;
  late final FResponse res;
  late final FEnviroment env;
  late final FReqHeaders headers;

  factory FContext({dynamic ctx}) => _sl ??= FContext._(ctx: ctx!);

  FContext._({required dynamic ctx}) : _ctx = ctx {
    req = FRequest(req: _ctx.req);
    res = FResponse(res: _ctx.res);
    env = FEnviroment();
    headers = FReqHeaders(headers: req.headers);
  }

  /// Method to log errors to the Appwrite Console, end users will not be able to see these errors.
  void error(String message) => _ctx.error(message);

  /// Method to log information to the Appwrite Console, end users will not be able to see these logs.
  void log(String message) => _ctx.log(message);
}

/// https://appwrite.io/docs/products/functions/develop#request
class FRequest {
  final dynamic _req;

  FRequest({required dynamic req}) : _req = req;

  /// Full URL, for example: http://awesome.appwrite.io:8000/v1/hooks?limit=12&offset=50
  String get url => _req.url;

  /// Hostname from the host header, such as awesome.appwrite.io
  String get host => _req.host;

  /// Port from the host header, for example 8000
  String get port => _req.port;

  /// Path part of URL, for example /v1/hooks
  String get path => _req.path;

  /// Raw query params string. For example "limit=12&offset=50"
  String get queryString => _req.queryString;

  /// Parsed query params. For example, req.query.limit
  Map<String, dynamic> get query => Map.unmodifiable(_req.query);

  /// Request method, such as GET, POST, PUT, DELETE, PATCH, etc.
  ReqMethod get method =>
      str2Enum((_req.method as String).toLowerCase(), ReqMethod.values)!;

  /// // Value of the x-forwarded-proto header, usually http or https
  String get scheme => _req.scheme;

  /// String key-value pairs of all request headers, keys are lowercase
  Map<String, String> get headers => Map.unmodifiable(_req.headers);

  /// Raw request body, contains request data
  String get bodyText => _req.bodyText;

  /// Object from parsed JSON request body, otherwise string
  Map<String, dynamic>? get bodyJson => _req.bodyJson is Map<String, dynamic>
      ? Map.unmodifiable(_req.bodyJson)
      : null;
}

/// https://appwrite.io/docs/products/functions/develop#response
class FResponse {
  final dynamic _res;

  FResponse({required dynamic res}) : _res = res;

  /// Sends a response with a code 204 No Content status.
  FunctionResult empty() => FunctionResult(_res.empty());

  /// Converts the data into a JSON string and sets the content-type header to application/json.
  FunctionResult json(Map<String, dynamic> json) =>
      FunctionResult(_res.json(json));

  /// Packages binary bytes, the status code, and the headers into an object.
  FunctionResult binary(Uint8List bytes) => FunctionResult(_res.binary(bytes));

  FunctionResult html(String html,
          {int statusCode = 200, Map<String, dynamic> headers = const {}}) =>
      FunctionResult(_res.html(html, statusCode, headers));

  /// Redirects the client to the specified URL link.
  FunctionResult redirect(String url, {int statusCode = 301}) =>
      FunctionResult(_res.redirect(url, statusCode));

  /// Converts the body using UTF-8 encoding into a binary Buffer.
  FunctionResult text(String text) => FunctionResult(_res.text(text));
}

/// https://appwrite.io/docs/products/functions/develop#environment-variables
class FEnviroment {
  final Map<String, String> env = Platform.environment;

  /// The API endpoint of the running function
  String get appwriteApiEndpoint => env["APPWRITE_FUNCTION_API_ENDPOINT"]!;

  /// The Appwrite version used to run the function
  String get appwriteVersion => env["APPWRITE_VERSION"]!;

  /// The region where the function will run from
  String get appwriteRegion => env["APPWRITE_REGION"]!;

  /// The ID of the running function.
  String get appwriteFunctionId => env["APPWRITE_FUNCTION_ID"]!;

  /// The Name of the running function.
  String get appwriteFunctionName => env["APPWRITE_FUNCTION_NAME"]!;

  /// The deployment ID of the running function.
  String get appwriteFunctionDeployment => env["APPWRITE_FUNCTION_DEPLOYMENT"]!;

  /// The project ID of the running function.
  String get appwriteFunctionProjectId => env["APPWRITE_FUNCTION_PROJECT_ID"]!;

  /// The runtime of the running function.
  String get appwriteFunctionRuntimeName =>
      env["APPWRITE_FUNCTION_RUNTIME_NAME	"]!;

  /// The runtime version of the running function.
  String get appwriteFunctionRuntimeVersion =>
      env["APPWRITE_FUNCTION_RUNTIME_VERSION"]!;

  /// Custom Env
  ///
  /// Get APPWRITE_API_KEY from env.
  String get appwriteApiKey => env["APPWRITE_API_KEY"]!;
}

/// https://appwrite.io/docs/products/functions/develop#headers
class FReqHeaders {
  final Map<String, String> headers;

  factory FReqHeaders({required Map<String, String> headers}) =>
      FReqHeaders._(headers: Map.unmodifiable(headers));

  FReqHeaders._({required this.headers});

  /// Describes how the function execution was invoked. Possible values are
  /// http, schedule or event.
  ReqTrigger get appwriteTrigger =>
      str2Enum(headers["x-appwrite-trigger"]!, ReqTrigger.values)!;

  /// If the function execution was triggered by an event, describes the
  /// triggering event.
  String? get appwriteEvent => headers["x-appwrite-event"];

  /// The dynamic API key is used for server authentication.
  ///
  /// [Learn more about dynamic api keys.](https://appwrite.io/docs/products/functions/develop#dynamic-api-key)
  String get appwriteKey => headers["x-appwrite-key"]!;

  /// If the function execution was invoked by an authenticated user, display
  /// the user ID. This doesn't apply to Appwrite Console users or API keys.
  String? get appwriteUserId => headers["x-appwrite-user-id"];

  /// JWT token generated from the invoking user's session. Used to authenticate
  /// Server SDKs to respect access permissions.
  ///
  /// [Learn more about JWT tokens](https://appwrite.io/docs/products/auth/jwt).
  String get appwriteUserJwt => headers["x-appwrite-user-jwt"]!;

  /// Displays the country code of the configured locale.
  String get appwriteCountryCode => headers["x-appwrite-country-code"]!;

  /// Displays the continent code of the configured locale.
  String get appwriteContinentCode => headers["x-appwrite-continent-code"]!;

  /// Describes if the configured local is within the EU.
  String get appwriteContinentEU => headers["x-appwrite-continent-eu"]!;
}

enum ReqTrigger {
  http,
  schedule,
  event,
}

enum ReqMethod {
  get,
  post,
  put,
  delete,
  head,
  connect,
  patch,
  options,
  trace,
}

class FunctionResult {
  final dynamic result;

  FunctionResult(this.result);
}

T? str2Enum<T extends Enum>(String str, List<T> enum_) {
  for (var e in enum_) {
    if (e.name == str) {
      return e;
    }
  }
  return null;
}

Future<dynamic> fMain({
  required dynamic ctx,
  required Future<FunctionResult> Function(FContext ctx) customFunc,
}) async {
  final c = FContext(ctx: ctx);
  return (await customFunc(c)).result;
}

class FClient {
  static FClient? _sl;
  static FClient get sl =>
      _sl != null ? _sl! : throw Exception("FClient not initialized yet !");

  Client _client;
  Client get client => _client;

  factory FClient({Client? client}) => _sl ??= FClient._(client: client!);
  FClient._({required Client client}) : _client = client {
    _setServices();
  }

  late Databases _databases;
  Databases get databases => _databases;

  late Storage _storage;
  Storage get storage => _storage;

  late Teams _teams;
  Teams get teams => _teams;

  late Users _users;
  Users get users => _users;

  late Account _account;
  Account get account => _account;

  late Functions _functions;
  Functions get functions => _functions;

  late Messaging _messaging;
  Messaging get messaging => _messaging;

  late Locale _locale;
  Locale get locale => _locale;

  late Avatars _avatars;
  Avatars get avatars => _avatars;

  late Sites _sites;
  Sites get sites => _sites;

  late Tokens _tokens;
  Tokens get tokens => _tokens;

  late Health _health;
  Health get health => _health;

  void _setServices() {
    _databases = Databases(_client);
    _storage = Storage(_client);
    _teams = Teams(_client);
    _users = Users(_client);
    _account = Account(_client);
    _functions = Functions(_client);
    _messaging = Messaging(_client);
    _locale = Locale(_client);
    _avatars = Avatars(_client);
    _sites = Sites(_client);
    _tokens = Tokens(_client);
    _health = Health(_client);
  }

  void updateClient(Client client) {
    _client = client;
    _setServices();
  }
}

abstract class NanoID {
  static const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String numbers = '0123456789';
  static const String symbols = '_-';
  static final Random _random = Random.secure();

  static String generate({
    int size = 10,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = false,
    bool excludeLookAlike = false,
  }) {
    String alphabet = '';

    if (includeUppercase) alphabet += uppercase;
    if (includeLowercase) alphabet += lowercase;
    if (includeNumbers) alphabet += numbers;
    if (includeSymbols) alphabet += symbols;

    if (excludeLookAlike) {
      alphabet = alphabet.replaceAll(RegExp(r'[Il1O0oQCG9g6B8DS5Z2]'), '');
    }

    if (alphabet.isEmpty) {
      throw ArgumentError('At least one character set must be enabled.');
    }

    return List.generate(
        size, (index) => alphabet[_random.nextInt(alphabet.length)]).join();
  }
}
