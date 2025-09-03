import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/supabase_service.dart';

class CropDiagnosisScreen extends ConsumerStatefulWidget {
  const CropDiagnosisScreen({super.key});

  @override
  ConsumerState<CropDiagnosisScreen> createState() =>
      _CropDiagnosisScreenState();
}

class _CropDiagnosisScreenState extends ConsumerState<CropDiagnosisScreen> {
  final _cropController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _diagnosisResult;

  final List<String> _commonCrops = [
    'Rice',
    'Wheat',
    'Cotton',
    'Sugarcane',
    'Soybean',
    'Corn',
    'Tomato',
    'Potato',
    'Onion',
    'Chili',
    'Brinjal',
    'Okra',
    'Groundnut',
    'Sunflower',
  ];

  @override
  void dispose() {
    _cropController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _analyzeCrop() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAnalyzing = true;
      _diagnosisResult = null;
    });

    try {
      final cropName = _cropController.text.trim();
      final symptoms = _symptomsController.text.trim();
      final imageDescription = _selectedImage != null
          ? 'Image provided showing crop symptoms'
          : null;

      final result = await GeminiAIService.diagnoseCrop(
        cropName,
        symptoms,
        imageDescription,
      );

      // Save diagnosis to Supabase
      await _saveDiagnosisToDatabase(result);

      setState(() {
        _diagnosisResult = result;
      });

      _showSuccessSnackBar('Crop analysis completed successfully!');
    } catch (e) {
      _showErrorSnackBar('Error analyzing crop: $e');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _saveDiagnosisToDatabase(Map<String, dynamic> diagnosis) async {
    try {
      await SupabaseService.client.from('crop_diagnosis').insert({
        'symptoms': _symptomsController.text.trim(),
        'diagnosis': diagnosis['diagnosis'],
        'treatment_recommendations': diagnosis['treatment'].toString(),
        'confidence_score': double.tryParse(diagnosis['confidence'] ?? '0'),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving diagnosis: $e');
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Add Photo', style: KrushakTextStyles.heading3),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _ImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KrushakColors.background,
      appBar: AppBar(
        title: Text(
          'Crop Diagnosis',
          style: KrushakTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: KrushakColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              _buildInputSection(),
              const SizedBox(height: 20),
              _buildImageSection(),
              const SizedBox(height: 30),
              _buildAnalyzeButton(),
              if (_diagnosisResult != null) ...[
                const SizedBox(height: 30),
                _buildResultsSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KrushakColors.primary.withOpacity(0.1),
            KrushakColors.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KrushakColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KrushakColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.biotech, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI-Powered Crop Analysis',
                  style: KrushakTextStyles.heading3,
                ),
                const SizedBox(height: 4),
                Text(
                  'Get instant diagnosis and treatment recommendations',
                  style: KrushakTextStyles.body.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Crop Information', style: KrushakTextStyles.heading3),
        const SizedBox(height: 16),

        // Crop Name Input
        Text('Crop Name', style: KrushakTextStyles.subheading),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _cropController.text.isEmpty ? null : _cropController.text,
          decoration: InputDecoration(
            hintText: 'Select or type crop name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: KrushakColors.primary),
            ),
            prefixIcon: const Icon(Icons.agriculture),
          ),
          items: _commonCrops
              .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              _cropController.text = value;
            }
          },
          validator: (value) {
            if (_cropController.text.isEmpty) {
              return 'Please select or enter crop name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Custom crop name input
        TextFormField(
          controller: _cropController,
          decoration: InputDecoration(
            labelText: 'Or type custom crop name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: KrushakColors.primary),
            ),
            prefixIcon: const Icon(Icons.edit),
          ),
        ),
        const SizedBox(height: 20),

        // Symptoms Input
        Text('Symptoms Description', style: KrushakTextStyles.subheading),
        const SizedBox(height: 8),
        TextFormField(
          controller: _symptomsController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText:
                'Describe the symptoms you observe (e.g., yellow leaves, spots, wilting, etc.)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: KrushakColors.primary),
            ),
            prefixIcon: const Icon(Icons.description),
          ),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Please describe the symptoms';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photo (Optional)', style: KrushakTextStyles.subheading),
        const SizedBox(height: 8),
        if (_selectedImage != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GestureDetector(
            onTap: _showImagePickerBottomSheet,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
                color: Colors.grey[50],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Add Photo',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to capture or select image',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _analyzeCrop,
        style: ElevatedButton.styleFrom(
          backgroundColor: KrushakColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isAnalyzing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Analyzing...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Text(
                'Analyze Crop',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildResultsSection() {
    final result = _diagnosisResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Diagnosis Results', style: KrushakTextStyles.heading2),
        const SizedBox(height: 16),

        // Diagnosis Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.medical_services, color: KrushakColors.primary),
                  const SizedBox(width: 8),
                  Text('Diagnosis', style: KrushakTextStyles.heading3),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                result['diagnosis'] ?? 'Unknown condition',
                style: KrushakTextStyles.subheading.copyWith(
                  color: KrushakColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result['description'] ?? 'No description available',
                style: KrushakTextStyles.body,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(
                        result['severity'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Severity: ${result['severity'] ?? 'Unknown'}',
                      style: TextStyle(
                        color: _getSeverityColor(result['severity']),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: KrushakColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Confidence: ${result['confidence'] ?? '0'}%',
                      style: TextStyle(
                        color: KrushakColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Treatment Recommendations
        if (result['treatment'] != null)
          _buildTreatmentSection(result['treatment']),

        const SizedBox(height: 16),

        // Additional Information
        if (result['timeline'] != null || result['cost_estimate'] != null)
          _buildAdditionalInfoSection(result),
      ],
    );
  }

  Widget _buildTreatmentSection(Map<String, dynamic> treatment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.healing, color: KrushakColors.secondary),
              const SizedBox(width: 8),
              Text(
                'Treatment Recommendations',
                style: KrushakTextStyles.heading3,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (treatment['immediate_actions'] != null)
            _buildTreatmentSubSection(
              'Immediate Actions',
              treatment['immediate_actions'],
              Icons.warning,
            ),

          if (treatment['organic_solutions'] != null)
            _buildTreatmentSubSection(
              'Organic Solutions',
              treatment['organic_solutions'],
              Icons.eco,
            ),

          if (treatment['chemical_solutions'] != null)
            _buildTreatmentSubSection(
              'Chemical Solutions',
              treatment['chemical_solutions'],
              Icons.science,
            ),

          if (treatment['preventive_measures'] != null)
            _buildTreatmentSubSection(
              'Preventive Measures',
              treatment['preventive_measures'],
              Icons.shield,
            ),
        ],
      ),
    );
  }

  Widget _buildTreatmentSubSection(
    String title,
    List<dynamic> items,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(title, style: KrushakTextStyles.subheading),
            ],
          ),
          const SizedBox(height: 8),
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 26, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: KrushakColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.toString(),
                          style: KrushakTextStyles.body,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(Map<String, dynamic> result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Additional Information', style: KrushakTextStyles.heading3),
          const SizedBox(height: 12),

          if (result['timeline'] != null)
            _buildInfoRow(
              'Recovery Timeline',
              result['timeline'],
              Icons.schedule,
            ),

          if (result['cost_estimate'] != null)
            _buildInfoRow(
              'Estimated Cost',
              result['cost_estimate'],
              Icons.currency_rupee,
            ),

          if (result['expert_tips'] != null && result['expert_tips'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.lightbulb, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text('Expert Tips', style: KrushakTextStyles.subheading),
                  ],
                ),
                const SizedBox(height: 8),
                ...result['expert_tips']
                    .map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(left: 26, bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: KrushakColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip.toString(),
                                style: KrushakTextStyles.body.copyWith(
                                  color: KrushakColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: KrushakTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value, style: KrushakTextStyles.body)),
        ],
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: KrushakColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KrushakColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: KrushakColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: KrushakColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
