/// `M-42` kiritish qatori (Figma `1118-114`: 303×41 input + 37×41 tugma).
///
/// Figma tuzilishi (#B-26): bitta `overlay` fonli `r8` konteyner — hint matni
/// chapda, **paper-plane yuborish ikonkasi shu konteyner ichida** o'ngda; undan
/// o'ngda alohida `37×41` `r8` tugma.
///
/// M140: `DR` statusida butunlay o'chiriladi va ostida izoh chiqadi.
/// Dizayndagi mikrofon tugmasi **`+` biriktirma** tugmasiga almashtirildi
/// (§11.9: `+` rasm/fayl/lokatsiya; ovozli xabar TZ da yo'q).
library;

import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n_extension.dart';
import '../../../../core/ui/ui.dart';

/// Figma: kompozitor qatori balandligi 41 dp.
const double kChatComposerHeight = 41;

/// Konteyner ichidagi kontent balandligi (41 − 2×10).
const double kChatComposerContentHeight = 21;

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
                Expanded(
                  child: _InputShell(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            enabled: widget.enabled,
                            maxLines: 4,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            onChanged: _onChanged,
                            onSubmitted: (String _) => _submit(),
                            style: context.text.body15.copyWith(color: c.textPrimary),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintText: context.l10n.chatInputHint,
                              hintStyle: context.text.body15.copyWith(color: c.textSecondary),
                            ),
                          ),
                        ),
                        const SizedBox(width: Spacing.s10),
                        _IconAction(
                          icon: Icons.send_outlined,
                          semanticLabel: context.l10n.chatSendAction,
                          onPressed: widget.enabled && _canSend ? _submit : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.s5),
                _SquareButton(
                  icon: Icons.add,
                  semanticLabel: context.l10n.chatAttachAction,
                  onPressed: widget.enabled ? widget.onAttach : null,
                ),
              ],
            ),
            if (widget.errorText != null) ...<Widget>[
              const SizedBox(height: Spacing.s5),
              Text(widget.errorText!, style: context.text.body16.copyWith(color: c.error)),
            ],
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

/// Figma: `Frame 1321317385` 37×41 `r8`, foni `overlay` — biriktirma tugmasi.
/// Teginish maydoni M8 bo'yicha ≥48 gacha kengaytiriladi.
class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.semanticLabel, required this.onPressed});

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool enabled = onPressed != null;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: touchTarget(context),
        height: kChatComposerHeight,
        child: Material(
          color: c.appBarSurface,
          borderRadius: Radii.inputRadius,
          child: InkWell(
            onTap: onPressed,
            borderRadius: Radii.inputRadius,
            child: Icon(icon, size: Spacing.s20, color: enabled ? c.textPrimary : c.textDisabled),
          ),
        ),
      ),
    );
  }
}

/// Figma: `Frame 1321317384` — `r8`, `pad(19,14,19,14)`, foni `overlay`.
class _InputShell extends StatelessWidget {
  const _InputShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: context.colors.appBarSurface, borderRadius: Radii.inputRadius),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s15, vertical: Spacing.s10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kChatComposerContentHeight),
        child: child,
      ),
    ),
  );
}

/// Konteyner ichidagi ikonka tugmasi (yuborish) — 24 dp.
class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.semanticLabel, required this.onPressed});

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Icon(
          icon,
          size: Spacing.s25,
          color: onPressed == null ? c.textDisabled : c.textPrimary,
        ),
      ),
    );
  }
}
