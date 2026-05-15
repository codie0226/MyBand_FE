import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class AttachmentMenu extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onPickPdf;

  const AttachmentMenu({
    super.key,
    required this.onPickImage,
    required this.onPickPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAttachmentIcon(
            context,
            icon: FontAwesomeIcons.solidCalendarPlus,
            label: '일정 생성',
            onTap: () {
              final router = GoRouter.of(context);
              Navigator.pop(context);
              router.push('/add_event');
            },
          ),
          _buildAttachmentIcon(
            context,
            icon: FontAwesomeIcons.image,
            label: '이미지',
            onTap: () {
              Navigator.pop(context);
              onPickImage();
            },
          ),
          _buildAttachmentIcon(
            context,
            icon: FontAwesomeIcons.solidFilePdf,
            label: '문서 (PDF)',
            onTap: () {
              Navigator.pop(context);
              onPickPdf();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentIcon(
    BuildContext context, {
    required FaIconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: theme.dividerColor),
            ),
            child: Center(
              child: FaIcon(
                icon,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
