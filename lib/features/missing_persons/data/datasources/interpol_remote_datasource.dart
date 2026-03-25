import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/interpol_notice_model.dart';
import '../../domain/value_objects/missing_person_filter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';

abstract interface class IInterpolRemoteDatasource {
  Future<InterpolNoticeListResponse> getYellowNotices({
    required MissingPersonFilter filter,
  });

  Future<InterpolNoticeModel> getYellowNoticeDetail(String noticeId);

  Future<List<String>> getNoticeImageUrls(String noticeId);
}

class InterpolRemoteDatasource implements IInterpolRemoteDatasource {
  final http.Client _client;

  const InterpolRemoteDatasource(this._client);

  @override
  Future<InterpolNoticeListResponse> getYellowNotices({
    required MissingPersonFilter filter,
  }) async {
    final uri = _buildListUri(filter);

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      _assertSuccess(response);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return InterpolNoticeListResponse.fromJson(json);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  @override
  Future<InterpolNoticeModel> getYellowNoticeDetail(String noticeId) async {
    final uri = Uri.parse(
      '${AppConstants.interpolBaseUrl}${AppConstants.interpolYellowPath}/$noticeId',
    );

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      _assertSuccess(response);
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // Fetch images in parallel
      List<String> imageUrls = [];
      try {
        imageUrls = await getNoticeImageUrls(noticeId);
      } catch (_) {
        // Images are optional — swallow error
      }

      return InterpolNoticeModel.fromDetailJson(json, imageUrls);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  @override
  Future<List<String>> getNoticeImageUrls(String noticeId) async {
    final uri = Uri.parse(
      '${AppConstants.interpolBaseUrl}${AppConstants.interpolYellowPath}/$noticeId/images',
    );

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) return [];
      _assertSuccess(response);

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final embedded = json['_embedded'] as Map<String, dynamic>? ?? {};
      final images = embedded['images'] as List<dynamic>? ?? [];

      return images
          .whereType<Map<String, dynamic>>()
          .map((img) {
            final links = img['_links'] as Map<String, dynamic>? ?? {};
            return (links['self'] as Map<String, dynamic>?)?['href'] as String?;
          })
          .whereType<String>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  // --- Helpers ---

  Uri _buildListUri(MissingPersonFilter filter) {
    final params = <String, String>{
      'page': filter.page.toString(),
      'resultPerPage': filter.pageSize.toString(),
    };

    // Nationality: if specific nationalities are set use the first one,
    // otherwise default to a broad search (Interpol supports one per call)
    if (filter.nationalities.isNotEmpty) {
      params['nationality'] = filter.nationalities.first;
    }

    if (filter.sex?.interpolId != null) {
      params['sexId'] = filter.sex!.interpolId!;
    }

    if (filter.minAge != null) params['ageMin'] = filter.minAge.toString();
    if (filter.maxAge != null) params['ageMax'] = filter.maxAge.toString();

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      // Interpol supports forename/name separately; use as free-text split
      final parts = filter.searchQuery!.trim().split(' ');
      if (parts.length >= 2) {
        params['name'] = parts.last.toUpperCase();
        params['forename'] = parts.first.toUpperCase();
      } else {
        params['name'] = filter.searchQuery!.toUpperCase();
      }
    }

    return Uri.parse(
      '${AppConstants.interpolBaseUrl}${AppConstants.interpolYellowPath}',
    ).replace(queryParameters: params);
  }

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  void _assertSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    if (response.statusCode == 404) {
      throw const ServerException(message: 'Not found.', statusCode: 404);
    }
    if (response.statusCode == 429) {
      throw const ServerException(
          message: 'Rate limited. Try again later.', statusCode: 429);
    }
    throw ServerException(
      message: 'Server returned ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }
}
