import 'package:flutter/foundation.dart';
import 'package:cinetpay/cinetpay.dart';
import '../models/formation_pack.dart';
import '../models/formation.dart';
import '../services/formation_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormationProvider extends ChangeNotifier {
  List<FormationPack> _formationPacks = [];
  List<Formation> _formations = [];
  bool _isLoading = false;
  String? _error;

  List<FormationPack> get formationPacks => _formationPacks;
  List<Formation> get formations => _formations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFormationPacks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await FormationService.getFormationPacks();
      
      // Vérifier que la réponse contient bien la clé 'packs'
      if (data.containsKey('packs') && data['packs'] is List) {
        _formationPacks = (data['packs'] as List)
            .map((packData) => FormationPack.fromJson(packData))
            .toList();
      } else {
        // Si la structure n'est pas celle attendue, initialiser avec une liste vide
        _formationPacks = [];
        _error = 'Format de données invalide pour les packs de formations';
        print('Erreur: Format de données invalide pour les packs de formations. Réponse reçue: $data');
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement des packs de formations: $e');
      // En cas d'erreur, on initialise avec une liste vide
      _formationPacks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<FormationPack?> loadFormationPackDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await FormationService.getFormationPack(id);
      
      // Vérifier que la réponse contient bien la clé 'pack'
      if (data.containsKey('pack') && data['pack'] is Map<String, dynamic>) {
        final packData = data['pack'] as Map<String, dynamic>;
        
        // Charger les formations du pack si elles ne sont pas déjà incluses
        if (!packData.containsKey('formations') || packData['formations'] == null) {
          try {
            final formationsData = await FormationService.getFormationsForPack(id);
            if (formationsData.containsKey('formations') && formationsData['formations'] is List) {
              packData['formations'] = formationsData['formations'];
            }
          } catch (formationsError) {
            print('Erreur lors du chargement des formations du pack: $formationsError');
            // Continuer sans les formations si le chargement échoue
          }
        }
        
        final pack = FormationPack.fromJson(packData);
        
        // Mettre à jour le pack dans la liste si il existe déjà
        final index = _formationPacks.indexWhere((existingPack) => existingPack.id == id);
        if (index != -1) {
          _formationPacks[index] = pack;
          notifyListeners();
        }
        
        return pack;
      } else {
        throw Exception('Format de données invalide pour le pack de formations');
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement des détails du pack de formations: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Formation>?> loadFormationsForPack(String packId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await FormationService.getFormationsForPack(packId);
      
      // Vérifier que la réponse contient bien la clé 'formations'
      if (data.containsKey('formations') && data['formations'] is List) {
        final formationsList = (data['formations'] as List)
            .map((formationData) => Formation.fromJson(formationData))
            .toList();
        
        // Mettre à jour la liste des formations
        _formations = formationsList;
        notifyListeners();
        
        return formationsList;
      } else {
        throw Exception('Format de données invalide pour les formations du pack');
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement des formations du pack: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> purchaseFormationPack(String packId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FormationService.purchaseFormationPack(packId);
      return result['success'] == true;
    } catch (e) {
      _error = e.toString();
      print("Erreur lors de l'achat du pack de formations: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateProgress(String formationId, double progress) async {
    // Cette méthode sera implémentée pour mettre à jour la progression
    // Dans une vraie application, elle ferait un appel API
    print('Mise à jour de la progression pour la formation $formationId: $progress%');
  }
}