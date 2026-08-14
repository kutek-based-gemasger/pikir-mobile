import 'package:flutter/material.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';

/// A group of settings rows under a small grey header.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: PikirText.label.copyWith(color: PikirColors.textSecondary),
          ),
        ),
        PikirCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(indent: 20),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One tappable settings row.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.detail,
    this.icon,
    this.onTap,
    this.destructive = false,
    this.trailing,
  });

  final String label;
  final String? detail;
  final IconData? icon;
  final VoidCallback? onTap;

  /// Renders the label in the danger colour.
  ///
  /// Used only for deleting everything. It stays in the ordinary row style at
  /// the ordinary size: the destructive option is neither hidden nor buried,
  /// because someone who wants their data gone should be able to find it.
  final bool destructive;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? PikirColors.danger
        : PikirColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: PikirText.body.copyWith(color: color)),
                  if (detail != null) ...[
                    const SizedBox(height: 2),
                    Text(detail!, style: PikirText.captionSecondary),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: PikirColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

/// A row with a switch on the right.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.detail,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      label: label,
      detail: detail,
      onTap: () => onChanged(!value),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: PikirColors.onPrimary,
        activeTrackColor: PikirColors.primary,
      ),
    );
  }
}
