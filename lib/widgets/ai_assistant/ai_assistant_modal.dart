import 'package:flutter/material.dart';
import '../../config/theme.dart';

class AIAssistantModal extends StatefulWidget {
  final String packName;

  const AIAssistantModal({Key? key, required this.packName}) : super(key: key);

  @override
  _AIAssistantModalState createState() => _AIAssistantModalState();
}

class _AIAssistantModalState extends State<AIAssistantModal> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAssistant();
  }

  void _initializeAssistant() {
    setState(() {
      messages.add(
        ChatMessage(
          text: "Bonjour ! Je suis le Professionnel IA Formaneo pour le pack \"${widget.packName}\". "
              "Je suis là pour vous aider à comprendre les concepts, répondre à vos questions et vous guider dans votre apprentissage. "
              "Comment puis-je vous aider aujourd'hui ?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.xl)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.xl)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Professionnel IA Formaneo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Expert en ${widget.packName}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isLoading) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppTheme.primaryColor 
                    : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg).copyWith(
                  bottomLeft: message.isUser 
                      ? Radius.circular(AppBorderRadius.lg) 
                      : Radius.circular(4),
                  bottomRight: message.isUser 
                      ? Radius.circular(4) 
                      : Radius.circular(AppBorderRadius.lg),
                ),
                border: message.isUser 
                    ? null 
                    : Border.all(color: Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white.withOpacity(0.7) 
                          : AppTheme.textLight,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: AppSpacing.sm),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.secondaryColor,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: 4),
                _buildDot(1),
                SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.3 + (0.3 * value)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Posez votre question...',
                hintStyle: TextStyle(color: AppTheme.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Container(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || isLoading) return;

    String userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      isLoading = true;
    });

    _scrollToBottom();

    // Simulation de réponse de l'IA
    await Future.delayed(Duration(seconds: 2));

    String response = _generateResponse(userMessage);

    setState(() {
      messages.add(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      isLoading = false;
    });

    _scrollToBottom();
  }

  String _generateResponse(String message) {
    // Réponses prédéfinies basées sur des mots-clés
    if (message.toLowerCase().contains('dropshipping')) {
      return "Le dropshipping est un modèle d'affaires où vous vendez des produits sans les stocker. "
             "Dans ce pack, vous apprendrez à identifier des produits gagnants, créer une boutique optimisée, "
             "et maîtriser les stratégies publicitaires pour maximiser vos profits.";
    } else if (message.toLowerCase().contains('formation')) {
      return "Ce pack contient plusieurs formations complètes. Chaque formation est divisée en modules "
             "progressifs. Je vous recommande de suivre l'ordre proposé pour une meilleure compréhension. "
             "N'hésitez pas à me poser des questions spécifiques sur chaque module !";
    } else if (message.toLowerCase().contains('aide') || message.toLowerCase().contains('help')) {
      return "Je suis là pour vous accompagner ! Vous pouvez me demander :\n"
             "• Des explications sur les concepts\n"
             "• Des conseils pratiques\n"
             "• De l'aide sur les exercices\n"
             "• Des recommandations personnalisées";
    } else {
      return "C'est une excellente question ! Dans le contexte de ${widget.packName}, "
             "je vous recommande de bien maîtriser les fondamentaux avant de passer aux techniques avancées. "
             "Avez-vous des questions spécifiques sur un module en particulier ?";
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}