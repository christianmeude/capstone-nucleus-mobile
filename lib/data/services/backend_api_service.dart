import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../models/research_model.dart';
import '../models/user_model.dart';

class SupabaseService {
  static final http.Client _client = http.Client();
  static Future<String?>? _refreshFuture;

  static String get _baseUrl {
    final value = dotenv.env['API_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('Missing API_URL in .env. Set API_URL=http://localhost:5001/api for the mobile app.');
    }

    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  static Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$normalizedPath');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    final cleaned = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value == null) return;
      final text = value.toString().trim();
      if (text.isEmpty) return;
      cleaned[key] = text;
    });

    return uri.replace(queryParameters: cleaned);
  }

  static bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password');
  }

  static dynamic _decodeBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return <String, dynamic>{'message': trimmed};
    }
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static Map<String, dynamic> _normalizeResponseMap(dynamic decoded) {
    final responseMap = _asMap(decoded);
    if (responseMap == null) {
      return <String, dynamic>{};
    }

    final data = responseMap['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return responseMap;
  }

  static Map<String, dynamic>? _extractUserMap(Map<String, dynamic> payload) {
    final directUser = _asMap(payload['user']);
    if (directUser != null) return directUser;

    final nestedData = _asMap(payload['data']);
    if (nestedData != null) {
      final nestedUser = _asMap(nestedData['user']);
      if (nestedUser != null) return nestedUser;
    }

    return null;
  }

  static String _extractMessage(dynamic decoded, String fallbackMessage) {
    final responseMap = _asMap(decoded);
    if (responseMap == null) return fallbackMessage;

    final error = responseMap['error'];
    if (error is Map) {
      final nested = Map<String, dynamic>.from(error);
      final message = nested['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }

    final message = responseMap['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;

    final errorText = responseMap['error'];
    if (errorText is String && errorText.trim().isNotEmpty) {
      return errorText.trim();
    }

    final details = responseMap['details'];
    if (details is String && details.trim().isNotEmpty) {
      return details.trim();
    }

    return fallbackMessage;
  }

  static String? _extractCode(dynamic decoded) {
    final responseMap = _asMap(decoded);
    if (responseMap == null) return null;

    final error = responseMap['error'];
    if (error is Map) {
      final nested = Map<String, dynamic>.from(error);
      final code = nested['code']?.toString().trim();
      if (code != null && code.isNotEmpty) return code;
    }

    final code = responseMap['code']?.toString().trim();
    if (code != null && code.isNotEmpty) return code;

    return null;
  }

  static AppException _mapApiError(
    int statusCode,
    dynamic decoded, {
    String fallbackMessage = 'Request failed',
  }) {
    final message = _extractMessage(decoded, fallbackMessage);
    final code = _extractCode(decoded);

    if (statusCode == 400) {
      if (code == 'USER_EXISTS' || code == 'USER_ALREADY_EXISTS') {
        return UserAlreadyExistsException();
      }

      if (code == 'INVALID_INPUT' ||
          code == 'VALIDATION_ERROR' ||
          code == 'WEAK_PASSWORD') {
        return ValidationException(message);
      }

      return ValidationException(message);
    }

    if (statusCode == 401) {
      if (code == 'INVALID_CREDENTIALS') {
        return InvalidCredentialsException();
      }

      if (code == 'INVALID_REFRESH_TOKEN' || code == 'SESSION_EXPIRED') {
        return SessionExpiredException();
      }

      return SessionExpiredException();
    }

    if (statusCode == 403) {
      return AuthException(message, code: code ?? 'FORBIDDEN');
    }

    if (statusCode == 404) {
      return NotFoundException(message);
    }

    if (statusCode == 409) {
      if (code == 'USER_EXISTS') {
        return UserAlreadyExistsException();
      }
      return ValidationException(message);
    }

    if (statusCode >= 500) {
      return ServerException(message);
    }

    return DataException(message, code: code);
  }

  static Future<http.Response> _sendRequest(http.Request request) async {
    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 30));
    return http.Response.fromStream(streamed);
  }

  static Future<http.Response> _buildAndSendJsonRequest({
    required String method,
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final request = http.Request(method, uri);

    if (includeAuth) {
      final accessToken = await _getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    if (body != null && method != 'GET' && method != 'DELETE') {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    return _sendRequest(request);
  }

  static Future<http.Response> _buildAndSendMultipartRequest({
    required String path,
    required Map<String, String> fields,
    required Uint8List fileBytes,
    required String filename,
    bool includeAuth = true,
  }) async {
    final uri = _buildUri(path);
    final request = http.MultipartRequest('POST', uri);

    if (includeAuth) {
      final accessToken = await _getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    request.fields.addAll(fields);
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
    );

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    return http.Response.fromStream(streamed);
  }

  static Future<String?> _getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(StorageKeys.accessToken);
  }

  static Future<String?> _getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(StorageKeys.refreshToken);
  }

  static String _buildDisplayName(Map<String, dynamic> userRow) {
    final fullName =
        userRow['fullName']?.toString().trim() ??
        userRow['full_name']?.toString().trim() ??
        '';
    if (fullName.isNotEmpty) return fullName;

    final first =
        userRow['first_name']?.toString().trim() ??
        userRow['firstName']?.toString().trim() ??
        '';
    final middle =
        userRow['middle_name']?.toString().trim() ??
        userRow['middleName']?.toString().trim() ??
        '';
    final last =
        userRow['last_name']?.toString().trim() ??
        userRow['lastName']?.toString().trim() ??
        '';
    final parts = [
      first,
      middle,
      last,
    ].where((part) => part.isNotEmpty).toList();
    return parts.join(' ');
  }

  static Future<void> _persistAuthSession({
    String? accessToken,
    String? refreshToken,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await _prefs;

    if (accessToken != null && accessToken.isNotEmpty) {
      await prefs.setString(StorageKeys.accessToken, accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(StorageKeys.refreshToken, refreshToken);
    }

    await prefs.setString(StorageKeys.userId, user['id']?.toString() ?? '');
    await prefs.setString(
      StorageKeys.userEmail,
      user['email']?.toString() ?? '',
    );
    await prefs.setString(
      StorageKeys.userRole,
      user['role']?.toString() ?? 'student',
    );
    await prefs.setString(StorageKeys.userName, _buildDisplayName(user));

    final department = user['department']?.toString();
    final departmentId =
        user['departmentId']?.toString() ?? user['department_id']?.toString();
    final program = user['program']?.toString();
    final programId =
        user['programId']?.toString() ?? user['program_id']?.toString();

    if (department != null && department.isNotEmpty) {
      await prefs.setString(StorageKeys.userDepartment, department);
    } else {
      await prefs.remove(StorageKeys.userDepartment);
    }

    if (departmentId != null && departmentId.isNotEmpty) {
      await prefs.setString(StorageKeys.userDepartmentId, departmentId);
    } else {
      await prefs.remove(StorageKeys.userDepartmentId);
    }

    if (program != null && program.isNotEmpty) {
      await prefs.setString(StorageKeys.userProgram, program);
    } else {
      await prefs.remove(StorageKeys.userProgram);
    }

    if (programId != null && programId.isNotEmpty) {
      await prefs.setString(StorageKeys.userProgramId, programId);
    } else {
      await prefs.remove(StorageKeys.userProgramId);
    }
  }

  static Future<void> _clearStoredSession() async {
    final prefs = await _prefs;
    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.refreshToken);
    await prefs.remove(StorageKeys.userId);
    await prefs.remove(StorageKeys.userEmail);
    await prefs.remove(StorageKeys.userRole);
    await prefs.remove(StorageKeys.userName);
    await prefs.remove(StorageKeys.userDepartment);
    await prefs.remove(StorageKeys.userDepartmentId);
    await prefs.remove(StorageKeys.userProgram);
    await prefs.remove(StorageKeys.userProgramId);
  }

  static Future<Map<String, dynamic>?> _loadStoredUserSnapshot() async {
    final prefs = await _prefs;
    final userId = prefs.getString(StorageKeys.userId);
    if (userId == null || userId.isEmpty) return null;

    return {
      'id': userId,
      'email': prefs.getString(StorageKeys.userEmail) ?? '',
      'fullName': prefs.getString(StorageKeys.userName) ?? '',
      'role': prefs.getString(StorageKeys.userRole) ?? 'student',
      'department': prefs.getString(StorageKeys.userDepartment),
      'departmentId': prefs.getString(StorageKeys.userDepartmentId),
      'program': prefs.getString(StorageKeys.userProgram),
      'programId': prefs.getString(StorageKeys.userProgramId),
    };
  }

  static Future<Map<String, dynamic>> _loginOrRegister({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final response = await _buildAndSendJsonRequest(
      method: 'POST',
      path: path,
      body: body,
      includeAuth: false,
    );

    final payload = _normalizeResponseMap(response);
    final user = _extractUserMap(payload);
    if (user == null) {
      throw DataException('Authentication response did not include a user');
    }

    await _persistAuthSession(
      accessToken: payload['token']?.toString(),
      refreshToken: payload['refreshToken']?.toString(),
      user: user,
    );

    return payload;
  }

  static Future<Map<String, dynamic>> _refreshSession(
    String refreshToken,
  ) async {
    final response = await _buildAndSendJsonRequest(
      method: 'POST',
      path: '/auth/refresh',
      body: {'refreshToken': refreshToken},
      includeAuth: false,
    );

    return _normalizeResponseMap(response);
  }

  static Future<bool> _refreshStoredSession() async {
    final storedRefreshToken = await _getRefreshToken();
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      return false;
    }

    if (_refreshFuture != null) {
      final nextToken = await _refreshFuture!.catchError((_) => null);
      return nextToken != null && nextToken.isNotEmpty;
    }

    _refreshFuture = _refreshSession(storedRefreshToken).then((payload) async {
      final user = _extractUserMap(payload);
      final accessToken = payload['token']?.toString();
      final nextRefreshToken =
          payload['refreshToken']?.toString() ?? storedRefreshToken;

      if (user == null || accessToken == null || accessToken.isEmpty) {
        return null;
      }

      await _persistAuthSession(
        accessToken: accessToken,
        refreshToken: nextRefreshToken,
        user: user,
      );

      return accessToken;
    });

    try {
      final nextToken = await _refreshFuture!;
      return nextToken != null && nextToken.isNotEmpty;
    } catch (_) {
      await _clearStoredSession();
      return false;
    } finally {
      _refreshFuture = null;
    }
  }

  static Future<Map<String, dynamic>> _requestJson({
    required String method,
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    bool includeAuth = true,
    bool allowRefresh = true,
  }) async {
    try {
      final response = await _buildAndSendJsonRequest(
        method: method,
        path: path,
        queryParameters: queryParameters,
        body: body,
        includeAuth: includeAuth,
      );

      final decoded = _decodeBody(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _normalizeResponseMap(decoded);
      }

      if (response.statusCode == 401 &&
          includeAuth &&
          allowRefresh &&
          !_isAuthEndpoint(path) &&
          await _refreshStoredSession()) {
        return _requestJson(
          method: method,
          path: path,
          queryParameters: queryParameters,
          body: body,
          includeAuth: includeAuth,
          allowRefresh: false,
        );
      }

      throw _mapApiError(
        response.statusCode,
        decoded,
        fallbackMessage: _extractMessage(decoded, 'Request failed'),
      );
    } on TimeoutException catch (error) {
      throw NetworkException('Request timed out', originalException: error);
    } on AppException {
      rethrow;
    } catch (error) {
      throw NetworkException(
        'Network request failed',
        originalException: error,
      );
    }
  }

  static Future<Map<String, dynamic>> _requestMultipart({
    required String path,
    required Map<String, String> fields,
    required Uint8List fileBytes,
    required String filename,
    bool includeAuth = true,
    bool allowRefresh = true,
  }) async {
    try {
      final response = await _buildAndSendMultipartRequest(
        path: path,
        fields: fields,
        fileBytes: fileBytes,
        filename: filename,
        includeAuth: includeAuth,
      );

      final decoded = _decodeBody(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _normalizeResponseMap(decoded);
      }

      if (response.statusCode == 401 &&
          includeAuth &&
          allowRefresh &&
          !_isAuthEndpoint(path) &&
          await _refreshStoredSession()) {
        return _requestMultipart(
          path: path,
          fields: fields,
          fileBytes: fileBytes,
          filename: filename,
          includeAuth: includeAuth,
          allowRefresh: false,
        );
      }

      throw _mapApiError(
        response.statusCode,
        decoded,
        fallbackMessage: _extractMessage(decoded, 'Request failed'),
      );
    } on TimeoutException catch (error) {
      throw NetworkException('Request timed out', originalException: error);
    } on AppException {
      rethrow;
    } catch (error) {
      throw NetworkException(
        'Network request failed',
        originalException: error,
      );
    }
  }

  static Future<void> initialize() async {
    // Kept for compatibility with the previous startup flow.
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    return _loginOrRegister(
      path: '/auth/login',
      body: {'email': normalizedEmail, 'password': normalizedPassword},
    );
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String role = 'student',
    String? department,
    String? departmentId,
    String? program,
    String? programId,
  }) async {
    return _loginOrRegister(
      path: '/auth/register',
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
        'fullName': fullName.trim(),
        'role': role,
        'department': department,
        'departmentId': departmentId,
        'program': program,
        'programId': programId,
      },
    );
  }

  static Future<void> logout() async {
    await _clearStoredSession();
  }

  static Future<UserModel?> getCurrentUser() async {
    try {
      final payload = await _requestJson(method: 'GET', path: '/auth/me');

      final user = _extractUserMap(payload);
      if (user == null) {
        return null;
      }

      await _persistAuthSession(user: user);
      return UserModel.fromJson(user);
    } on NetworkException catch (_) {
      final snapshot = await _loadStoredUserSnapshot();
      if (snapshot != null) {
        return UserModel.fromJson(snapshot);
      }
      rethrow;
    } on AppException {
      rethrow;
    }
  }

  static Future<String?> getCurrentUserId() async {
    final prefs = await _prefs;
    final storedId = prefs.getString(StorageKeys.userId);
    if (storedId != null && storedId.isNotEmpty) {
      return storedId;
    }

    final user = await getCurrentUser();
    return user?.id;
  }

  static Future<String?> getCurrentUserRole() async {
    final prefs = await _prefs;
    final storedRole = prefs.getString(StorageKeys.userRole);
    if (storedRole != null && storedRole.isNotEmpty) {
      return storedRole;
    }

    final user = await getCurrentUser();
    return user?.role;
  }

  static Future<List<ResearchModel>> getMyResearch() async {
    final payload = await _requestJson(
      method: 'GET',
      path: '/research/my/papers',
    );

    final papers = payload['papers'];
    if (papers is! List) return <ResearchModel>[];

    return papers
        .whereType<Map>()
        .map(
          (entry) => ResearchModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  static Future<List<ResearchModel>> getPublishedPapers({
    String? category,
    String? search,
    String? year,
  }) async {
    final payload = await _requestJson(
      method: 'GET',
      path: '/research/published',
      queryParameters: {
        if (category != null && category.isNotEmpty) 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
        if (year != null && year.isNotEmpty) 'year': year,
      },
      includeAuth: false,
    );

    final papers = payload['papers'];
    if (papers is! List) return <ResearchModel>[];

    return papers
        .whereType<Map>()
        .map(
          (entry) => ResearchModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  static Future<ResearchModel> getResearchById(String id) async {
    final payload = await _requestJson(method: 'GET', path: '/research/$id');

    final paper = _asMap(payload['paper']) ?? payload;
    return ResearchModel.fromJson(paper);
  }

  static Future<void> submitResearch({
    required String title,
    required String abstract,
    String? keywords,
    required String category,
    String? coAuthors,
    bool allowDownload = false,
    bool allowHighlight = false,
    required Uint8List fileBytes,
    required String filename,
    String? facultyId,
    String? department,
    String? departmentId,
  }) async {
    final fields = <String, String>{
      'title': title,
      'abstract': abstract,
      'category': category,
      'allowDownload': allowDownload.toString(),
      'allowHighlight': allowHighlight.toString(),
      if (keywords != null && keywords.trim().isNotEmpty)
        'keywords': keywords.trim(),
      if (coAuthors != null && coAuthors.trim().isNotEmpty)
        'coAuthors': coAuthors.trim(),
      if (facultyId != null && facultyId.trim().isNotEmpty)
        'facultyId': facultyId.trim(),
      if (department != null && department.trim().isNotEmpty)
        'department': department.trim(),
      if (departmentId != null && departmentId.trim().isNotEmpty)
        'departmentId': departmentId.trim(),
    };

    await _requestMultipart(
      path: '/research/submit',
      fields: fields,
      fileBytes: fileBytes,
      filename: filename,
    );
  }

  static Future<void> trackDownload(String paperId) async {
    await _requestJson(
      method: 'POST',
      path: '/research/$paperId/download',
      includeAuth: true,
    );
  }

  static Future<void> trackView(String paperId) async {
    await _requestJson(
      method: 'POST',
      path: '/research/$paperId/view',
      includeAuth: true,
    );
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final payload = await _requestJson(
      method: 'GET',
      path: '/research/categories',
      includeAuth: false,
    );

    final categories = payload['categories'];
    if (categories is! List) return <Map<String, dynamic>>[];

    return categories
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getDepartments() async {
    final payload = await _requestJson(
      method: 'GET',
      path: '/departments',
      includeAuth: false,
    );

    final departments = payload['departments'];
    if (departments is! List) return <Map<String, dynamic>>[];

    return departments
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getFacultyMembers({
    String? department,
    String? departmentId,
  }) async {
    final payload = await _requestJson(
      method: 'GET',
      path: '/research/faculty/members',
      queryParameters: {
        if (department != null && department.isNotEmpty)
          'department': department,
        if (departmentId != null && departmentId.isNotEmpty)
          'departmentId': departmentId,
      },
    );

    final facultyMembers = payload['facultyMembers'];
    if (facultyMembers is! List) return <Map<String, dynamic>>[];

    return facultyMembers
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2) return <Map<String, dynamic>>[];

    final payload = await _requestJson(
      method: 'GET',
      path: '/auth/students/search',
      queryParameters: {'query': normalizedQuery},
    );

    final students = payload['students'];
    if (students is! List) return <Map<String, dynamic>>[];

    return students
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  static Future<List<ResearchModel>> getAllResearch({String? status}) async {
    final payload = await _requestJson(
      method: 'GET',
      path: '/research/all/papers',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    final papers = payload['papers'];
    if (papers is! List) return <ResearchModel>[];

    return papers
        .whereType<Map>()
        .map(
          (entry) => ResearchModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
  }

  static Future<void> approveResearch(
    String paperId, {
    String? comments,
  }) async {
    await _requestJson(
      method: 'POST',
      path: '/research/$paperId/approve',
      body: {
        if (comments != null && comments.trim().isNotEmpty)
          'comments': comments.trim(),
      },
    );
  }

  static Future<void> rejectResearch(String paperId, String reason) async {
    await _requestJson(
      method: 'POST',
      path: '/research/$paperId/reject',
      body: {'reason': reason},
    );
  }

  static Future<void> requestRevision(String paperId, String notes) async {
    await _requestJson(
      method: 'POST',
      path: '/research/$paperId/revision',
      body: {'notes': notes},
    );
  }

  static Future<String> getSignedPdfUrl(String fileUrl) async {
    return fileUrl;
  }

  static Future<bool> isFileAccessible(String url) async {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
