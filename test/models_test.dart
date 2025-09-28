// Test file to verify that the models compile correctly
import 'package:flutter_test/flutter_test.dart';
import 'package:formaneo/models/user.dart';
import 'package:formaneo/models/formation_pack.dart';
import 'package:formaneo/models/formation.dart';
import 'package:formaneo/models/module.dart';

void main() {
  test('Models should be created without errors', () {
    // Test User model
    final user = User(
      id: '1',
      name: 'Test User',
      email: 'test@example.com',
      promoCode: 'TEST123',
      affiliateLink: 'https://example.com/invite/TEST123',
      createdAt: DateTime.now(),
    );
    
    expect(user.id, '1');
    expect(user.name, 'Test User');
    expect(user.email, 'test@example.com');
    
    // Test FormationPack model
    final pack = FormationPack(
      id: '1',
      name: 'Test Pack',
      slug: 'test-pack',
      author: 'Test Author',
      price: 10000.0,
      formations: [],
      totalDuration: 3600,
      rating: 4.5,
      studentsCount: 100,
      formationsCount: 10,
      isFeatured: true,
      isActive: true,
      order: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    expect(pack.id, '1');
    expect(pack.name, 'Test Pack');
    expect(pack.price, 10000.0);
    
    // Test Formation model
    final formation = Formation(
      id: '1',
      packId: '1',
      title: 'Test Formation',
      duration: 3600,
      order: 1,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    expect(formation.id, '1');
    expect(formation.title, 'Test Formation');
    
    // Test Module model
    final module = Module(
      id: '1',
      formationId: '1',
      title: 'Test Module',
      duration: 1800,
      order: 1,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    expect(module.id, '1');
    expect(module.title, 'Test Module');
  });
}