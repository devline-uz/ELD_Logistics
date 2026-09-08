/// `M-42` kiritish qatori (Figma `1118-114`: 303×41 input + 37×41 tugma).
///
/// M140: `DR` statusida butunlay o'chiriladi va ostida izoh chiqadi.
/// Dizayndagi mikrofon tugmasi **`+` biriktirma** tugmasiga almashtirildi
/// (§11.9: `+` rasm/fayl/lokatsiya; ovozli xabar TZ da yo'q).
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    required this.enabled,
    required this.onSend,
    required this.onAttach,
    this.errorText,
    super.key,
  });

  /// M140: `false` bo'lsa kiritish bloklanadi.
  final bool enabled;

  final ValueChanged<String> onSend;
  final VoidCallback onAttach;

  /// Mijoz tomonidagi rad etish sababi (matn uzun va h.k.).
  final String? errorText;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _canSend = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final bool next = value.trim().isNotEmpty;
    if (next != _canSend) {
      setState(() => _canSend = next);
    }
  }

  void _submit() {
    final String text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) {
      return;
    }
    widget.onSend(text);
    _controller.clear();
    setState(() => _canSend = false);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      color: c.surface,
      padding: const EdgeInsets.fromLTRB(
        Spacing.screenPaddingPhone,
        Spacing.s10,
        Spacing.screenPaddingPhone,
        Spacing.s10,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          // `bottomNavigationBar` bo'sh (loose) cheklov beradi — `min` bo'lmasa
          // kompozitor butun ekranni egallaydi va ro'yxatga joy qolmaydi.
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _SquareButton(
                  icon: Icons.add,
                  semanticLabel: context.l10n.chatAttachAction,
                  onPressed: widget.enabled ? widget.onAttach : null,
                ),
                const SizedBox(width: Spacing.s5),
                Expanded(
                  child: AppTextField(
                    controller: _controller,
                    hint: context.l10n.chatInputHint,
                    enabled: widget.enabled,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onChanged: _onChanged,
                    onSubmitted: (String _) => _submit(),
                    errorText: widget.errorText,
                  ),
                ),
                const SizedBox(width: Spacing.s5),
                _SquareButton(
                  icon: Icons.send,
                  semanticLabel: context.l10n.chatSendAction,
                  filled: true,
                  onPressed: widget.enabled && _canSend ? _submit : null,
                ),
              ],
            ),
            if (!widget.enabled) ...<Widget>[
              const SizedBox(height: Spacing.s5),
              Text(
                context.l10n.chatDrivingDisabled,
                style: context.text.body16.copyWith(color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// M8: teginish maydoni ≥48×48 (planshetda 56).
class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double size = touchTarget(context);
    final bool enabled = onPressed != null;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          color: filled && enabled ? c.primary : c.surfaceAlt,
          borderRadius: BorderRadius.circular(Radii.input),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(Radii.input),
            child: Icon(
              icon,
              size: Spacing.s20,
              color: !enabled
                  ? c.textDisabled
                  : filled
                  ? c.onPrimary
                  : c.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
