import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import for displaying images from URLs

import '../../../../../core/theme/LocaleKeys.dart';

class ImagePickerSection extends StatefulWidget {
  final List<File> selectedImages; // New images chosen by user (File objects)
  final List<String> existingImageUrls; // Existing images from backend (URLs)
  final int maxImages;
  final Function(List<File>) onImagesChanged; // Callback for new images
  final Function(List<String>) onExistingImagesRemoved; // Callback for removed existing images

  const ImagePickerSection({
    super.key,
    required this.selectedImages,
    required this.existingImageUrls, // New parameter
    this.maxImages = 3,
    required this.onImagesChanged,
    required this.onExistingImagesRemoved, // New parameter
  });

  @override
  State<ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<ImagePickerSection> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    // Check if max images limit is reached
    if (widget.selectedImages.length + widget.existingImageUrls.length >= widget.maxImages) {
      _showLimitReachedSnackbar();
      return;
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final newSelectedImages = List<File>.from(widget.selectedImages)
        ..add(File(pickedFile.path));
      widget.onImagesChanged(newSelectedImages); // Notify parent about new images
    }
  }

  Future<void> _pickMultipleImages() async {
    // Check if max images limit is reached
    if (widget.selectedImages.length + widget.existingImageUrls.length >= widget.maxImages) {
      _showLimitReachedSnackbar();
      return;
    }

    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      // Calculate how many more images can be added
      final remainingSlots = widget.maxImages - (widget.selectedImages.length + widget.existingImageUrls.length);
      final imagesToAdd = pickedFiles.take(remainingSlots).map((xFile) => File(xFile.path)).toList();

      if (imagesToAdd.isEmpty && remainingSlots == 0) {
        _showLimitReachedSnackbar();
        return;
      }

      final newSelectedImages = List<File>.from(widget.selectedImages)
        ..addAll(imagesToAdd);
      widget.onImagesChanged(newSelectedImages); // Notify parent about new images
    }
  }

  void _removeSelectedImage(int index) {
    final newSelectedImages = List<File>.from(widget.selectedImages)
      ..removeAt(index);
    widget.onImagesChanged(newSelectedImages); // Notify parent about removed new image
  }

  void _removeExistingImage(int index) {
    final newExistingUrls = List<String>.from(widget.existingImageUrls)
      ..removeAt(index);
    widget.onExistingImagesRemoved(newExistingUrls); // Notify parent about removed existing image
  }

  void _showLimitReachedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.imageLimitReached.tr(args: [widget.maxImages.toString()])),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalImagesCount = widget.selectedImages.length + widget.existingImageUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LocaleKeys.choosePictures.tr(), style: Theme.of(context).textTheme.bodyMedium), // Using bodyMedium for general text
        const SizedBox(height: 10),
        Wrap(
          spacing: 10.0, // Spacing between images
          runSpacing: 10.0, // Spacing between rows of images
          children: [
            // Display existing images from URLs
            ...widget.existingImageUrls.asMap().entries.map((entry) {
              final int index = entry.key;
              final String imageUrl = entry.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 100, // Fixed size for display
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 100, height: 100, color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 100, height: 100, color: Colors.red.shade100,
                        child: const Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => _removeExistingImage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),

            // Display newly selected images (File objects)
            ...widget.selectedImages.asMap().entries.map((entry) {
              final int index = entry.key;
              final File imageFile = entry.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      imageFile,
                      width: 100, // Fixed size for display
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => _removeSelectedImage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),

            // Add button (only if maxImages limit is not reached)
            if (totalImagesCount < widget.maxImages)
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext bc) {
                      return SafeArea(
                        child: Wrap(
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: Text(LocaleKeys.photoLibrary.tr()), // Localize this
                              onTap: () {
                                _pickImage(ImageSource.gallery);
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: Text(LocaleKeys.camera.tr()), // Localize this
                              onTap: () {
                                _pickImage(ImageSource.camera);
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.image),
                              title: Text(LocaleKeys.pickMultipleImages.tr()), // Localize this
                              onTap: () {
                                _pickMultipleImages();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Icon(Icons.add_a_photo, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ],
    );
  }
}