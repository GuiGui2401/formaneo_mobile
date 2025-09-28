import 'package:flutter/foundation.dart';
import 'package:cinetpay/cinetpay.dart';
import 'package:flutter/material.dart';
import '../models/ebook.dart';
import '../services/ebook_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EbookProvider extends ChangeNotifier {
  List<Ebook> _ebooks = [];
  Ebook? _currentEbook;
  bool _isLoading = false;
  String? _error;

  List<Ebook> get ebooks => _ebooks;
  Ebook? get currentEbook => _currentEbook;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEbooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await EbookService.getEbooks();
      _ebooks = (data['ebooks'] as List)
          .map((ebookData) => Ebook.fromJson(ebookData))
          .toList();
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement des ebooks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Ebook?> loadEbook(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await EbookService.getEbook(id);
      _currentEbook = Ebook.fromJson(data['ebook']);
      return _currentEbook;
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement de l\'ebook: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> downloadEbook(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await EbookService.downloadEbook(id);
      final downloadUrl = data['download_url'];
      
      if (downloadUrl != null) {
        // Mettre à jour l'état de téléchargement de l'ebook dans la liste
        // Mettre à jour l'ebook courant s'il existe
        if (_currentEbook != null && _currentEbook!.id == id) {
          _currentEbook = Ebook(
            id: _currentEbook!.id,
            title: _currentEbook!.title,
            description: _currentEbook!.description,
            coverImageUrl: _currentEbook!.coverImageUrl,
            pdfUrl: downloadUrl, // Mettre à jour avec l'URL de téléchargement
            author: _currentEbook!.author,
            price: _currentEbook!.price,
            pages: _currentEbook!.pages,
            category: _currentEbook!.category,
            rating: _currentEbook!.rating,
            downloads: _currentEbook!.downloads,
            isPurchased: _currentEbook!.isPurchased,
            createdAt: _currentEbook!.createdAt,
            updatedAt: _currentEbook!.updatedAt,
          );
        }
        
        // Mettre à jour l'ebook dans la liste
        for (int i = 0; i < _ebooks.length; i++) {
          if (_ebooks[i].id == id) {
            _ebooks[i] = Ebook(
              id: _ebooks[i].id,
              title: _ebooks[i].title,
              description: _ebooks[i].description,
              coverImageUrl: _ebooks[i].coverImageUrl,
              pdfUrl: downloadUrl, // Mettre à jour avec l'URL de téléchargement
              author: _ebooks[i].author,
              price: _ebooks[i].price,
              pages: _ebooks[i].pages,
              category: _ebooks[i].category,
              rating: _ebooks[i].rating,
              downloads: _ebooks[i].downloads,
              isPurchased: _ebooks[i].isPurchased,
              createdAt: _ebooks[i].createdAt,
              updatedAt: _ebooks[i].updatedAt,
            );
            break;
          }
        }
        
        notifyListeners();
        return true;
      } else {
        throw Exception('Lien de téléchargement non disponible');
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du téléchargement de l\'ebook: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> viewEbook(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await EbookService.viewEbook(id);
      final viewUrl = data['view_url'];
      
      if (viewUrl != null) {
        // Stocker l'URL de consultation pour l'utiliser dans l'interface
        _currentEbook = _currentEbook != null ? 
          Ebook(
            id: _currentEbook!.id,
            title: _currentEbook!.title,
            description: _currentEbook!.description,
            coverImageUrl: _currentEbook!.coverImageUrl,
            pdfUrl: _currentEbook!.pdfUrl,
            author: _currentEbook!.author,
            price: _currentEbook!.price,
            pages: _currentEbook!.pages,
            category: _currentEbook!.category,
            rating: _currentEbook!.rating,
            downloads: _currentEbook!.downloads,
            isPurchased: _currentEbook!.isPurchased,
            createdAt: _currentEbook!.createdAt,
            updatedAt: _currentEbook!.updatedAt,
          ) : null;
          
        notifyListeners();
        return true;
      } else {
        throw Exception('Lien de consultation non disponible');
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur lors de la consultation de l\'ebook: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> purchaseEbookWithCinetPay(BuildContext context, String ebookId, double amount, String userEmail, String userName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Obtenir les informations utilisateur
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Obtenir les détails de l'ebook
      final ebookResponse = await EbookService.getEbook(ebookId);
      final ebook = Ebook.fromJson(ebookResponse['ebook']);

      // Générer un ID de transaction unique
      final transactionId = 'EBOOK_${DateTime.now().millisecondsSinceEpoch}_${ebookId}';

      // Configuration CinetPay
      final configData = <String, dynamic>{
        'apikey': '45213166268af015b7d2734.50726534', // Remplacer par la vraie clé
        'site_id': 105905750, // Remplacer par le vrai site ID
        'notify_url': 'http://admin.cleanestuaire.com/api/v1/cinetpay/notify'
      };

      // Données de paiement
      final paymentData = <String, dynamic>{
        'transaction_id': transactionId,
        'amount': amount,
        'currency': 'XOF',
        'channels': 'ALL',
        'description': 'Achat de l\'ebook ${ebook.title}',
        'customer_name': userName,
        'customer_surname': '',
        'customer_email': userEmail,
        'customer_phone_number': '', // À récupérer de l'utilisateur
        'customer_country': 'CI',
      };

      // Naviguer vers CinetPay
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CinetPayCheckout(
            title: 'Paiement CinetPay',
            configData: configData,
            paymentData: paymentData,
            waitResponse: (data) {
              print('Réponse CinetPay: $data');
            },
            onError: (error) {
              print('Erreur CinetPay: $error');
            },
          ),
        ),
      );

      // Vérifier le résultat du paiement
      if (result != null && result['status'] == 'ACCEPTED') {
        // Paiement réussi, appeler l'API backend pour finaliser l'achat
        final apiResult = await EbookService.purchaseEbook(ebookId);
        if (apiResult['success'] == true && apiResult['download_url'] != null) {
          // Télécharger le PDF
          final downloadUrl = apiResult['download_url'];
          if (await canLaunch(downloadUrl)) {
            await launch(downloadUrl);
            return true;
          } else {
            throw Exception('Impossible d\'ouvrir le lien de téléchargement');
          }
        }
        return apiResult['success'] == true;
      } else {
        throw Exception('Paiement échoué ou annulé');
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur lors de l\'achat de l\'ebook avec CinetPay: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> purchaseEbook(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await EbookService.purchaseEbook(id);
      
      // Mettre à jour l'état d'achat de l'ebook dans la liste
      if (result['success'] == true) {
        // Mettre à jour l'ebook courant s'il existe
        if (_currentEbook != null && _currentEbook!.id == id) {
          _currentEbook = Ebook(
            id: _currentEbook!.id,
            title: _currentEbook!.title,
            description: _currentEbook!.description,
            coverImageUrl: _currentEbook!.coverImageUrl,
            pdfUrl: _currentEbook!.pdfUrl,
            author: _currentEbook!.author,
            price: _currentEbook!.price,
            pages: _currentEbook!.pages,
            category: _currentEbook!.category,
            rating: _currentEbook!.rating,
            downloads: _currentEbook!.downloads,
            isPurchased: true, // Marquer comme acheté
            createdAt: _currentEbook!.createdAt,
            updatedAt: _currentEbook!.updatedAt,
          );
        }
        
        // Mettre à jour l'ebook dans la liste
        for (int i = 0; i < _ebooks.length; i++) {
          if (_ebooks[i].id == id) {
            _ebooks[i] = Ebook(
              id: _ebooks[i].id,
              title: _ebooks[i].title,
              description: _ebooks[i].description,
              coverImageUrl: _ebooks[i].coverImageUrl,
              pdfUrl: _ebooks[i].pdfUrl,
              author: _ebooks[i].author,
              price: _ebooks[i].price,
              pages: _ebooks[i].pages,
              category: _ebooks[i].category,
              rating: _ebooks[i].rating,
              downloads: _ebooks[i].downloads,
              isPurchased: true, // Marquer comme acheté
              createdAt: _ebooks[i].createdAt,
              updatedAt: _ebooks[i].updatedAt,
            );
            break;
          }
        }
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      print('Erreur lors de l\'achat de l\'ebook: \$e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}