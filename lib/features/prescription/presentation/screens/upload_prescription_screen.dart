import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';

class UploadPrescriptionScreen extends StatefulWidget {
  const UploadPrescriptionScreen({super.key});

  @override
  State<UploadPrescriptionScreen> createState() => _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState extends State<UploadPrescriptionScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80, // Compress slightly
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFEDF8F2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: Text(
          'Upload Prescription',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subtitle
              Text(
                'Upload your doctor\'s prescription. Our pharmacist will review and prepare your medicines.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Upload Dropzone
              GestureDetector(
                onTap: () {
                  if (_selectedImage == null) {
                    _pickImage(ImageSource.gallery);
                  }
                },
                child: DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    color: AppColors.divider,
                    strokeWidth: 1.5,
                    dashPattern: const [6, 4],
                    radius: const Radius.circular(24),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: _selectedImage != null ? 300 : null,
                    padding: _selectedImage != null 
                        ? EdgeInsets.zero 
                        : const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FBF9), // Very light gray-green matching UI
                      borderRadius: BorderRadius.circular(24),
                    ),
                    clipBehavior: Clip.antiAlias, // Ensures image corners clip to border-radius
                    child: _selectedImage != null
                        ? _buildImagePreview()
                        : _buildPlaceholder(),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Take Photo Outlined Button
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, color: AppColors.textPrimary, size: 20),
                  label: Text(
                    'Take Photo',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.divider, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Submit Button
              AppButton(
                label: 'Submit Prescription',
                onPressed: _selectedImage != null 
                    ? () {
                        // Submit Logic
                      } 
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Upload Icon in circle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFE2F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.upload_file_outlined,
            color: Color(0xFF2EAA58),
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to upload',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'PNG, JPG or PDF (max 10MB)',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
