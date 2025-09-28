import 'package:flutter/material.dart';
import '../../config/theme.dart';

class QuizCard extends StatelessWidget {
  final String subject;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLocked;
  final int? questionsCount;
  final String? difficulty;

  const QuizCard({
    Key? key,
    required this.subject,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLocked = false,
    this.questionsCount,
    this.difficulty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: isLocked 
                ? null 
                : LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey[300] : color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock : icon,
                      color: isLocked ? Colors.grey : color,
                      size: 24,
                    ),
                  ),
                  Spacer(),
                  if (difficulty != null && !isLocked)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Text(
                        difficulty!,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                subject,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? Colors.grey : AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isLocked ? Colors.grey : AppTheme.textSecondary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (questionsCount != null && !isLocked) ...[
                    Icon(Icons.quiz, size: 14, color: AppTheme.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      '$questionsCount questions',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  Spacer(),
                  if (isLocked)
                    Text(
                      'Verrouillé',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: color,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}