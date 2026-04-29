import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageCropDialog extends StatefulWidget {
  final Uint8List imageBytes;
  const ImageCropDialog({super.key, required this.imageBytes});

  @override
  State<ImageCropDialog> createState() => _ImageCropDialogState();
}

class _ImageCropDialogState extends State<ImageCropDialog>
    with SingleTickerProviderStateMixin {
  static const Color brandYellow = Color(0xFFFFC21C);
  static const Color textBlack = Color(0xFF000000);
  static const double elementBorder = 2.0;
  static const double thickBorder = 2.5;
  static const double _cropSize = 260.0;

  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _previousOffset = Offset.zero;
  double _previousScale = 1.0;
  Offset _focalPoint = Offset.zero;

  bool _imageLoaded = false;
  bool _isSaving = false;
  double _imageAspectRatio = 1.0;

  final GlobalKey _repaintKey = GlobalKey();

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _imageAspectRatio = frame.image.width / frame.image.height;
      _imageLoaded = true;
      _fitImageToCrop();
    });
  }

  void _fitImageToCrop() {
    if (_imageAspectRatio >= 1.0) {
      final h = _cropSize / _imageAspectRatio;
      _scale = (_cropSize / h).clamp(1.0, 5.0);
    } else {
      _scale = 1.0;
    }
    _offset = Offset.zero;
  }

  double get _minScale => 1.0;
  double get _maxScale => 5.0;

  void _onScaleStart(ScaleStartDetails d) {
    _previousOffset = _offset;
    _previousScale = _scale;
    _focalPoint = d.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      final newScale = (_previousScale * d.scale).clamp(_minScale, _maxScale);
      final focalDelta = d.localFocalPoint - _focalPoint;
      final scaleDelta = newScale / _previousScale;
      _offset = ((_previousOffset - _focalPoint) * scaleDelta +
          _focalPoint +
          focalDelta);
      _scale = newScale;
      _clampOffset();
    });
  }

  void _onScaleEnd(ScaleEndDetails d) => _clampOffset();

  void _clampOffset() {
    const r = _cropSize / 2;
    final maxDx = (_cropSize * _scale / 2 - r).abs();
    final maxDy = ((_cropSize / _imageAspectRatio) * _scale / 2 - r).abs();
    _offset = Offset(
      _offset.dx.clamp(-maxDx, maxDx),
      _offset.dy.clamp(-maxDy, maxDy),
    );
  }

  Future<Uint8List?> _cropImage() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: textBlack, width: thickBorder),
            boxShadow: const [
              BoxShadow(color: textBlack, offset: Offset(6, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ── YELLOW HEADER BAR ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                decoration: const BoxDecoration(
                  color: brandYellow,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  border: Border(
                    bottom: BorderSide(color: textBlack, width: elementBorder),
                  ),
                ),
                child: Text(
                  'CROP PHOTO',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: textBlack,
                    letterSpacing: 2.5,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── CROP CIRCLE ──
              _imageLoaded
                  ? Container(
                      width: _cropSize + 6,
                      height: _cropSize + 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: textBlack, width: thickBorder),
                        boxShadow: const [
                          BoxShadow(
                              color: textBlack, offset: Offset(0, 6)),
                        ],
                      ),
                      child: ClipOval(
                        child: GestureDetector(
                          onScaleStart: _onScaleStart,
                          onScaleUpdate: _onScaleUpdate,
                          onScaleEnd: _onScaleEnd,
                          child: SizedBox(
                            width: _cropSize,
                            height: _cropSize,
                            child: RepaintBoundary(
                              key: _repaintKey,
                              child: OverflowBox(
                                minWidth: 0,
                                minHeight: 0,
                                maxWidth: double.infinity,
                                maxHeight: double.infinity,
                                child: Transform.translate(
                                  offset: _offset,
                                  child: Transform.scale(
                                    scale: _scale,
                                    child: SizedBox(
                                      width: _cropSize,
                                      height:
                                          _cropSize / _imageAspectRatio,
                                      child: Image.memory(
                                        widget.imageBytes,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: _cropSize + 6,
                      height: _cropSize + 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: textBlack, width: thickBorder),
                        color: brandYellow.withValues(alpha: 0.3),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: textBlack),
                      ),
                    ),

              const SizedBox(height: 20),

              // ── HINT TEXT ──
              Text(
                'Pinch to zoom  ·  Drag to reposition',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textBlack.withValues(alpha: 0.35),
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 24),

              // ── BUTTONS ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, null),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: textBlack, width: elementBorder),
                            boxShadow: const [
                              BoxShadow(
                                  color: textBlack,
                                  offset: Offset(0, 4)),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textBlack,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Done
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          setState(() => _isSaving = true);
                          final cropped = await _cropImage();
                          navigator.pop(cropped);
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: brandYellow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: textBlack, width: elementBorder),
                            boxShadow: const [
                              BoxShadow(
                                  color: textBlack,
                                  offset: Offset(0, 4)),
                            ],
                          ),
                          child: Center(
                            child: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: textBlack,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Done',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: textBlack,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}