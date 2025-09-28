import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../lib/config/api_config.dart';
import '../lib/services/api_service.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'affiliate_api_test.mocks.dart';

void main() {
  group('Affiliate API Tests', () {
    late MockClient mockClient;
    late ApiService apiService;

    setUp(() {
      mockClient = MockClient();
      // We would need to mock the static methods in ApiService
      // For now, we'll test the API endpoints directly
    });

    test('Test affiliate dashboard endpoint', () async {
      final url = '${ApiConfig.baseUrl}${ApiConfig.affiliateEndpoint}/dashboard';
      print('Testing URL: $url');
      
      // In a real test, we would mock the HTTP client and verify the response
      // For now, we'll just print the URL to verify it's correct
      expect(url, equals('http://admin.cleanestuaire.com/api/v1/affiliate/dashboard'));
    });

    test('Test affiliate list endpoint', () async {
      final url = '${ApiConfig.baseUrl}${ApiConfig.affiliateEndpoint}/list?page=1&limit=20';
      print('Testing URL: $url');
      
      expect(url, equals('http://admin.cleanestuaire.com/api/v1/affiliate/list?page=1&limit=20'));
    });
  });
}