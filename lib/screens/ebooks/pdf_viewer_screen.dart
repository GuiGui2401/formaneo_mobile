import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../../config/theme.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PdfViewerScreen({
    Key? key,
    required this.title,
    required this.pdfUrl,
  }) : super(key: key);

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isLoading = true;
  bool _isReady = false;
  String? _errorMessage;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPdf();
  }

  Future<void> _downloadAndLoadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Télécharger le PDF dans le stockage local
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');
      
      final dio = Dio();
      await dio.download(widget.pdfUrl, file.path);
      
      setState(() {
        _localPath = file.path;
        _isLoading = false;
        _isReady = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du téléchargement du PDF: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement du PDF'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.file_download, color: Colors.white),
            onPressed: _downloadPdf,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handlePopupMenuSelection,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 18),
                      SizedBox(width: 8),
                      Text('Partager'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'print',
                  child: Row(
                    children: [
                      Icon(Icons.print, size: 18),
                      SizedBox(width: 8),
                      Text('Imprimer'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            ),
          if (_errorMessage != null)
            Container(
              padding: EdgeInsets.all(16),
              color: AppTheme.errorColor.withOpacity(0.1),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: AppTheme.errorColor),
                textAlign: TextAlign.center,
              ),
            ),
          if (_isReady && _localPath != null)
            Expanded(
              child: PDFView(
                filePath: _localPath,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: false,
                pageFling: true,
                pageSnap: true,
                defaultPage: _currentPage,
                fitPolicy: FitPolicy.WIDTH,
                preventLinkNavigation: false,
                onRender: (_pages) {
                  setState(() {
                    _totalPages = _pages!;
                    _isReady = true;
                  });
                },
                onError: (error) {
                  setState(() {
                    _errorMessage = error.toString();
                  });
                },
                onPageError: (page, error) {
                  setState(() {
                    _errorMessage = 'Erreur sur la page $page: $error';
                  });
                },
                onViewCreated: (PDFViewController pdfViewController) {
                  // Vous pouvez conserver une référence au contrôleur si nécessaire
                },
                onLinkHandler: (String? uri) {
                  print('Lien cliqué: $uri');
                },
                onPageChanged: (int? page, int? total) {
                  setState(() {
                    _currentPage = page!;
                  });
                },
              ),
            ),
          if (!_isLoading && !_isReady && _errorMessage == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Préparation du document...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goToPreviousPage,
          ),
          Text(
            '${_currentPage + 1}/$_totalPages',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: _goToNextPage,
          ),
        ],
      ),
    );
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _downloadPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement du PDF...'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
    // Le PDF est déjà téléchargé localement, on peut implémenter une fonction de sauvegarde ici
  }

  void _handlePopupMenuSelection(String value) {
    switch (value) {
      case 'share':
        _shareDocument();
        break;
      case 'print':
        _printDocument();
        break;
    }
  }

  void _shareDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partage du document...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
    // Implémentez la logique de partage ici
  }

  void _printDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Impression du document...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
    // Implémentez la logique d'impression ici
  }

  @override
  void dispose() {
    super.dispose();
  }
}