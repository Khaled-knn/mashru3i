import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mashrou3i/presentation/widgets/compnents.dart';
import 'package:mashrou3i/presentation/widgets/custom_button.dart';

import '../../../../../core/theme/color.dart';
import '../../../../../data/models/offer_model.dart';
import 'offers_cubit.dart';
import 'offers_states.dart';

// Helper extension moved outside the class to be globally accessible
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final Map<String, double?> _offerValues = {};
  final Map<String, DateTime?> _startDates = {};
  final Map<String, DateTime?> _endDates = {};
  final Map<String, GlobalKey<FormState>> _offerFormKeys = {};
  final List<String> _availableOfferTypes = [
    'free_delivery',
    'first_order_discount',
    'all_orders_discount',
  ];

  String? _editingOfferType;

  final Set<String> _userToggledInactive = {};

  @override
  void initState() {
    super.initState();
    context.read<OffersCubit>().fetchOffers();

    for (var type in _availableOfferTypes) {
      _offerFormKeys[type] = GlobalKey<FormState>();
      _offerValues[type] = null;
      _startDates[type] = null;
      _endDates[type] = null;
    }
  }

  Future<void> _selectDate(
      BuildContext context,
      bool isStartDate,
      String offerType,
      ) async {
    DateTime initialDateForPicker;

    if (isStartDate) {
      initialDateForPicker = _startDates[offerType] ?? DateTime.now();
    } else {
      initialDateForPicker = _endDates[offerType] ?? DateTime.now();
      // Ensure initialDateForPicker is not before today
      if (initialDateForPicker.isBefore(DateTime.now())) {
        initialDateForPicker = DateTime.now();
      }
      // Ensure initialDateForPicker is not before the start date
      if (_startDates[offerType] != null &&
          initialDateForPicker.isBefore(_startDates[offerType]!)) {
        initialDateForPicker = _startDates[offerType]!;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDateForPicker,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
            buttonTheme: const ButtonThemeData(
                textTheme: ButtonTextTheme.primary
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: textColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDates[offerType] = picked;
          if (_endDates[offerType] != null &&
              _endDates[offerType]!.isBefore(_startDates[offerType]!)) {
            _endDates[offerType] = null;
          }
        } else {
          if (_startDates[offerType] != null &&
              picked.isBefore(_startDates[offerType]!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text(
                  'End date cannot be before start date',
                  style: TextStyle(color: Colors.black),
                ).tr(),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
            _endDates[offerType] = null;
          } else {
            _endDates[offerType] = picked;
          }
        }
      });
    }
  }

  void _saveOffer(String offerType) {
    final formKey = _offerFormKeys[offerType];

    if (offerType != 'free_delivery') {
      if (formKey == null || !formKey.currentState!.validate()) {
        return;
      }
      formKey.currentState!.save();
    }

    if (offerType != 'free_delivery') {
      if (_offerValues[offerType] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text(
              'please_enter_discount_value',
              style: TextStyle(color: Colors.black),
            ).tr(),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
        return;
      }
      if (_startDates[offerType] == null || _endDates[offerType] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text(
              'please_select_dates',
              style: TextStyle(color: Colors.black),
            ).tr(),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
        return;
      }
    }

    final currentOffers =
    (context.read<OffersCubit>().state is OffersLoaded)
        ? (context.read<OffersCubit>().state as OffersLoaded).offers
        : [];

    final existingOfferIndex = currentOffers.indexWhere(
          (o) => o.offerType == offerType,
    );

    PromotionOffer newOffer;

    if (offerType == 'free_delivery') {
      newOffer = PromotionOffer(
        offerType: offerType,
        offerValue: 0,
        offerStart: DateTime.now(),
        offerEnd: DateTime.now().add(const Duration(days: 365)),
      );
    } else {
      newOffer = PromotionOffer(
        offerType: offerType,
        offerValue: _offerValues[offerType]!,
        offerStart: _startDates[offerType]!,
        offerEnd: _endDates[offerType]!,
      );
    }

    List<PromotionOffer> updatedOffers = List<PromotionOffer>.from(
      currentOffers,
    );

    if (existingOfferIndex != -1) {
      updatedOffers[existingOfferIndex] = newOffer;
    } else {
      updatedOffers.add(newOffer);
    }

    context.read<OffersCubit>().saveOffers(updatedOffers);

    setState(() {
      _editingOfferType = null;
      _offerValues[offerType] = null;
      _startDates[offerType] = null;
      _endDates[offerType] = null;
      _offerFormKeys[offerType]?.currentState?.reset();
      _userToggledInactive.remove(offerType);
    });
  }

  void _deleteOffer(PromotionOffer offer) {
    final List<PromotionOffer> currentOffers =
    (context.read<OffersCubit>().state is OffersLoaded)
        ? (context.read<OffersCubit>().state as OffersLoaded).offers
        : [];

    List<PromotionOffer> updatedOffers = List<PromotionOffer>.from(
      currentOffers,
    );

    updatedOffers.removeWhere((o) => o.offerType == offer.offerType);

    context.read<OffersCubit>().saveOffers(updatedOffers);
    setState(() {
      _editingOfferType = null;
      _userToggledInactive.remove(offer.offerType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('offers', style: TextStyle(fontSize: 18)).tr(),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: popButton(context),
      ),
      body: BlocConsumer<OffersCubit, OffersState>(
        listener: (context, state) {
          if (state is OffersError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is OffersSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text(
                  'offer_saved_successfully',
                  style: TextStyle(color: Colors.black),
                ).tr(),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OffersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<PromotionOffer> currentLoadedOffers = [];
          if (state is OffersLoaded) {
            currentLoadedOffers = state.offers;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'manage_offers',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ).tr(),
                const SizedBox(height: 16),
                ..._availableOfferTypes.map((offerType) {
                  final existingOffer = currentLoadedOffers.firstWhereOrNull(
                        (o) => o.offerType == offerType,
                  );
                  bool isOfferCurrentlyActiveByDates = existingOffer?.isActive ?? false;
                  bool isSwitchOn = isOfferCurrentlyActiveByDates && !_userToggledInactive.contains(offerType);

                  return _buildOfferTypeCard(
                    context,
                    offerType,
                    existingOffer,
                    isSwitchOn,
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfferTypeCard(
      BuildContext context,
      String offerType,
      PromotionOffer? existingOffer,
      bool isSwitchCurrentlyOn,
      ) {
    bool isExpandedForEditing = _editingOfferType == offerType;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getOfferTypeName(offerType),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: isSwitchCurrentlyOn,
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        _editingOfferType = offerType;
                        if (existingOffer != null &&
                            offerType != 'free_delivery') {
                          _offerValues[offerType] = existingOffer.offerValue;
                          _startDates[offerType] = existingOffer.offerStart;
                          _endDates[offerType] = existingOffer.offerEnd;
                        } else {
                          _offerValues[offerType] = null;
                          _startDates[offerType] =
                              DateTime.now();
                          _endDates[offerType] = DateTime.now().add(
                            const Duration(days: 365),
                          );
                        }
                        _userToggledInactive.remove(offerType);
                      } else {
                        if (existingOffer != null) {
                          _deleteOffer(existingOffer);
                        } else {
                          debugPrint('Attempted to deactivate a non-existent offer type: $offerType');
                        }
                        _editingOfferType = null; // Close the form
                      }
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (existingOffer != null &&
                !isExpandedForEditing) // Show existing offer details only if not editing
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (existingOffer.offerType != 'free_delivery')
                    Text(
                      '${existingOffer.formattedDiscount} ${'discount'.tr()}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  if (existingOffer.offerType != 'free_delivery')
                    const SizedBox(height: 8),

                  if (existingOffer.offerType != 'free_delivery')
                    Text(
                      '${'from'.tr()} ${DateFormat('yyyy-MM-dd').format(existingOffer.offerStart)} '
                          '${'to'.tr()} ${DateFormat('yyyy-MM-dd').format(existingOffer.offerEnd)}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  if (existingOffer.offerType != 'free_delivery')
                    const SizedBox(height: 8),
                ],
              ),
            if (isExpandedForEditing && offerType != 'free_delivery')
              Form(
                key: _offerFormKeys[offerType],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: _offerValues[offerType]?.toString(),
                      decoration: InputDecoration(
                        labelText: 'discount_percentage'.tr(),
                        border: const OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_discount_value'.tr();
                        }
                        if (double.tryParse(value) == null) {
                          return 'please_enter_valid_number'.tr();
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _offerValues[offerType] = double.parse(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'start_date'.tr(),
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text:
                              _startDates[offerType] != null
                                  ? DateFormat(
                                'yyyy-MM-dd',
                              ).format(_startDates[offerType]!)
                                  : '',
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context, true, offerType),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'end_date'.tr(),
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text:
                              _endDates[offerType] != null
                                  ? DateFormat(
                                'yyyy-MM-dd',
                              ).format(_endDates[offerType]!)
                                  : '',
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context, false, offerType),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      onPressed: () => _saveOffer(offerType),
                      text: 'save_offer'.tr(),
                      radios: 10,
                      textColor: Colors.black,
                    ),
                  ],
                ),
              ),
            if (isExpandedForEditing && offerType == 'free_delivery')
              CustomButton(
                onPressed: () => _saveOffer(offerType),
                text: 'activate_free_delivery'.tr(),
                radios: 10,
                textColor: Colors.black,
              ),

            // Show "Configure Offer" button only if not expanded for editing AND the switch is OFF
            if (!isExpandedForEditing && !isSwitchCurrentlyOn)
              CustomButton(
                onPressed: () {
                  setState(() {
                    _editingOfferType = offerType; // Expand for editing
                    _offerValues[offerType] =
                    null; // Clear values for new configuration
                    _startDates[offerType] = DateTime.now();
                    _endDates[offerType] = DateTime.now().add(
                      const Duration(days: 365),
                    );
                    // Remove from manually deactivated list as user is now configuring/activating
                    _userToggledInactive.remove(offerType);
                  });
                },
                text: 'configure_offer'.tr(),
                radios: 10,
                textColor: Colors.black,
              ),
          ],
        ),
      ),
    );
  }

  String _getOfferTypeName(String type) {
    switch (type) {
      case 'free_delivery':
        return 'free_delivery'.tr();
      case 'first_order_discount':
        return 'first_order_discount'.tr();
      case 'all_orders_discount':
        return 'all_orders_discount'.tr();
      default:
        return type;
    }
  }
}