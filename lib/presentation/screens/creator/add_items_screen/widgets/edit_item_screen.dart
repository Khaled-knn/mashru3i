// lib/features/dashboard_feature/edit_item_screen/edit_item_screen.dart
import 'dart:convert';
import 'dart:io'; // لاستخدام File
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mashrou3i/core/theme/color.dart';
import 'package:mashrou3i/presentation/screens/creator/add_items_screen/cubit/get_item_cubit.dart';
import 'package:mashrou3i/presentation/screens/creator/add_items_screen/cubit/get_item_state.dart';
import 'package:mashrou3i/presentation/widgets/compnents.dart';

import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../../data/models/items_model/creator_item_model.dart';

import '../../../../../data/models/items_model/restaurant_item_details.dart';
import '../../../../../data/models/items_model/hs_item_details.dart';
import '../../../../../data/models/items_model/hc_item_details.dart';
import '../../../../../data/models/items_model/freelancer_item_details.dart';


import '../../../../../data/models/items_model/teaching_item_details.dart';
import '../../../../widgets/coustem_form_input.dart';
import '../../../../widgets/custom_button.dart';
import '../../dashboard_screen/logic/dashboard_cibit.dart';
import '../../dashboard_screen/logic/dashboard_states.dart';
import 'extra_items_section.dart';
import 'freelancer_info_section.dart';
import 'image_picker.dart';

enum TimeUnit { minutes, hours }

class EditItemScreen extends StatefulWidget {
  final CreatorItemModel itemToEdit;

  const EditItemScreen({super.key, required this.itemToEdit});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _timeController;
  late final TextEditingController _descriptionController;

