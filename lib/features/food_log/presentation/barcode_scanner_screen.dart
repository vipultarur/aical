import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/services/gemini_service.dart';
import 'package:calcount/core/services/local_storage_service.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/features/food_log/models/food_search_item.dart';
import 'package:calcount/common/widgets/app_snack_bar.dart';

enum ScannerMode {
  barcode,
  photo,
  ingredients,
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  // Real Camera Properties
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;

  // Barcode scanner
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isScanningBarcode = false;

  ScannerMode _selectedMode = ScannerMode.photo;
  bool _isTorchOn = false;
  double _zoomLevel = 1.0;
  bool _isCapturing = false;
  double _captureOpacity = 0.0;
  bool _isProcessing = false; // Shows AI processing overlay
  String _processingMessage = '';

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );

    _initializeRealCamera();
  }

  @override
  void dispose() {
    _laserController.dispose();
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  Future<void> _initializeRealCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final backCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      // Fall back to grid viewfinder
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) {
      setState(() => _isTorchOn = !_isTorchOn);
      return;
    }
    try {
      final next = !_isTorchOn;
      await _cameraController!.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (!mounted) return;
      setState(() => _isTorchOn = next);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTorchOn = !_isTorchOn);
    }
  }

  Future<void> _toggleZoom() async {
    final next = _zoomLevel == 1.0 ? 2.0 : 1.0;
    if (_cameraController != null && _isCameraInitialized) {
      try {
        await _cameraController!.setZoomLevel(next);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() => _zoomLevel = next);
  }

  // ─────────────────────── Gallery Import ──────────────────────────────────

  Future<void> _pickImageFromGallery() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      final bytes = await File(picked.path).readAsBytes();

      switch (_selectedMode) {
        case ScannerMode.barcode:
          _processBarcodeScanFromFile(picked.path);
          break;
        case ScannerMode.photo:
          _processWithAI(bytes, 'photo');
          break;
        case ScannerMode.ingredients:
          _processWithAI(bytes, 'ingredients');
          break;
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Could not open gallery',
        type: AppSnackBarType.error,
      );
    }
  }

  // ─────────────────────── Shutter Capture ─────────────────────────────────

  Future<void> _captureAndProcess() async {
    if (_isProcessing) return;

    // Flash animation
    setState(() {
      _isCapturing = true;
      _captureOpacity = 1.0;
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() => _captureOpacity = 0.0);
    });

    XFile? capturedFile;
    if (_cameraController != null && _isCameraInitialized) {
      try {
        capturedFile = await _cameraController!.takePicture();
      } catch (e) {
        // Continue even if capture fails
      }
    }

    Future.delayed(const Duration(milliseconds: 200), () async {
      if (!mounted) return;
      setState(() => _isCapturing = false);

      if (capturedFile == null) {
        AppSnackBar.show(
          context,
          message: 'Camera capture failed. Try again.',
          type: AppSnackBarType.error,
        );
        return;
      }

      final bytes = await File(capturedFile.path).readAsBytes();

      switch (_selectedMode) {
        case ScannerMode.barcode:
          _processBarcodeScanFromFile(capturedFile.path);
          break;
        case ScannerMode.photo:
          _processWithAI(bytes, 'photo');
          break;
        case ScannerMode.ingredients:
          _processWithAI(bytes, 'ingredients');
          break;
      }
    });
  }

  // ─────────────────────── Barcode Processing ─────────────────────────────

  Future<void> _processBarcodeScanFromFile(String filePath) async {
    if (_isScanningBarcode || _isProcessing) return;
    setState(() {
      _isScanningBarcode = true;
      _isProcessing = true;
      _processingMessage = 'Scanning barcode...';
    });

    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isScanningBarcode = false;
          _isProcessing = false;
        });
        AppSnackBar.show(
          context,
          message: 'No barcode found. Try again.',
          type: AppSnackBarType.error,
        );
        return;
      }

      final barcodeValue = barcodes.first.rawValue ?? '';
      if (barcodeValue.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isScanningBarcode = false;
          _isProcessing = false;
        });
        AppSnackBar.show(
          context,
          message: 'Could not read barcode value.',
          type: AppSnackBarType.error,
        );
        return;
      }

      if (!mounted) return;
      setState(() => _processingMessage = 'Looking up barcode: $barcodeValue...');

      // Look up barcode via Gemini AI
      final foodItem = await GeminiService.lookupBarcode(barcodeValue);

      if (!mounted) return;
      setState(() {
        _isScanningBarcode = false;
        _isProcessing = false;
      });

      if (foodItem != null) {
        // Save to custom foods
        await LocalStorageService.addCustomFood(foodItem);
        _navigateToFoodDetail(foodItem);
      } else {
        AppSnackBar.show(
          context,
          message: 'Could not identify product. Try again.',
          type: AppSnackBarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanningBarcode = false;
        _isProcessing = false;
      });
      AppSnackBar.show(
        context,
        message: 'Barcode scan error. Please try again.',
        type: AppSnackBarType.error,
      );
    }
  }

  // ─────────────────────── AI Photo Processing ────────────────────────────

  Future<void> _processWithAI(List<int> imageBytes, String mode) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _processingMessage = mode == 'photo'
          ? 'Analyzing food with AI...'
          : 'Reading ingredients label...';
    });

    try {
      final bytes = Uint8List.fromList(imageBytes);

      FoodSearchItem? result;
      if (mode == 'photo') {
        result = await GeminiService.analyzeFoodPhoto(bytes);
      } else {
        result = await GeminiService.analyzeIngredientsPhoto(bytes);
      }

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (result != null) {
        // Save to custom foods
        await LocalStorageService.addCustomFood(result);
        _navigateToFoodDetail(result);
      } else {
        AppSnackBar.show(
          context,
          message: 'Could not analyze image. Try a clearer photo.',
          type: AppSnackBarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      AppSnackBar.show(
        context,
        message: 'AI analysis failed. Please try again.',
        type: AppSnackBarType.error,
      );
    }
  }

  void _navigateToFoodDetail(FoodSearchItem food) {
    AppSnackBar.show(
      context,
      message: 'Found: ${food.name}',
      type: AppSnackBarType.success,
    );
    context.pushReplacement(
      AppRoutes.foodDetail('scanned_item'),
      extra: food,
    );
  }

  // ─────────────────────── BUILD ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview or Grid fallback
          Positioned.fill(
            child: _isCameraInitialized && _cameraController != null
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize?.height ?? size.width,
                      height: _cameraController!.value.previewSize?.width ?? size.height,
                      child: CameraPreview(_cameraController!),
                    ),
                  )
                : CustomPaint(
                    size: Size(size.width, size.height),
                    painter: _CameraGridPainter(),
                  ),
          ),

          // 2. Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          // 3. Viewfinder brackets
          Center(child: _buildCameraViewfinder()),

          // 4. Header
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left, color: Colors.white, size: 26),
                  ),
                ),
                Text(
                  'Scan food',
                  style: AppTypography.headingMd(color: Colors.white).copyWith(
                    fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 0.3,
                  ),
                ),
                GestureDetector(
                  onTap: _toggleFlash,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isTorchOn ? LucideIcons.zap : LucideIcons.zapOff,
                      color: _isTorchOn ? Colors.yellow : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. Instruction banner
          Positioned(
            bottom: 170, left: 32, right: 32,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getModeInstructionText(),
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // 6. Capture controls
          Positioned(
            bottom: 76, left: 0, right: 0,
            child: _buildCaptureControlBar(),
          ),

          // 7. Mode tabs
          Positioned(
            bottom: 12, left: 0, right: 0,
            child: SafeArea(top: false, child: _buildModeTabBar()),
          ),

          // 8. Flash effect
          if (_isCapturing)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _captureOpacity,
                duration: const Duration(milliseconds: 150),
                child: Container(color: Colors.white),
              ),
            ),

          // 9. AI Processing Overlay
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 48, height: 48,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D4ED8)),
                          strokeWidth: 3,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _processingMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please wait...',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getModeInstructionText() {
    switch (_selectedMode) {
      case ScannerMode.barcode:
        return 'Align package barcode inside the red laser bracket';
      case ScannerMode.photo:
        return 'Center your plate inside the camera frame to auto-detect';
      case ScannerMode.ingredients:
        return 'Fit nutrition facts or ingredient list in the scanning box';
    }
  }

  Widget _buildCameraViewfinder() {
    double width, height;
    switch (_selectedMode) {
      case ScannerMode.barcode:
        width = 280; height = 160; break;
      case ScannerMode.photo:
        width = 300; height = 300; break;
      case ScannerMode.ingredients:
        width = 260; height = 360; break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      width: width, height: height,
      child: Stack(
        children: [
          _buildCameraBracket(width: width, height: height),
          if (_selectedMode == ScannerMode.barcode)
            AnimatedBuilder(
              animation: _laserAnimation,
              builder: (context, child) {
                return Positioned(
                  top: height * _laserAnimation.value,
                  left: 20, right: 20,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.8),
                          blurRadius: 8, spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (_selectedMode == ScannerMode.ingredients)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [
                        Colors.greenAccent.withValues(alpha: 0.01),
                        Colors.greenAccent.withValues(alpha: 0.08),
                        Colors.greenAccent.withValues(alpha: 0.01),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraBracket({required double width, required double height}) {
    const double borderSize = 48.0;
    const double strokeWidth = 3.5;
    final bracketColor = Colors.white.withValues(alpha: 0.75);

    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _cornerBox(bracketColor, strokeWidth, borderSize, topLeft: true)),
        Positioned(top: 0, right: 0, child: _cornerBox(bracketColor, strokeWidth, borderSize, topRight: true)),
        Positioned(bottom: 0, left: 0, child: _cornerBox(bracketColor, strokeWidth, borderSize, bottomLeft: true)),
        Positioned(bottom: 0, right: 0, child: _cornerBox(bracketColor, strokeWidth, borderSize, bottomRight: true)),
      ],
    );
  }

  Widget _cornerBox(Color color, double stroke, double size, {
    bool topLeft = false, bool topRight = false,
    bool bottomLeft = false, bool bottomRight = false,
  }) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        border: Border(
          top: (topLeft || topRight) ? BorderSide(color: color, width: stroke) : BorderSide.none,
          bottom: (bottomLeft || bottomRight) ? BorderSide(color: color, width: stroke) : BorderSide.none,
          left: (topLeft || bottomLeft) ? BorderSide(color: color, width: stroke) : BorderSide.none,
          right: (topRight || bottomRight) ? BorderSide(color: color, width: stroke) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: topLeft ? const Radius.circular(24) : Radius.zero,
          topRight: topRight ? const Radius.circular(24) : Radius.zero,
          bottomLeft: bottomLeft ? const Radius.circular(24) : Radius.zero,
          bottomRight: bottomRight ? const Radius.circular(24) : Radius.zero,
        ),
      ),
    );
  }

  Widget _buildCaptureControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _pickImageFromGallery,
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
              ),
              child: const Center(child: Icon(Icons.image_outlined, color: Colors.white, size: 26)),
            ),
          ),
          GestureDetector(
            onTap: _captureAndProcess,
            child: Container(
              width: 76, height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleZoom,
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
              ),
              child: Center(
                child: Text(
                  '${_zoomLevel.toStringAsFixed(1)}x',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ScannerMode.values.map((mode) {
        final isSelected = _selectedMode == mode;
        String text;
        switch (mode) {
          case ScannerMode.barcode: text = 'Barcode'; break;
          case ScannerMode.photo: text = 'Food photo'; break;
          case ScannerMode.ingredients: text = 'Ingredients'; break;
        }

        return GestureDetector(
          onTap: () => setState(() => _selectedMode = mode),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text, style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                  fontSize: 14,
                )),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 3.5, width: isSelected ? 20 : 0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D4ED8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const gridCountY = 24;
    final dy = size.height / gridCountY;
    for (var i = 0; i < gridCountY; i++) {
      canvas.drawLine(Offset(0, i * dy), Offset(size.width, i * dy), paint);
    }

    const gridCountX = 12;
    final dx = size.width / gridCountX;
    for (var i = 0; i < gridCountX; i++) {
      canvas.drawLine(Offset(i * dx, 0), Offset(i * dx, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
