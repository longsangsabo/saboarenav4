import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sabo_arena/theme/app_theme.dart';

class QRAttendanceScanner extends StatefulWidget {
  final Function(Map<String, dynamic>) onScanResult;
  
  const QRAttendanceScanner({
    super.key,
    required this.onScanResult,
  });

  @override
  State<QRAttendanceScanner> createState() => _QRAttendanceScannerState();
}

class _QRAttendanceScannerState extends State<QRAttendanceScanner> {
  MobileScannerController controller = MobileScannerController();
  
  bool isScanning = true;
  bool isProcessing = false;
  String? errorMessage;
  bool flashOn = false;
  
  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isDenied) {
        setState(() {
          errorMessage = 'Cần cấp quyền camera để quét QR code';
        });
      }
    }
  }

  Future<void> _handleScanResult(String qrData) async {
    if (isProcessing) return;
    
    setState(() {
      isProcessing = true;
      isScanning = false;
      errorMessage = null;
    });

    try {
      // Simple verification - in a real app, you'd call an attendance service
      final verificationResult = await _verifyAttendanceQR(qrData);
      
      if (verificationResult['success']) {
        // Stop scanning and return result
        widget.onScanResult(verificationResult);
      } else {
        setState(() {
          errorMessage = verificationResult['error'] ?? 'QR code không hợp lệ';
          isProcessing = false;
        });
        
        // Resume scanning after 3 seconds
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            isScanning = true;
            errorMessage = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi quét QR: $e';
        isProcessing = false;
      });
      
      // Resume scanning after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          isScanning = true;
          errorMessage = null;
        });
      }
    }
  }

  // Mock attendance verification - replace with actual service call
  Future<Map<String, dynamic>> _verifyAttendanceQR(String qrData) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    
    try {
      // Basic QR format validation
      if (qrData.isEmpty || qrData.length < 10) {
        return {
          'success': false,
          'error': 'Mã QR không hợp lệ'
        };
      }

      // Mock successful verification
      return {
        'success': true,
        'data': {
          'qrCode': qrData,
          'timestamp': DateTime.now().toIso8601String(),
          'message': 'Chấm công thành công',
          'userId': 'user_123',
          'eventId': 'event_456',
        }
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Lỗi xác thực: $e'
      };
    }
  }

  void _toggleFlash() async {
    await controller.toggleTorch();
    setState(() {
      flashOn = !flashOn;
    });
  }

  void _flipCamera() async {
    await controller.switchCamera();
  }

  void _resumeScanning() {
    setState(() {
      isScanning = true;
      isProcessing = false;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Quét mã chấm công'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
            tooltip: 'Bật/tắt đèn flash',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: _flipCamera,
            tooltip: 'Đổi camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mobile Scanner View
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (isScanning && !isProcessing && capture.barcodes.isNotEmpty) {
                final barcode = capture.barcodes.first;
                if (barcode.rawValue != null) {
                  _handleScanResult(barcode.rawValue!);
                }
              }
            },
          ),
          
          // Scanner overlay (custom implementation)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isProcessing ? Colors.orange : 
                          isScanning ? Colors.green : Colors.red,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Corner brackets
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: isScanning ? Colors.green : Colors.red, width: 4),
                          left: BorderSide(color: isScanning ? Colors.green : Colors.red, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: isScanning ? Colors.green : Colors.red, width: 4),
                          right: BorderSide(color: isScanning ? Colors.green : Colors.red, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: isScanning ? Colors.green : Colors.red, width: 4),
                          left: BorderSide(color: isScanning ? Colors.green : Colors.red, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: isScanning ? Colors.green : Colors.red, width: 4),
                          right: BorderSide(color: isScanning ? Colors.green : Colors.red, width: 4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Instructions overlay
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đưa camera về phía mã QR chấm công',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã QR sẽ được quét tự động',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Processing overlay
          if (isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primaryLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Đang xác thực QR code...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Error message
          if (errorMessage != null)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // Bottom controls
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: flashOn ? Icons.flash_on : Icons.flash_off,
                  label: 'Đèn flash',
                  onPressed: _toggleFlash,
                ),
                _buildControlButton(
                  icon: Icons.flip_camera_ios,
                  label: 'Đổi camera',
                  onPressed: _flipCamera,
                ),
                _buildControlButton(
                  icon: Icons.refresh,
                  label: 'Quét lại',
                  onPressed: _resumeScanning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}