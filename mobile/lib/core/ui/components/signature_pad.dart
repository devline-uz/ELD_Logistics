/// `SignaturePad` — imzo maydoni (tz-mobile §11.0.4, §12).
///
/// Balandlik ≥200 dp, `Clear` / `Save`. Chiqish — PNG baytlari; `signed_at`
/// **bu yerda hosil qilinmaydi** (vaqt `core/time/TimeSource` dan, chaqiruvchi
/// qatlamda) — shuning uchun widget'da `DateTime.now()` yo'q.
///
/// To'liq oflayn: `CustomPainter` + `dart:ui` rasterizatsiyasi, tarmoq yo'q.
library;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../radius.dart';
import '../spacing.dart';
import '../theme.dart';
import '../tokens.dart';
import 'app_button.dart';

/// Imzo maydonining minimal balandligi (tz-mobile §11.0.4).
const double kSignaturePadMinHeight = 200;

class SignaturePad extends StatefulWidget {
  const SignaturePad({
    required this.clearLabel,
    required this.saveLabel,
    required this.onSaved,
    this.hint,
    this.height = kSignaturePadMinHeight,
    this.strokeWidth = 2.5,
    this.exportPixelRatio = 2,
    super.key,
  });

  /// Lokalizatsiya qilingan `Clear`.
  final String clearLabel;

  /// Lokalizatsiya qilingan `Save`.
  final String saveLabel;

  /// Bo'sh maydondagi izoh (lokalizatsiyalangan).
  final String? hint;

  /// PNG baytlari qaytadi. `signed_at` ni chaqiruvchi `TimeSource` dan oladi.
  final ValueChanged<Uint8List> onSaved;

  final double height;
  final double strokeWidth;

  /// Eksport aniqligi (2× — 200 dp maydon uchun yetarli).
  final double exportPixelRatio;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final List<List<Offset>> _strokes = <List<Offset>>[];
  final GlobalKey _canvasKey = GlobalKey();
  Size _canvasSize = Size.zero;

  bool get _isEmpty => _strokes.every((List<Offset> s) => s.isEmpty);

  void _start(Offset local) => setState(() => _strokes.add(<Offset>[local]));

  void _extend(Offset local) {
    if (_strokes.isEmpty) {
      return;
    }
    setState(() => _strokes.last.add(local));
  }

  void _clear() => setState(_strokes.clear);

  Future<void> _save() async {
    if (_isEmpty || _canvasSize.isEmpty) {
      return;
    }
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.scale(widget.exportPixelRatio);
    // Shaffof fon: PNG imzo boshqa hujjatlar ustiga qo'yiladi.
    _SignaturePainter(
      strokes: _strokes,
      color: context.colors.textPrimary,
      strokeWidth: widget.strokeWidth,
    ).paint(canvas, _canvasSize);

    final ui.Image image = await recorder.endRecording().toImage(
      (_canvasSize.width * widget.exportPixelRatio).round(),
      (_canvasSize.height * widget.exportPixelRatio).round(),
    );
    final ByteData? png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (png == null) {
      return;
    }
    widget.onSaved(png.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          key: _canvasKey,
          height: widget.height,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: Radii.cardRadius,
            border: Border.all(color: c.stroke, width: Strokes.thin),
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                onPanStart: (DragStartDetails d) => _start(d.localPosition),
                onPanUpdate: (DragUpdateDetails d) => _extend(d.localPosition),
                child: CustomPaint(
                  painter: _SignaturePainter(
                    strokes: _strokes,
                    color: c.textPrimary,
                    strokeWidth: widget.strokeWidth,
                  ),
                  child: _isEmpty && widget.hint != null
                      ? Center(
                          child: Text(
                            widget.hint!,
                            style: context.text.body13.copyWith(color: c.textDisabled),
                          ),
                        )
                      : const SizedBox.expand(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Spacing.s15),
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton.secondary(
                label: widget.clearLabel,
                onPressed: _isEmpty ? null : _clear,
              ),
            ),
            const SizedBox(width: Spacing.s10),
            Expanded(
              child: AppButton.primary(
                label: widget.saveLabel,
                onPressed: _isEmpty ? null : () => unawaited(_save()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter({required this.strokes, required this.color, required this.strokeWidth});

  final List<List<Offset>> strokes;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final List<Offset> stroke in strokes) {
      if (stroke.length < 2) {
        if (stroke.length == 1) {
          canvas.drawPoints(ui.PointMode.points, stroke, paint);
        }
        continue;
      }
      final Path path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) =>
      old.strokes != strokes || old.color != color || old.strokeWidth != strokeWidth;
}