  late final TextEditingController _additionalDataController;
  late final TextEditingController _behanceLinkController;
  late final TextEditingController _driveLinkController;
  late final TextEditingController _syllabusController;



  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];

  List<Map<String, dynamic>> _extraItems = [];
  List<String> _portfolioLinks = [];

  final CancelToken _uploadCancelToken = CancelToken();
  bool _isSubmitting = false;
  bool _hasUnsavedChanges = false;

  // The profession ID for the item being edited (fixed)
  late final int _currentProfessionId;




  @override
  void initState() {
    super.initState();
    _currentProfessionId = widget.itemToEdit.categoryId!;
    _initializeControllers();
    _populateFields(widget.itemToEdit);
  }

  void _initializeControllers() {
    _nameController = TextEditingController()..addListener(_onFormChanged);
    _priceController = TextEditingController()..addListener(_onFormChanged);
    _timeController = TextEditingController()..addListener(_onFormChanged);
    _descriptionController = TextEditingController()..addListener(_onFormChanged);
    _additionalDataController = TextEditingController()..addListener(_onFormChanged);
    _behanceLinkController = TextEditingController()..addListener(_onFormChanged);
    _driveLinkController = TextEditingController()..addListener(_onFormChanged);
    _syllabusController = TextEditingController()..addListener(_onFormChanged);
  }

  void _populateFields(CreatorItemModel item) {
    _nameController.text = item.name ?? '';
    _priceController.text = item.price?.toString() ?? '';
    _descriptionController.text = item.description ?? '';
    _existingImageUrls = List<String>.from(item.pictures ?? []); // Populate existing image URLs

    // Populate profession-specific fields
    if (item.details != null) {
      switch (_currentProfessionId) {
        case 1: // Food Chef
        case 2: // Sweet Chef
          final details = item.details as RestaurantItemDetails;
          _timeController.text = details.time ?? '';
          if (details.ingredients != null) {
            _extraItems = details.ingredients!
                .map((e) => {"name": e.name, "price": e.price})
                .toList();
          }
          break;
        case 3: // Home Services
          final details = item.details as HsItemDetails;
          _timeController.text = details.workingTime ?? '';
          _behanceLinkController.text = details.behanceLink ?? '';
          _portfolioLinks = List<String>.from(details.portfolioLinks ?? []);
          break;
        case 4: // Hand Crafter
          final details = item.details as HcItemDetails;
          _timeController.text = details.time ?? '';
          _descriptionController.text = item.description ?? '';
          break;
        case 5: // Freelancer
          final details = item.details as FreelancerItemDetails;
          _timeController.text = details.workingTime ?? '';
          _portfolioLinks = List<String>.from(details.portfolioLinks ?? []);break;
        case 6: // Tutoring
          final details = item.details as TeachingItemDetails;
          _timeController.text = details.courseDuration ?? '';
          _syllabusController.text = details.syllabus ?? '';
          _driveLinkController.text = details.googleDriveLink ?? '';
          break;
        default:
          break;
      }
    }
    // Reset hasUnsavedChanges after initial population
    _hasUnsavedChanges = false;
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _hasUnsavedChanges = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _additionalDataController.dispose();
    _behanceLinkController.dispose();
    _driveLinkController.dispose();
    _syllabusController.dispose();
    _uploadCancelToken.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // متغيرات رسالة التعديل
    final DateTime? createdAt = widget.itemToEdit.createdAt;
    String message = '';
    Color textColor =Theme.of(context).primaryColor;
    Color borderColor = Theme.of(context).primaryColor;

    if (createdAt != null) {
      final Duration difference = DateTime.now().difference(createdAt);
      final Duration timeLimit = const Duration(hours: 24);

      if (difference < timeLimit) {
        final Duration remainingTime = timeLimit - difference;
        final int hoursRemaining = remainingTime.inHours;
        final int minutesRemaining = remainingTime.inMinutes.remainder(60);

        if (hoursRemaining > 0) {

          message = LocaleKeys.freeEditTimeRemainingHoursMinutes.tr(
            namedArgs: {
              'hours': hoursRemaining.toString(),
              'minutes': minutesRemaining.toString(),
            },
          );
          textColor = Colors.teal;
        } else {
          textColor = Colors.orange.shade700;
          borderColor = Colors.orange.shade400;
          message = LocaleKeys.freeEditTimeRemainingMinutes.tr(
            namedArgs: {'minutes': minutesRemaining.toString()},
          );
        }
      } else {
        message = LocaleKeys.editWillCostTokens.tr(namedArgs: {'tokens': '5'});
        textColor = Colors.orange.shade700;
        borderColor = Colors.orange.shade400;
      }
    } else {
      message = LocaleKeys.editTimeLimitMessage.tr();
    }


    return BlocListener<GetItemsCubit, GetItemsState>(
      listener: (context, state) {
        if (state is GetItemsLoading) {
          if (mounted) setState(() => _isSubmitting = true);
        } else if (state is UpdateItemSuccess) {
          String successMessage = state.message;
          if (state.tokensDeducted > 0) {
            successMessage += ' ${LocaleKeys.tokensDeducted.tr(args: [state.tokensDeducted.toString()])}';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(successMessage, style: TextStyle(color: Colors.black),), backgroundColor: Theme.of(context).primaryColor),
          );
          if (mounted) {
            setState(() => _isSubmitting = false);
          }
          Navigator.of(context).pop(true); // Pop with true to indicate success for refreshing previous screen
        } else if (state is GetItemsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
          if (mounted) {
            setState(() => _isSubmitting = false); // إعادة تفعيل الزر أو إخفاء المؤشر على الفشل
          }
        }
      },
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Image.asset('assets/images/logo.png' , width: 150,),
            leading: popButton(context),
            
          ),
          
          body: BlocBuilder<DashBoardCubit, DashBoardStates>(
            builder: (context, dashboardState) {
              if (dashboardState is! ProfileLoaded) {
                return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
              }

              final profile = dashboardState.profile;
              final creatorId = profile.id;

              if (_isSubmitting) {
                return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: textColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        LocaleKeys.editItem.tr(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildNameField(_currentProfessionId),
                      const SizedBox(height: 20),
                      _buildPriceField(),
                      const SizedBox(height: 20),
                      _buildImagePickerSection(),
                      if (_shouldShowTimeField(_currentProfessionId)) ...[
                        const SizedBox(height: 20),
                        _buildTimeField(_currentProfessionId),
                      ],
                      if (_shouldShowDescriptionField(_currentProfessionId)) ...[
                        const SizedBox(height: 20),
                        _buildDescriptionField(_currentProfessionId),
                      ],
                      const SizedBox(height: 20),

                      if ([1, 2].contains(_currentProfessionId))
                        ExtraItemsSection(
                          maxItems: 3,
                          initialItems: _extraItems,
                          onItemsChanged: (items) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _extraItems = items;
                                  _onFormChanged();
                                });
                              }
                            });
                          },
                        ),


                      if ([5].contains(_currentProfessionId))
                        PortfolioLinksField(
                          professionId: _currentProfessionId,
                          initialLinks: _portfolioLinks,
                          onChanged: (links) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _portfolioLinks = links;
                                  _onFormChanged();
                                });
                              }
                            });
                          },
                        ),

                      if ([6].contains(_currentProfessionId)) ...[
                        const SizedBox(height: 20),
                        CustomFormInput(
                          controller: _driveLinkController,
                          label: LocaleKeys.googleDriveLink.tr(),
                          hintText: LocaleKeys.enterGoogleDriveLink.tr(),
                          fillColor: Colors.transparent,
                          borderColor: Colors.grey,
                          keyboardType: TextInputType.url,
                          validator: _validateRequiredField,
                        ),
                      ],

                      if (_currentProfessionId == 6) ...[
                        const SizedBox(height: 20),
                        CustomFormInput(
                          controller: _syllabusController,
                          label: LocaleKeys.syllabus.tr(),
                          hintText: LocaleKeys.enterSyllabusDetails.tr(),
                          maxLines: 5,
                          fillColor: Colors.transparent,
                          borderColor: Colors.grey,
                          validator: _validateRequiredField,
                        ),
                      ],
                      const SizedBox(height: 30),
                      _buildActionButtons(creatorId, _currentProfessionId), // Pass fixed professionId
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _buildNameField(int professionId) {
    return CustomFormInput(
      controller: _nameController,
      label: _getLabelName(professionId),
      hintText: _getNameHint(professionId),
      validator: _validateRequiredField,
      fillColor: Colors.transparent,
      borderColor: Colors.grey,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomFormInput(
                controller: _priceController,
                label: '${LocaleKeys.price.tr()} (${LocaleKeys.inDollars.tr()})',
                hintText: '0.00',
                validator: _validatePrice,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                fillColor: Colors.transparent,
                borderColor: Colors.grey,
                prefixText: '\$ ',
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            LocaleKeys.priceGuideText.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(int professionId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,

              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getDescriptionLabel(professionId) ,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              CustomFormInput(
                controller: _descriptionController,
                label: '',
                hintText: _getDescriptionHint(professionId),
                maxLines: 3,
                validator: _validateRequiredField,
                fillColor: Colors.transparent,
                borderColor: Colors.transparent,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            _getDescriptionGuide(professionId),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.uploadImages.tr(),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        // Pass existing images to the ImagePickerSection
        ImagePickerSection(
          selectedImages: _selectedImages,
          existingImageUrls: _existingImageUrls, // Pass existing image URLs
          maxImages: 3,
          onImagesChanged: (images) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedImages = images;
                  _onFormChanged();
                });
              }
            });
          },
          onExistingImagesRemoved: (remainingUrls) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _existingImageUrls = remainingUrls;
                  _onFormChanged();
                });
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimeField(int professionId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFormInput(
          controller: _timeController,
          label: _getTimeLabel(professionId),
          hintText: _getTimeHint(professionId),
          onTap: () => _showDurationPicker(context),
          validator: _validateRequiredField,
          fillColor: Colors.transparent,
          borderColor: Colors.grey,
          readOnly: true,
          suffixIcon: Icons.access_time,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            _getTimeGuide(professionId),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(int creatorId, int professionId) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 35
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              onPressed: _isSubmitting ? null : () => _submitForm(creatorId, professionId),
              text: LocaleKeys.updateItem.tr(), // Changed to Update Item
              isLoading: _isSubmitting,
              textColor: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomButton(
              onPressed: _isSubmitting ? null : () => _confirmCancel(context),
              text: LocaleKeys.cancel.tr(),
              color: const Color.fromRGBO(172, 190, 177, 1),
              textColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.unsavedChanges.tr()),
        content: Text(LocaleKeys.unsavedChangesMessage.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(LocaleKeys.stay.tr(), style: TextStyle(color: textColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(LocaleKeys.leave.tr(), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  void _confirmCancel(BuildContext context) {
    if (!_hasUnsavedChanges) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.unsavedChanges.tr()),
        content: Text(LocaleKeys.unsavedChangesMessage.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocaleKeys.stay.tr(), style: TextStyle(color: textColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(LocaleKeys.leave.tr(), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDurationPicker(BuildContext context) {
    Duration? selectedDuration;
    TimeUnit selectedUnit = TimeUnit.minutes;
    TextEditingController durationController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(child: Text(LocaleKeys.selectDuration.tr())),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(IconBroken.Time_Square, size: 50),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: LocaleKeys.durationValueHint.tr(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<TimeUnit>(
                        value: selectedUnit,
                        items: TimeUnit.values.map((unit) {
                          return DropdownMenuItem<TimeUnit>(
                            value: unit,
                            child: Text(unit == TimeUnit.minutes ? LocaleKeys.min.tr() : LocaleKeys.hr.tr()),
                          );
                        }).toList(),
                        onChanged: (unit) {
                          if (unit != null) {
                            setState(() {
                              selectedUnit = unit;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    LocaleKeys.cancel.tr(),
                    style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final value = int.tryParse(durationController.text);
                    if (value != null && value > 0) {
                      selectedDuration = selectedUnit == TimeUnit.minutes
                          ? Duration(minutes: value)
                          : Duration(hours: value);
                      Navigator.pop(context, selectedDuration);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(LocaleKeys.invalidDuration.tr())),
                      );
                    }
                  },
                  child: Text(
                    LocaleKeys.ok.tr(),
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((pickedDuration) {
      if (pickedDuration != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              final hours = pickedDuration.inHours;
              final minutes = pickedDuration.inMinutes % 60;

              if (hours > 0) {
                _timeController.text = "$hours ${LocaleKeys.hr.tr()}${minutes > 0 ? " ${LocaleKeys.and.tr()} $minutes ${LocaleKeys.min.tr()}" : ""}";
              } else {
                _timeController.text = "$minutes ${LocaleKeys.min.tr()}";
              }
              _onFormChanged();
            });
          }
        });
      }
    });
  }


  void _submitForm(int creatorId, int professionId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final String name = _nameController.text.trim();
      final double price = double.tryParse(_priceController.text.trim()) ?? 0;
      final String token = CacheHelper.getData(key: 'token');

      final DateTime? createdAt = widget.itemToEdit.createdAt; // افترض أن itemToEdit لديه createdAt
      bool isMoreThan24Hours = false;
      if (createdAt != null) {
        final Duration difference = DateTime.now().difference(createdAt);
        if (difference.inHours >= 24) {
          isMoreThan24Hours = true;
        }
      }

      if (isMoreThan24Hours) {

    final double? userTokens = context.read<DashBoardCubit>().creatorProfile!.tokens;


        const int requiredTokens = 5;

        if (userTokens == null || userTokens < requiredTokens) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocaleKeys.insufficientTokens.tr(args: [requiredTokens.toString()])),
                backgroundColor: Colors.orange,
              ),
            );
            setState(() => _isSubmitting = false);
          }
          return;
        }
      }
      List<String> picturesToUpload = [];
      for (File imageFile in _selectedImages) {
        try {
          String uploadedUrl = await _uploadImage(imageFile);
          picturesToUpload.add(uploadedUrl);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${LocaleKeys.imageUploadFailed.tr()}: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isSubmitting = false);
          }
          return;
        }
      }
      List<String> finalPictures = [..._existingImageUrls, ...picturesToUpload];


      Map<String, dynamic> itemData = {
        "name": name,
        "price": price,
      };

      itemData['pictures'] = finalPictures;

      if (_shouldShowDescriptionField(professionId) && _descriptionController.text.isNotEmpty) {
        itemData['description'] = _descriptionController.text.trim();
      } else {
        itemData['description'] = null;
      }

      switch (professionId) {
        case 1: // Food Chef
        case 2: // Sweet Chef
          if (_timeController.text.isNotEmpty) {
            itemData['time'] = _timeController.text.trim();
          } else {
            itemData['time'] = null;
          }
          itemData['ingredients'] = _extraItems
              .where((e) => e['name'] != null && e['name'].toString().trim().isNotEmpty)
              .map((e) => {
            "name": e['name'],
            "price": e['price'] is String
                ? double.tryParse(e['price']) ?? 0.0
                : e['price']?.toDouble() ?? 0.0,
          })
              .toList();
          break;

        case 3: // Home Services (hs_item_details)
          if (_timeController.text.isNotEmpty) {
            itemData['working_time'] = _timeController.text.trim();
          } else {
            itemData['working_time'] = null;
          }
          if (_behanceLinkController.text.isNotEmpty) {
            itemData['behance_link'] = _behanceLinkController.text.trim();
          } else {
            itemData['behance_link'] = null;
          }
          itemData['portfolio_links'] = _portfolioLinks;
          break;

        case 4: // Hand Crafter (hc_item_details)
          if (_timeController.text.isNotEmpty) {
            itemData['time'] = _timeController.text.trim();
          } else {
            itemData['time'] = null;
          }
          itemData['ingredients'] = _extraItems
              .where((e) => e['name'] != null && e['name'].toString().trim().isNotEmpty)
              .map((e) => {
            "name": e['name'],
            "price": e['price'] is String
                ? double.tryParse(e['price']) ?? 0.0
                : e['price']?.toDouble() ?? 0.0,
          })
              .toList();
          if (_additionalDataController.text.isNotEmpty) {
            itemData['additional_data'] = _additionalDataController.text.trim();
          } else {
            itemData['additional_data'] = null;
          }
          break;

        case 5: // Freelancer's (freelancer_item_details)
          if (_timeController.text.isNotEmpty) {
            itemData['working_time'] = _timeController.text.trim();
          } else {
            itemData['working_time'] = null;
          }
          itemData['portfolio_links'] = _portfolioLinks;
          if (_driveLinkController.text.isNotEmpty) { // Assuming drive link is for freelancer too
            itemData['google_drive_link'] = _driveLinkController.text.trim();
          } else {
            itemData['google_drive_link'] = null;
          }
          break;

        case 6: // Tutoring (tutoring_item_details)
          if (_timeController.text.isNotEmpty) {
            itemData['course_duration'] = _timeController.text.trim();
          } else {
            itemData['course_duration'] = null;
          }
          if (_syllabusController.text.isNotEmpty) {
            itemData['syllabus'] = _syllabusController.text.trim();
          } else {
            itemData['syllabus'] = null;
          }
          if (_driveLinkController.text.isNotEmpty) {
            itemData['google_drive_link'] = _driveLinkController.text.trim();
          } else {
            itemData['google_drive_link'] = null;
          }
          break;

        default:
          break;
      }

      print('FLUTTER DEBUG: Final itemData sent to Cubit: $itemData');

      // Call updateItem instead of addItem
      await context.read<GetItemsCubit>().updateItem(
        itemId: widget.itemToEdit.id!, // Pass the ID of the item to update
        itemData: itemData,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
      }

    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        print('FLUTTER DEBUG: Submission caught error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${LocaleKeys.submissionFailed.tr()}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(image.path, filename: fileName),
      });
      var response = await Dio().post(
        'https://www.mashru3i.com/upload.php',
        data: formData,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.data);
        return decoded['url'];
      } else {
        throw Exception(LocaleKeys.uploadFailedWithCode.tr(args: [response.statusCode.toString()]));
      }
    } catch (e) {
      throw Exception(LocaleKeys.imageUploadError.tr());
    }
  }

  bool _shouldShowTimeField(int professionId) {
    return [1, 2, 4, 5, 6].contains(professionId); // Added 3 for Home Services (working_time)
  }

  bool _shouldShowDescriptionField(int professionId) {
    // Description is used for general description, and for Hand Crafter's 'ingredients/materials'
    return [1, 2, 3, 4].contains(professionId); // Assuming all professions have a general description
  }

  String? _validateRequiredField(String? value) {
    return (value == null || value.isEmpty) ? LocaleKeys.fieldRequired.tr() : null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return LocaleKeys.fieldRequired.tr();
    if (double.tryParse(value) == null) return LocaleKeys.invalidPrice.tr();
    if (double.parse(value) <= 0) return LocaleKeys.priceMustBePositive.tr();
    return null;
  }

  String _getLabelName(int professionId) {
    switch (professionId) {
      case 1: return LocaleKeys.nameOfFood.tr();
      case 2: return LocaleKeys.nameOfSweet.tr();
      case 3: return LocaleKeys.nameOfHS.tr();
      case 4: return LocaleKeys.nameOfHC.tr();
      case 5: return LocaleKeys.nameOfFreelancer.tr();
      case 6: return LocaleKeys.nameOfCourse.tr();
      default: return LocaleKeys.nameOfService.tr();
    }
  }

  String _getTimeLabel(int professionId) {
    switch (professionId) {
      case 1:
      case 2: return LocaleKeys.preparationTimeLabel.tr();
      case 3: return LocaleKeys.workingTimeLabel.tr();
      case 4: return LocaleKeys.creationTimeLabel.tr();
      case 5: return LocaleKeys.workingTimeLabel.tr(); // Freelancer uses working_time for delivery
      case 6: return LocaleKeys.courseDurationLabel.tr();
      default: return LocaleKeys.timeLabel.tr();
    }
  }

  String _getDescriptionLabel(int professionId) {
    if (professionId == 1 || professionId == 2) {
      return LocaleKeys.ingredientsLabel.tr();
    } else if (professionId == 4) {
      return LocaleKeys.materials.tr(); // For Hand Crafter, assuming this is the label for materials
    }
    return LocaleKeys.descriptionLabel.tr(); // General description label
  }

  String _getNameHint(int professionId) {
    switch (professionId) {
      case 1: return LocaleKeys.foodNameHint.tr();
      case 2: return LocaleKeys.sweetNameHint.tr();
      case 3: return LocaleKeys.hsNameHint.tr();
      case 4: return LocaleKeys.hcNameHint.tr();
      case 5: return LocaleKeys.freelancerNameHint.tr();
      case 6: return LocaleKeys.courseNameHint.tr();
      default: return LocaleKeys.serviceNameHint.tr();
    }
  }

  String _getDescriptionHint(int professionId) {
    switch (professionId) {
      case 1: return LocaleKeys.foodDescHint.tr();
      case 2: return LocaleKeys.sweetDescHint.tr();
      case 4: return LocaleKeys.hcDescHint.tr();
      default: return LocaleKeys.serviceDescHint.tr();
    }
  }

  String _getDescriptionGuide(int professionId) {
    switch (professionId) {
      case 1: return LocaleKeys.foodDescGuide.tr();
      case 2: return LocaleKeys.sweetDescGuide.tr();
      case 4: return LocaleKeys.hcDescGuide.tr();
      default: return LocaleKeys.serviceDescGuide.tr();
    }
  }

  String _getTimeHint(int professionId) {
    switch (professionId) {
      case 1:
      case 2: return LocaleKeys.preparationTimeHint.tr();
      case 3: return LocaleKeys.workingTimeHint.tr();
      case 4: return LocaleKeys.creationTimeHint.tr();
      case 5: return LocaleKeys.workingTimeHint.tr();
      case 6: return LocaleKeys.courseDurationHint.tr();
      default: return LocaleKeys.preparationTimeHint.tr();
    }
  }

  String _getTimeGuide(int professionId) {
    switch (professionId) {
      case 1:
      case 2: return LocaleKeys.preparationTimeGuide.tr();
      case 3: return LocaleKeys.workingTimeGuide.tr();
      case 4: return LocaleKeys.creationTimeGuide.tr();
      case 5: return LocaleKeys.workingTimeGuide.tr();
      case 6: return LocaleKeys.courseDurationGuide.tr();
      default: return LocaleKeys.preparationTimeGuide.tr();
    }
  }
}