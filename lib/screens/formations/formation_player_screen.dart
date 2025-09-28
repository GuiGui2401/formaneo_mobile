import 'package:flutter/material.dart';
import 'package:formaneo/models/formation.dart';
import 'package:provider/provider.dart';
import '../../models/formation_pack.dart';
import '../../config/theme.dart';
import '../../providers/formation_provider.dart';
import '../../widgets/ai_assistant/ai_assistant_modal.dart';
import '../../utils/formatters.dart';

class FormationPlayerScreen extends StatefulWidget {
  final Formation formation;

  const FormationPlayerScreen({Key? key, required this.formation}) : super(key: key);

  @override
  _FormationPlayerScreenState createState() => _FormationPlayerScreenState();
}

class _FormationPlayerScreenState extends State<FormationPlayerScreen> {
  int currentModuleIndex = 0;
  bool isVideoPlaying = false;
  bool showTranscript = false;
  double videoProgress = 0.0;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration(minutes: 25); // Durée exemple
  List<Map<String, String>> userNotes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildVideoPlayer(),
            Expanded(
              child: Container(
                color: AppTheme.backgroundColor,
                child: Column(
                  children: [
                    _buildVideoControls(),
                    Expanded(
                      child: _buildContent(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAssistantFAB(),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      width: double.infinity,
      height: 220,
      color: Colors.black,
      child: Stack(
        children: [
          // Placeholder pour la vidéo
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black54,
                  Colors.black87,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isVideoPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 64,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    widget.formation.modules[currentModuleIndex].title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Contrôles de la vidéo
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          
          // Bouton plein écran
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: IconButton(
              onPressed: _toggleFullscreen,
              icon: Icon(Icons.fullscreen, color: Colors.white),
            ),
          ),
          
          // Barre de progression
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: videoProgress,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _previousModule,
                icon: Icon(Icons.skip_previous),
                color: currentModuleIndex > 0 ? AppTheme.primaryColor : Colors.grey,
              ),
              IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(isVideoPlaying ? Icons.pause : Icons.play_arrow),
                color: AppTheme.primaryColor,
                iconSize: 32,
              ),
              IconButton(
                onPressed: _nextModule,
                icon: Icon(Icons.skip_next),
                color: currentModuleIndex < widget.formation.modules.length - 1 
                    ? AppTheme.primaryColor 
                    : Colors.grey,
              ),
              SizedBox(width: AppSpacing.md),
              Text(
                '${_formatDuration(currentPosition)} / ${_formatDuration(totalDuration)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    showTranscript = !showTranscript;
                  });
                },
                icon: Icon(Icons.subtitles),
                color: showTranscript ? AppTheme.primaryColor : Colors.grey,
              ),
              IconButton(
                onPressed: _showPlaybackSpeed,
                icon: Icon(Icons.speed),
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: Color(0xFFE2E8F0),
              thumbColor: AppTheme.primaryColor,
              trackHeight: 4,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: videoProgress,
              onChanged: (value) {
                setState(() {
                  videoProgress = value;
                  currentPosition = Duration(
                    milliseconds: (totalDuration.inMilliseconds * value).round(),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primaryColor,
              tabs: [
                Tab(text: 'Modules'),
                Tab(text: 'Notes'),
                Tab(text: 'Ressources'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildModulesList(),
                _buildNotes(),
                _buildResources(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesList() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: widget.formation.modules.length,
      itemBuilder: (context, index) {
        final module = widget.formation.modules[index];
        final isCurrentModule = index == currentModuleIndex;
        final isCompleted = index < currentModuleIndex;
        
        return Card(
          margin: EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? AppTheme.accentColor 
                    : isCurrentModule 
                        ? AppTheme.primaryColor 
                        : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted 
                    ? Icons.check 
                    : isCurrentModule 
                        ? Icons.play_arrow 
                        : Icons.lock,
                color: isCompleted || isCurrentModule ? Colors.white : Colors.grey,
                size: 18,
              ),
            ),
            title: Text(
              '${index + 1}. ${module.title}',
              style: TextStyle(
                fontWeight: isCurrentModule ? FontWeight.w600 : FontWeight.normal,
                color: isCurrentModule ? AppTheme.primaryColor : AppTheme.textPrimary,
              ),
            ),
            subtitle: Text(
              '${Formatters.formatDuration(module.duration)} • ${isCompleted ? 'Terminé' : isCurrentModule ? 'En cours' : 'Verrouillé'}',
              style: TextStyle(
                fontSize: 12,
                color: isCompleted 
                    ? AppTheme.accentColor 
                    : isCurrentModule 
                        ? AppTheme.primaryColor 
                        : Colors.grey,
              ),
            ),
            trailing: isCurrentModule 
                ? Icon(Icons.volume_up, color: AppTheme.primaryColor, size: 16)
                : null,
            onTap: index <= currentModuleIndex ? () => _selectModule(index) : null,
          ),
        );
      },
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mes Notes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ElevatedButton.icon(
                onPressed: _addNote,
                icon: Icon(Icons.add, size: 16),
                label: Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: userNotes.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_add, size: 64, color: Colors.grey[400]),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'Aucune note pour le moment',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'Ajoutez des notes pour retenir les points importants',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: userNotes.length,
                    itemBuilder: (context, index) {
                      final note = userNotes[index];
                      return _buildNoteCard(
                        note['title'] ?? 'Note ${index + 1}',
                        note['content'] ?? '',
                        note['timestamp'] ?? '',
                        index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(String title, String content, String timestamp, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              content,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editNote(index),
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Modifier'),
                ),
                TextButton.icon(
                  onPressed: () => _deleteNote(index),
                  icon: Icon(Icons.delete, size: 16),
                  label: Text('Supprimer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResources() {
    final resources = [
      {
        'title': 'Guide PDF - ${widget.formation.title}',
        'size': 'PDF • 2.3 MB',
        'icon': Icons.picture_as_pdf,
        'color': Colors.red,
      },
      {
        'title': 'Templates - Exercices pratiques',
        'size': 'XLSX • 1.1 MB',
        'icon': Icons.table_chart,
        'color': Colors.green,
      },
      {
        'title': 'Checklist - Points clés',
        'size': 'PDF • 0.8 MB',
        'icon': Icons.checklist,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Bonus - Scripts et exemples',
        'size': 'DOCX • 0.5 MB',
        'icon': Icons.description,
        'color': Colors.blue,
      },
    ];

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ressources Téléchargeables',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.builder(
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final resource = resources[index];
                return _buildResourceCard(
                  resource['title'] as String,
                  resource['size'] as String,
                  resource['icon'] as IconData,
                  resource['color'] as Color,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(String title, String size, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(size),
        trailing: IconButton(
          onPressed: () => _downloadResource(title),
          icon: Icon(Icons.download),
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildAssistantFAB() {
    return FloatingActionButton.extended(
      onPressed: _showAssistant,
      backgroundColor: AppTheme.primaryColor,
      icon: Icon(Icons.psychology, color: Colors.white),
      label: Text(
        'Assistant',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Fonctions de contrôle
  void _togglePlayPause() {
    setState(() {
      isVideoPlaying = !isVideoPlaying;
    });
    
    if (isVideoPlaying) {
      _startProgressTimer();
    }
  }

  void _startProgressTimer() {
    // Simulation de progression vidéo
    Future.delayed(Duration(seconds: 1), () {
      if (isVideoPlaying && mounted) {
        setState(() {
          videoProgress += 0.01;
          currentPosition = Duration(
            milliseconds: (totalDuration.inMilliseconds * videoProgress).round(),
          );
          
          if (videoProgress >= 1.0) {
            videoProgress = 1.0;
            isVideoPlaying = false;
            _completeModule();
          }
        });
        
        if (isVideoPlaying) {
          _startProgressTimer();
        }
      }
    });
  }

  void _previousModule() {
    if (currentModuleIndex > 0) {
      setState(() {
        currentModuleIndex--;
        videoProgress = 0.0;
        currentPosition = Duration.zero;
        isVideoPlaying = false;
      });
    }
  }

  void _nextModule() {
    if (currentModuleIndex < widget.formation.modules.length - 1) {
      setState(() {
        currentModuleIndex++;
        videoProgress = 0.0;
        currentPosition = Duration.zero;
        isVideoPlaying = false;
      });
    }
  }

  void _selectModule(int index) {
    setState(() {
      currentModuleIndex = index;
      videoProgress = 0.0;
      currentPosition = Duration.zero;
      isVideoPlaying = false;
    });
  }

  void _completeModule() {
    // Marquer le module comme terminé
    final provider = Provider.of<FormationProvider>(context, listen: false);
    provider.updateProgress(widget.formation.id, (currentModuleIndex + 1) / widget.formation.modules.length * 100);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Module terminé ! +50 FCFA de bonus'),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Passer au module suivant automatiquement
    if (currentModuleIndex < widget.formation.modules.length - 1) {
      Future.delayed(Duration(seconds: 2), () {
        _nextModule();
      });
    }
  }

  void _toggleFullscreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mode plein écran - Fonctionnalité bientôt disponible'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPlaybackSpeed() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vitesse de lecture',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSpacing.lg),
            ...['0.5x', '0.75x', '1x', '1.25x', '1.5x', '2x'].map((speed) {
              return ListTile(
                title: Text(speed),
                trailing: speed == '1x' ? Icon(Icons.check, color: AppTheme.primaryColor) : null,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vitesse changée à $speed')),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _addNote() {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Timestamp: ${_formatDuration(currentPosition)}'),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Titre de la note...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contenu de la note...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                setState(() {
                  userNotes.add({
                    'title': titleController.text.isNotEmpty ? titleController.text : 'Note ${userNotes.length + 1}',
                    'content': noteController.text,
                    'timestamp': _formatDuration(currentPosition),
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Note ajoutée !')),
                );
              }
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _editNote(int index) {
    final note = userNotes[index];
    final titleController = TextEditingController(text: note['title']);
    final noteController = TextEditingController(text: note['content']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier la note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Titre de la note...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contenu de la note...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userNotes[index] = {
                  'title': titleController.text.isNotEmpty ? titleController.text : 'Note ${index + 1}',
                  'content': noteController.text,
                  'timestamp': note['timestamp'] ?? '',
                };
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Note modifiée !')),
              );
            },
            child: Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la note'),
        content: Text('Êtes-vous sûr de vouloir supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userNotes.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Note supprimée !')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _downloadResource(String resourceName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement de "$resourceName" commencé...'),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIAssistantModal(
        packName: widget.formation.title,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}