import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mashrou3i/core/theme/color.dart'; // تأكد من أن هذا المسار صحيح
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../widgets/coustem_form_input.dart';
import '../../../../widgets/custom_button.dart';
import '../../dashboard_screen/logic/dashboard_cibit.dart';
import '../../dashboard_screen/logic/dashboard_states.dart';
import '../cubit/add_item_cubit.dart';
import 'extra_items_section.dart';
import 'freelancer_info_section.dart'; // تأكد أن هذا الملف موجود ويحتوي على PortfolioLinksField
import 'image_picker.dart';

enum TimeUnit { minutes, hours }

class AddItemForm extends StatefulWidget {
  const AddItemForm({super.key});

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
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
  List<Map<String, dynamic>> _extraItems = [];
  List<String> _portfolioLinks = [];

  final CancelToken _uploadCancelToken = CancelToken();
  bool _isSubmitting = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(LocaleKeys.timeLimitNotice.tr()),
          content: Text(LocaleKeys.editTimeLimitMessage.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.ok.tr() , style: TextStyle(color: textColor),),
            ),
          ],
        ),
      );
    });
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
    // Dispose new controllers
    _additionalDataController.dispose();
    _behanceLinkController.dispose();
    _driveLinkController.dispose();
    _syllabusController.dispose();
    _uploadCancelToken.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashBoardCubit>().state;

    if (state is! ProfileLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = state.profile;
    final professionId = profile.professionId;
    final creatorId = profile.id;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Padding(
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
                  color: const Color.fromRGBO(119, 247, 211, 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.teal[600]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        LocaleKeys.editTimeLimitMessage.tr(),
                        style: const TextStyle(color: Color.fromRGBO(0, 194, 139, 1)),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                LocaleKeys.addNewItem.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildNameField(professionId),
              const SizedBox(height: 20),
              _buildPriceField(),
              const SizedBox(height: 20),
              _buildImagePickerSection(),
              if (_shouldShowTimeField(professionId)) ...[
                const SizedBox(height: 20),
                _buildTimeField(professionId),
              ],
              if (_shouldShowDescriptionField(professionId)) ...[
                const SizedBox(height: 20),
                _buildDescriptionField(professionId),
              ],

              const SizedBox(height: 20), // Spacing before profession-specific sections

              // Extra items section for Food/Sweet Chef (ingredients)
              if ([1, 2].contains(professionId))
                ExtraItemsSection(
                  maxItems: 3,
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

              // Additional Data field for Hand Crafter
              if (professionId == 4) ...[
                const SizedBox(height: 20),
              ],
              if ([5].contains(professionId))
                PortfolioLinksField(
                  professionId: professionId,
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

              // Drive Link field for Freelancer's
              if (professionId == 6) ...[
                const SizedBox(height: 20),
                CustomFormInput(
                  controller: _driveLinkController,
                  label: LocaleKeys.googleDriveLinkLabel.tr(), // Localize this
                  hintText: LocaleKeys.googleDriveLinkHint.tr(), // Localize this
                  fillColor: Colors.transparent,
                  borderColor: Colors.grey,
                  keyboardType: TextInputType.url,
                  validator: (value) { return null; },
                ),
              ],

              if (professionId == 6) ...[
                const SizedBox(height: 20),
                CustomFormInput(
                  controller: _syllabusController,
                  label: LocaleKeys.syllabusLabel.tr(), // Localize this
                  hintText: LocaleKeys.syllabusHint.tr(), // Localize this
                  maxLines: 5,
                  fillColor: Colors.transparent,
                  borderColor: Colors.grey,
                  validator: _validateRequiredField, // Decide if required
                ),
              ],
              const SizedBox(height: 30),
              _buildActionButtons(creatorId, professionId),
            ],
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
        ImagePickerSection(
          selectedImages: _selectedImages,
          existingImageUrls: [],
          maxImages: 3,
          onImagesChanged: (images) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedImages = images;
                });
              }
            });
          },
          onExistingImagesRemoved: (remainingUrls) {
            debugPrint('Attempted to remove existing image in AddItemScreen. Remaining: $remainingUrls');
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
              text: LocaleKeys.save.tr(),
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
              title: Center(child: Text(LocaleKeys.selectDuration.tr())), // Localize
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
                            hintText: LocaleKeys.durationValueHint.tr(), // Localize
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<TimeUnit>(
                        value: selectedUnit,
                        items: TimeUnit.values.map((unit) {
                          return DropdownMenuItem<TimeUnit>(
                            value: unit,
                            child: Text(unit == TimeUnit.minutes ? LocaleKeys.min.tr() : LocaleKeys.hr.tr()), // Localize
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
                      // Optional: show error if input is invalid
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(LocaleKeys.invalidDuration.tr()), backgroundColor: Colors.red,), // Localize
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
                _timeController.text = "$hours ${LocaleKeys.hr.tr()}${minutes > 0 ? " ${LocaleKeys.and.tr()} $minutes ${LocaleKeys.min.tr()}" : ""}"; // Localize
              } else {
                _timeController.text = "$minutes ${LocaleKeys.min.tr()}"; // Localize
              }
              _onFormChanged();
            });
          }
        });
      }
    });
  }

  void _submitForm(int creatorId, int professionId) async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      setState(() => _isSubmitting = true);
    }

    try {
      final String name = _nameController.text.trim();
      final double price = double.tryParse(_priceController.text.trim()) ?? 0;
      final String token = CacheHelper.getData(key: 'token');

      String? imageUrl;
      if (_selectedImages.isNotEmpty) {
        try {
          imageUrl = await _uploadImage(_selectedImages.first);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocaleKeys.imageUploadFailed.tr()),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isSubmitting = false);
          }
          return;
        }
      }

      Map<String, dynamic> itemData = {
        "name": name,
        "price": price,
        "category_id": professionId, // Assuming category_id is same as professionId for now
      };

      if (imageUrl != null) {
        itemData['pictures'] = [imageUrl];
      } else {
        itemData['pictures'] = []; // Ensure 'pictures' is an empty array if no image
      }

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
          print('FLUTTER DEBUG: _portfolioLinks value for profession 5: $_portfolioLinks (Type: ${_portfolioLinks.runtimeType})');
          break;

        case 4: // Hand Crafter (hc_item_details)
          if (_timeController.text.isNotEmpty) {
            itemData['time'] = _timeController.text.trim();
          } else {
            itemData['time'] = null;
          }
          if (_descriptionController.text.isNotEmpty) {
            itemData['ingredients'] = _descriptionController.text.trim();
          } else {
            itemData['ingredients'] = null;
          }
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
          print('FLUTTER DEBUG: _portfolioLinks value for profession 5: $_portfolioLinks (Type: ${_portfolioLinks.runtimeType})');
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
          // **التعديل هنا: أضف google_drive_link**
          if (_driveLinkController.text.isNotEmpty) { // تفترض وجود _googleDriveLinkController
            itemData['google_drive_link'] = _driveLinkController.text.trim();
          } else {
            itemData['google_drive_link'] = null;
          }
          break;

        default:
          break;
      }

      print('FLUTTER DEBUG: Final itemData sent to Cubit: $itemData');

      await context.read<ItemCubit>().addItem(
        itemData: itemData,
        token: token,
        context:context,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
      }

    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${LocaleKeys.submissionFailed.tr()}: $e'),
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
    return [1, 2, 4, 5 , 6].contains(professionId); // Added 3 for Home Services
  }

  bool _shouldShowDescriptionField(int professionId) {
    return [1, 2, 3, 4].contains(professionId);
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
      case 3: return LocaleKeys.nameOfHS.tr(); // Localize
      case 4: return LocaleKeys.nameOfHC.tr(); // Localize
      case 5: return LocaleKeys.nameOfFreelancer.tr(); // Localize
      case 6: return LocaleKeys.nameOfCourse.tr(); // Localize
      default: return LocaleKeys.nameOfService.tr(); // Localize
    }
  }

  String _getTimeLabel(int professionId) {
    switch (professionId) {
      case 1:
      case 2: return LocaleKeys.preparationTimeLabel.tr(); // Localize
      case 3: return LocaleKeys.workingTimeLabel.tr(); // Localize
      case 4: return LocaleKeys.creationTimeLabel.tr(); // Localize (New for HC)
      case 5: return LocaleKeys.workingTimeLabel.tr(); // Localize
      case 6: return LocaleKeys.courseDurationLabel.tr(); // Localize
      default: return LocaleKeys.timeLabel.tr(); // Localize
    }
  }

  String _getDescriptionLabel(int professionId) {
    if (professionId == 1 || professionId == 2) {
      return LocaleKeys.ingredientsLabel.tr(); // Localize
    } else if (professionId == 4) {
      return LocaleKeys.descriptionHC.tr(); // Localize for Hand Crafter
    }
    return LocaleKeys.descriptionLabel.tr(); // Localize
  }

  String _getNameHint(int professionId) {
    switch (professionId) {
      case 1: return LocaleKeys.foodNameHint.tr();
      case 2: return LocaleKeys.sweetNameHint.tr();
      case 3: return LocaleKeys.hsNameHint.tr();
      case 4: return LocaleKeys.hcNameHint.tr();
      case 5: return LocaleKeys.freelancerNameHint.tr(); // Localize
      case 6: return LocaleKeys.courseNameHint.tr(); // Localize
      default: return LocaleKeys.serviceNameHint.tr();
    }
  }

  String _getDescriptionHint(int professionId) {
    switch (professionId) {
      case 1: return LocaleKeys.foodDescHint.tr();
      case 2: return LocaleKeys.sweetDescHint.tr();
      case 4: return LocaleKeys.hcDescHint.tr(); // Localize for Hand Crafter
      default: return LocaleKeys.serviceDescHint.tr();
    }
  }

  String _getDescriptionGuide(int professionId) {
    switch (professionId) {
      case 1: return LocaleKeys.foodDescGuide.tr();
      case 2: return LocaleKeys.sweetDescGuide.tr();
      case 4: return LocaleKeys.hcDescGuide.tr(); // Localize for Hand Crafter
      default: return LocaleKeys.serviceDescGuide.tr();
    }
  }

  String _getTimeHint(int professionId) {
    switch (professionId) {
      case 1:
      case 2: return LocaleKeys.preparationTimeHint.tr();
      case 3: return LocaleKeys.workingTimeHint.tr();
      case 4: return LocaleKeys.creationTimeHint.tr(); // Localize (New for HC)
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
      case 4: return LocaleKeys.creationTimeGuide.tr(); // Localize (New for HC)
      case 5: return LocaleKeys.workingTimeGuide.tr();
      case 6: return LocaleKeys.courseDurationGuide.tr();
      default: return LocaleKeys.preparationTimeGuide.tr();
    }
  }
}