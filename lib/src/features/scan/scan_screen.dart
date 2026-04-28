import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:neuroaid/src/core/services/scan_service.dart';
import 'package:neuroaid/src/features/scan/CornerMarkerWidget.dart';
import 'package:neuroaid/src/features/scan/buildSourceButton.dart';

enum ScanType { brain, face, hand }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  ScanType? _scanType;
  final ScanService _scanService = GetIt.instance<ScanService>();

  // ── helpers ──────────────────────────────────────────────────────────────

  IconData _iconForType(ScanType? type) {
    switch (type) {
      case ScanType.face:
        return FontAwesomeIcons.faceSmile;
      case ScanType.hand:
        return FontAwesomeIcons.hand;
      case ScanType.brain:
      default:
        return FontAwesomeIcons.camera;
    }
  }

  String _labelForType(ScanType? type) {
    switch (type) {
      case ScanType.face:
        return 'Face Scan';
      case ScanType.hand:
        return 'Hand Scan';
      case ScanType.brain:
        return 'Brain Scan';
      default:
        return 'Tap to Scan';
    }
  }

  // ── image picking ─────────────────────────────────────────────────────────

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      if (image != null) setState(() => _selectedImage = File(image.path));
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (image != null) setState(() => _selectedImage = File(image.path));
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    }
  }

  // ── upload ────────────────────────────────────────────────────────────────

  Future<void> _uploadScan() async {
    if (_selectedImage == null) {
      _showSnack('Please select an image first', Colors.orange);
      return;
    }
    if (_scanType == null) {
      _showSnack('Please select a scan type first', Colors.orange);
      return;
    }

    setState(() => _isUploading = true);

    try {
      Map<String, dynamic> result;
      switch (_scanType!) {
        case ScanType.face:
          result = await _scanService.uploadFaceScan(_selectedImage!);
          break;
        case ScanType.hand:
          result = await _scanService.uploadHandScan(_selectedImage!);
          break;
        case ScanType.brain:
          result = await _scanService.uploadScan(_selectedImage!);
          result['scan_type'] = 'brain';
          break;
      }

      if (mounted) {
        setState(() => _isUploading = false);
        _showResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        _showSnack('Upload failed: $e', Colors.red);
      }
    }
  }

  // ── dialogs ───────────────────────────────────────────────────────────────

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  void _showScanTypeDialog() {
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
                'Select Scan Type',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose which part to analyze',
                style: TextStyle(fontSize: 13, color: Colors.black45),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildTypeButton(icon: FontAwesomeIcons.brain, label: 'Brain', emoji: '🧠', type: ScanType.brain)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTypeButton(icon: FontAwesomeIcons.faceSmile, label: 'Face', emoji: '😊', type: ScanType.face)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTypeButton(icon: FontAwesomeIcons.hand, label: 'Hand', emoji: '✋', type: ScanType.hand)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required IconData icon,
    required String label,
    required String emoji,
    required ScanType type,
  }) {
    final bool selected = _scanType == type;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _scanType = type;
          _selectedImage = null;
        });
        _showImageSourceDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0E7772)
              : const Color(0xFF0E7772).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0E7772),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF0E7772),
              ),
            ),
          ],
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

  void _showResultDialog(Map<String, dynamic> result) {
    final String scanType = result['scan_type'] as String? ?? 'brain';
    final rawResult = result['result'] as String? ?? 'UNKNOWN';
    final bool isStroke = rawResult.toUpperCase() == 'STROKE';
    final bool isNormal =
        rawResult.toUpperCase() == 'NORMAL' || rawResult.toUpperCase() == 'NO STROKE';

    // confidence may come as double or String
    final dynamic rawConf = result['confidence'];
    double displayConfidence = 0;
    if (rawConf is double) {
      displayConfidence = rawConf;
    } else if (rawConf is int) {
      displayConfidence = rawConf.toDouble();
    } else if (rawConf is String) {
      displayConfidence =
          double.tryParse(rawConf.replaceAll('%', '').trim()) ?? 0;
    }

    final IconData resultIcon = isStroke
        ? FontAwesomeIcons.triangleExclamation
        : isNormal
            ? FontAwesomeIcons.circleCheck
            : FontAwesomeIcons.circleQuestion;
    final Color resultColor =
        isStroke ? Colors.red : isNormal ? Colors.green : Colors.grey;

    String resultTitle;
    String resultSubtitle;
    if (isStroke) {
      resultTitle = 'Stroke Detected';
      resultSubtitle = 'تم اكتشاف سكتة دماغية';
    } else if (isNormal) {
      resultTitle = 'Normal Result';
      resultSubtitle = 'نتيجة طبيعية';
    } else {
      resultTitle = 'Analysis Failed';
      resultSubtitle = 'فشل التحليل';
    }

    final List<dynamic> issues = result['issues'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(resultIcon, size: 50, color: resultColor),
                const SizedBox(height: 12),
                Text(
                  resultTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  resultSubtitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: resultColor.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Confidence: ${displayConfidence.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                if (result['stroke_score'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Stroke Score: ${result['stroke_score']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: resultColor,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // ── type-specific details ──────────────────────────────────
                if (scanType == 'brain') _buildBrainDetails(result),
                if (scanType == 'face') _buildFaceDetails(result),
                if (scanType == 'hand') _buildHandDetails(result),

                // ── issues / findings ──────────────────────────────────────
                if (issues.isNotEmpty || (scanType == 'brain' && result['risk_category'] == null))
                  Container(
                    width: double.infinity,
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
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (issues.isNotEmpty)
                          ...issues.map(
                            (issue) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ',
                                      style: TextStyle(fontSize: 14)),
                                  Expanded(
                                    child: Text(
                                      issue.toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._brainFindings(isStroke, isNormal).map(
                            (f) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ',
                                      style: TextStyle(fontSize: 14)),
                                  Expanded(
                                    child: Text(
                                      f,
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

                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E7772).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(_iconForType(_scanType),
                          size: 11, color: const Color(0xFF0E7772)),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          result['model'] ?? 'AI Model',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF0E7772),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                        _scanType = null;
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

  Widget _buildBrainDetails(Map<String, dynamic> result) {
    final String riskCategory = result['risk_category'] as String? ?? '';
    final dynamic prob = result['stroke_probability'];
    final String rawResult = result['raw_result'] as String? ?? '';

    if (riskCategory.isEmpty && prob == null) return const SizedBox.shrink();

    final bool isHighRisk = riskCategory.toLowerCase().contains('high');
    final Color riskColor = isHighRisk ? Colors.red : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Brain Scan Analysis',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent),
            ),
            if (rawResult.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Diagnosis: $rawResult',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
            if (riskCategory.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Risk Category: ',
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  Text(
                    riskCategory,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: riskColor),
                  ),
                ],
              ),
            ],
            if (prob != null) ...[
              const SizedBox(height: 4),
              Text(
                'Stroke Probability: $prob%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: riskColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFaceDetails(Map<String, dynamic> result) {
    final String reason = result['reason'] as String? ?? '';
    final Map<String, dynamic> metrics =
        (result['metrics'] as Map?)?.cast<String, dynamic>() ?? {};

    if (reason.isEmpty && metrics.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Face Analysis',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange),
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Reason: $reason',
                  style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ],
            if (metrics.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...metrics.entries.map(
                (e) => Text(
                  '${_formatMetricKey(e.key)}: ${e.value}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHandDetails(Map<String, dynamic> result) {
    final int leftFingers = result['left_fingers'] as int? ?? 0;
    final int rightFingers = result['right_fingers'] as int? ?? 0;
    final int fingerDiff = result['finger_diff'] as int? ?? 0;
    final bool leftOpen = result['left_is_open'] as bool? ?? false;
    final bool rightOpen = result['right_is_open'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hand Analysis',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _handStat('✋ Left', '$leftFingers fingers',
                    leftOpen ? 'Open' : 'Closed'),
                _handStat('🤚 Right', '$rightFingers fingers',
                    rightOpen ? 'Open' : 'Closed'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Finger Difference: $fingerDiff',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fingerDiff > 1 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _handStat(String title, String fingers, String state) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 2),
        Text(fingers,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
        Text(state,
            style: const TextStyle(fontSize: 12, color: Colors.black45)),
      ],
    );
  }

  List<String> _brainFindings(bool isStroke, bool isNormal) {
    if (isStroke) {
      return [
        'Signs of stroke detected in the scan',
        'Immediate medical attention recommended',
        'Please consult with a neurologist',
      ];
    } else if (isNormal) {
      return [
        'No signs of stroke detected',
        'Brain scan appears normal',
        'Continue regular health monitoring',
      ];
    }
    return [
      'Unable to analyze the image',
      'Please try again with a clearer image',
    ];
  }

  String _formatMetricKey(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ')
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  // ── pill button ───────────────────────────────────────────────────────────

  Widget _buildScanPillButton() {
    final bool hasType = _scanType != null;
    return GestureDetector(
      onTap: _showScanTypeDialog,
      child: Container(
        width: 140,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF0E7772),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  _iconForType(_scanType),
                  color: const Color(0xFF0E7772),
                  size: 28,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Text(
                hasType
                    ? (_selectedImage != null
                        ? 'Image Selected'
                        : _labelForType(_scanType))
                    : 'Tap to Scan',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

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
                    icon: const FaIcon(FontAwesomeIcons.arrowRotateLeft,
                        size: 16, color: Colors.white),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.scissors,
                        size: 16, color: Colors.white),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.xmark,
                        size: 16, color: Colors.white),
                    onPressed: () => setState(() => _selectedImage = null),
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
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(
                                      _iconForType(_scanType),
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _scanType != null
                                          ? 'Ready for ${_labelForType(_scanType)}'
                                          : 'No image selected',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildScanPillButton(),
                    const SizedBox(height: 16),
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
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
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
          if (_isUploading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Analyzing ${_labelForType(_scanType)}...',
                      style: const TextStyle(
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
