import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:neuroaid/src/core/services/scan_service.dart';
import 'package:neuroaid/src/features/scan/CornerMarkerWidget.dart';
import 'package:neuroaid/src/features/scan/buildSourceButton.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final ScanService _scanService = GetIt.instance<ScanService>();

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality:
            100, // NO COMPRESSION - preserve original quality for AI model
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Pill-style scan button shown at the bottom
  Widget _buildScanPillButton() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: 140,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF0E7772),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // White circular icon container
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.camera,
                  color: Color(0xFF0E7772),
                  size: 28,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Text(
                _selectedImage != null ? 'Image Selected' : 'Tap to Scan',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality:
            100, // NO COMPRESSION - preserve original quality for AI model
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadScan() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final result = await _scanService.uploadScan(_selectedImage!);

      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        // Show success dialog with result
        _showResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    // Extract AI analysis results from stroke_image model
    final String prediction = result['prediction'] ?? 'unknown';
    final String confidenceStr = result['confidence'] ?? '0%';

    // Parse confidence percentage (e.g., "95.5%" -> 95.5)
    // Display the actual confidence from the AI model without any adjustments
    final double displayConfidence =
        double.tryParse(confidenceStr.replaceAll('%', '').trim()) ?? 0.0;

    // Determine icon and color based on result
    IconData resultIcon;
    Color resultColor;
    String resultTitle;
    String resultSubtitle;
    List<String> findings = [];

    if (prediction.toLowerCase() == 'normal') {
      resultIcon = FontAwesomeIcons.circleCheck;
      resultColor = Colors.green;
      resultTitle = 'Normal Scan';
      resultSubtitle = 'نتيجة طبيعية';
      findings = [
        'No signs of stroke detected',
        'Brain scan appears normal',
        'Continue regular health monitoring',
      ];
    } else if (prediction.toLowerCase() == 'stroke') {
      resultIcon = FontAwesomeIcons.triangleExclamation;
      resultColor = Colors.red;
      resultTitle = 'Stroke Detected';
      resultSubtitle = 'تم اكتشاف سكتة دماغية';
      findings = [
        'Signs of stroke detected in the scan',
        'Immediate medical attention recommended',
        'Please consult with a neurologist',
      ];
    } else {
      resultIcon = FontAwesomeIcons.circleQuestion;
      resultColor = Colors.grey;
      resultTitle = 'Analysis Failed';
      resultSubtitle = 'فشل التحليل';
      findings = [
        'Unable to analyze the image',
        'Please try again with a clearer image',
      ];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(resultIcon, size: 60, color: resultColor),
                const SizedBox(height: 16),
                Text(
                  resultTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  resultSubtitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: resultColor.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Confidence: ${displayConfidence.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Findings:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...findings.map(
                        (finding) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Text(
                                  finding.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (result['source'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E7772).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.brain,
                          size: 12,
                          color: Color(0xFF0E7772),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AI Model: ${result['model'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF0E7772),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E7772),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildSourceButton(
                    icon: FontAwesomeIcons.camera,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                  ),
                  buildSourceButton(
                    icon: FontAwesomeIcons.images,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.chevronLeft,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Top Action Buttons (only show when image is selected)
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0E7772),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.arrowRotateLeft,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // TODO: Implement rotate left
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.scissors,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // TODO: Implement crop
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.xmark,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 40),

              // Scan Frame
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF0E7772),
                        width: 4,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Display selected image or placeholder
                          if (_selectedImage != null)
                            Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          else
                            Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.camera,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No image selected',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Corner Markers
                          CornerMarkerWidget(Alignment.topLeft),
                          CornerMarkerWidget(Alignment.topRight),
                          CornerMarkerWidget(Alignment.bottomLeft),
                          CornerMarkerWidget(Alignment.bottomRight),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Bottom Section with Scan Pill Button
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildScanPillButton(),

                    const SizedBox(height: 16),

                    // Upload Button (only show when image is selected)
                    if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUploading ? null : _uploadScan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E7772),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: _isUploading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Upload Scan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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

          // Full screen loading overlay
          if (_isUploading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Uploading scan...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
