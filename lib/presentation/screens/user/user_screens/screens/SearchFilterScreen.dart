import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/core/theme/color.dart';
import 'package:mashrou3i/core/theme/icons_broken.dart';
import 'package:mashrou3i/data/creatorsItems.dart';
import 'package:mashrou3i/presentation/widgets/compnents.dart';
import '../../../../../data/models/user_items_model/ItemSearch.dart';
import 'ProductDetailScreen.dart';
import 'items_logic/items_get_cubit.dart';
import 'items_logic/items_git_states.dart';

class SearchFilterScreen extends StatefulWidget {
  final String categoryTitle;
  final String? initialSearch;
  final double? initialMinRate;
  final bool initialFreeDelivery;
  final bool initialHasOffer;
  final bool initialIsOpenNow;
  final int? initialProfessionId;
  final bool returnCreator;

  const SearchFilterScreen({
    Key? key,
    required this.categoryTitle,
    this.initialSearch,
    this.initialMinRate,
    this.initialFreeDelivery = false,
    this.initialHasOffer = false,
    this.initialIsOpenNow = false,
    this.initialProfessionId,
    this.returnCreator = false,
  }) : super(key: key);

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  late TextEditingController _searchController;
  late double _minRate;
  late bool _freeDelivery;
  late bool _hasOffer;
  late bool _isOpenNow;
  int? _selectedProfessionId;
  String? _selectedTimeFilter;
  String? _selectedWorkingTimeFilter;
  String? _selectedCourseDurationFilter;
  Timer? _debounce;
  bool _hasSearched = false;

  final List<Map<String, dynamic>> _professions = [
    {'id': null, 'name_key': 'all_professions'},
    {'id': 1, 'name_key': 'restaurant_profession'},
    {'id': 2, 'name_key': 'sweets'},
    {'id': 3, 'name_key': 'hand_service_profession'},
    {'id': 4, 'name_key': 'hand_crafter_profession'},
    {'id': 5, 'name_key': 'freelancer_profession'},
    {'id': 6, 'name_key': 'tutoring_profession'},
  ];

  List<ItemFull> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch);
    _minRate = widget.initialMinRate ?? 0.0;
    _freeDelivery = widget.initialFreeDelivery;
    _hasOffer = widget.initialHasOffer;
    _isOpenNow = widget.initialIsOpenNow;
    _selectedProfessionId = widget.initialProfessionId;

    _hasSearched = widget.initialSearch?.isNotEmpty ?? false;

    if (_hasSearched) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _hasSearched = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _hasSearched = true;
    });

    context.read<UserItemsCubit>().fetchSearchItems(
      query: _searchController.text.trim(),
      professionId: _selectedProfessionId,
      minRate: _minRate > 0 ? _minRate : null,
      freeDelivery: _freeDelivery,
      hasOffer: _hasOffer,
      isOpenNow: _isOpenNow,
      time: _selectedTimeFilter,
      workingTime: _selectedWorkingTimeFilter,
      courseDuration: _selectedCourseDurationFilter,
      limit: 20,
      offset: 0,
    );
  }

  IconData _getIconForProfessionId(int professionId) {
    if (professionId == 1 || professionId == 2 || professionId == 4) {
      return Icons.restaurant;
    }
    switch (professionId) {
      case 3:
        return Icons.handyman;
      case 5:
        return Icons.work;
      case 6:
        return Icons.school;
      default:
        return Icons.info_outline;
    }
  }

  void _navigateToDetails(ItemFull item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          itemId: item.id,
          productName: item.name,
          productPrice: item.price,
          productDescription: item.description,
          creator: item.toCreatorItem(),
          isAvailable: item.isAvailable,
          professionId: item.professionId,
          portfolioLink: item.portfolioLinks?.isNotEmpty == true
              ? item.portfolioLinks!.first
              : null,
          syllabus: item.syllabus,
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'filter_options'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int?>(

                      decoration: InputDecoration(
                        labelText: 'select_profession'.tr(),
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      value: _selectedProfessionId,
                      items: _professions.map((prof) {
                        return DropdownMenuItem<int?>(
                          value: prof['id'],
                          child: Text((prof['name_key'] as String).tr()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          _selectedProfessionId = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text('minimum_rate'.tr())),
                          Text(_minRate.toStringAsFixed(1)),
                        ],
                      ),
                    ),
                    Slider(
                      value: _minRate,
                      min: 0.0,
                      max: 5.0,
                      divisions: 50,
                      label: _minRate.toStringAsFixed(1),
                      onChanged: (newValue) {
                        setModalState(() {
                          _minRate = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('free_delivery'.tr()),
                      value: _freeDelivery,
                      onChanged: (newValue) {
                        setModalState(() {
                          _freeDelivery = newValue;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text('has_offer'.tr()),
                      value: _hasOffer,
                      onChanged: (newValue) {
                        setModalState(() {
                          _hasOffer = newValue;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text('open_now'.tr()),
                      value: _isOpenNow,
                      onChanged: (newValue) {
                        setModalState(() {
                          _isOpenNow = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_selectedProfessionId == null ||
                        _selectedProfessionId == 1 ||
                        _selectedProfessionId == 4)

                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 15
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _performSearch();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            'apply_filters'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                            color: Colors.black,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        leading: popButton(context),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon:  Icon(IconBroken.Filter, color: Colors.black),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_in_category'.tr(args: [widget.categoryTitle]),
                prefixIcon: const Icon(IconBroken.Search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _debounce?.cancel();
                    _performSearch();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
              ),
              onChanged: (text) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  _performSearch();
                });
              },
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 16),

            // Search Results
            Expanded(
              child: BlocConsumer<UserItemsCubit, UserItemsState>(
                listener: (context, state) {
                  if (state is UserSearchItemsLoaded) {
                    setState(() {
                      _searchResults = state.searchResults;
                    });
                  } else if (state is UserItemsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                    setState(() {
                      _searchResults = [];
                    });
                  }
                },
                builder: (context, state) {
                  if (!_hasSearched) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'enter_search_term'.tr(),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is UserItemsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_searchResults.isEmpty) {
                    return Center(
                      child: Text(
                        'no_results_found'.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _navigateToDetails(item),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[100],
                                    child: item.pictures.isNotEmpty
                                        ? Image.network(
                                      item.pictures[0],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                    )
                                        : Center(
                                      child: Icon(
                                        _getIconForProfessionId(item.professionId),
                                        color: Theme.of(context).primaryColor,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      if (item.storeName != null && item.storeName!.isNotEmpty)
                                        Text(
                                          item.storeName!,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${item.price.toStringAsFixed(2)}\$',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}