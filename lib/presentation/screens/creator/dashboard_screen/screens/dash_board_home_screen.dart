import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mashrou3i/core/theme/color.dart';
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../../data/models/crator_order_model.dart';
import '../../../../../data/models/items_model/creator_item_model.dart';
import '../../../../../data/models/items_model/freelancer_item_details.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../data/models/items_model/hc_item_details.dart';
import '../../../../../data/models/items_model/hs_item_details.dart';
import '../../../../../data/models/items_model/restaurant_item_details.dart';
import '../../../../../data/models/items_model/teaching_item_details.dart';
import '../../add_items_screen/cubit/get_item_cubit.dart';
import '../../add_items_screen/cubit/get_item_state.dart';
import '../../add_items_screen/widgets/edit_item_screen.dart';
import '../../order/order_cubit.dart';
import '../../order/order_states.dart';
import '../logic/dashboard_cibit.dart';
import '../logic/dashboard_states.dart';

class DashBoardHomeScreen extends StatefulWidget {
  const DashBoardHomeScreen({super.key});

  @override
  State<DashBoardHomeScreen> createState() => _DashBoardHomeScreenState();
}

class _DashBoardHomeScreenState extends State<DashBoardHomeScreen> {
  List<CreatorItemModel> items = [];
  List<CreatorOrder> orders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    context.read<GetItemsCubit>().fetchMyItems();
    _fetchRecentOrders();
  }


  void _fetchRecentOrders() {
    final token = CacheHelper.getData(key: 'token');
    context.read<CreatorOrderCubit>().fetchCreatorOrders(token).then((_) {
      if (mounted) {
        final state = context.read<CreatorOrderCubit>().state;
        if (state is CreatorOrderLoaded) {
          setState(() {
            orders = List.from(state.orders)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            orders = orders.take(3).toList();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetItemsCubit, GetItemsState>(
      builder: (context, state) {
        if (state is GetItemsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is GetItemsError) {
          return SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(LocaleKeys.errorLoadingItems.tr()),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _loadData(),
                    child: Text(LocaleKeys.retry.tr()),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is GetItemsSuccess) {
          items = state.items;
        }
        final recentItems = items.reversed.take(3).toList();

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadData();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(15),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image(
                        width: 200,
                        image: AssetImage('assets/images/logo.png'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Recent Items Section
                    _buildSectionHeader(
                      context,
                      title: LocaleKeys.recentItems.tr(),
                      actionText: LocaleKeys.addNewItem.tr(),
                      onTitlePressed: () => context.push('/RecentItems'),
                      onActionPressed: () => context.push('/AddItemsScreen'),
                    ),
                    const SizedBox(height: 10),

                    if (recentItems.isEmpty)
                      _buildEmptyState(
                        icon: Icons.inventory_2,
                        message: LocaleKeys.noItemsFound.tr(),
                        actionText: LocaleKeys.addNewItem.tr(),
                        onPressed: () => context.push('/AddItemsScreen'),
                      )
                    else
                      _buildItemsTable(context, recentItems),

                    const SizedBox(height: 20),

                    // Recent Orders Section
                    _buildSectionHeader(
                      context,
                      title: LocaleKeys.recentOrder.tr(),
                      actionText: 'view-all'.tr(),
                      onTitlePressed: () => context.push('/OrdersScreen'),
                      onActionPressed: () => context.push('/OrdersScreen'),
                    ),
                    const SizedBox(height: 10),
                    _buildOrdersTable(orders),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildSectionHeader(
      BuildContext context, {
        required String title,
        required String actionText,
        required VoidCallback onTitlePressed,
        required VoidCallback onActionPressed,
      }) {
    return Row(
      children: [
        TextButton(
          onPressed: onTitlePressed,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Icon(Icons.arrow_forward_ios_rounded, size: 15),
        const Spacer(),
        TextButton(
          onPressed: onActionPressed,
          child: Text(
            actionText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color:textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String actionText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(actionText, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(BuildContext context, List<CreatorItemModel> items) {
    int? currentCreatorProfessionId = items.isNotEmpty ? items[0].categoryId : null;

    print(currentCreatorProfessionId);

    List<DataColumn> columns = [
      DataColumn(label: Text(LocaleKeys.id.tr())),
      DataColumn(label: Text(LocaleKeys.name.tr())),
      DataColumn(label: Text(LocaleKeys.price.tr())),
    ];
    if (currentCreatorProfessionId == 5) {
      columns.add(DataColumn(label: Text(LocaleKeys.portfolioLink.tr())));
    } else if(currentCreatorProfessionId == 6){
      columns.add(DataColumn(label: Text(LocaleKeys.driveLink.tr())));
    }else{
      columns.add(DataColumn(label: Text(LocaleKeys.description.tr())));
    }

    if (currentCreatorProfessionId != 3) {
      columns.add(DataColumn(label: Text(LocaleKeys.time.tr())));
    }

    columns.addAll([
      DataColumn(label: Text(LocaleKeys.image.tr())),
      DataColumn(label: Text(LocaleKeys.edit.tr())),
      DataColumn(label: Text(LocaleKeys.delete.tr())),
    ]);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              dataRowMinHeight: 60,
              dataRowMaxHeight: 80,
              columnSpacing: 10,
              horizontalMargin: 12,
              columns: columns,
              rows: items.map((item) => _buildItemRow(context, item, currentCreatorProfessionId)).toList(),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildItemRow(BuildContext context, CreatorItemModel item, int? currentCreatorProfessionId) {
    final restaurantDetails = item.details is RestaurantItemDetails ? item.details as RestaurantItemDetails : null;
    final hcDetails = item.details is HcItemDetails ? item.details as HcItemDetails : null;
    final hsDetails = item.details is HsItemDetails ? item.details as HsItemDetails : null;
    final freelancerDetails = item.details is FreelancerItemDetails ? item.details as FreelancerItemDetails : null;
    final tutoringDetails = item.details is TeachingItemDetails ? item.details as TeachingItemDetails : null;

    String timeValue = '-';

    if (item.categoryId == 1 || item.categoryId == 2) {
      if (restaurantDetails != null && restaurantDetails.time != null && restaurantDetails.time!.isNotEmpty) {
        timeValue = restaurantDetails.time!;
      }
    } else if (item.categoryId == 4) {
      if (hcDetails != null && hcDetails.time != null && hcDetails.time!.isNotEmpty) {
        timeValue = hcDetails.time!;
      }
    } else if (item.categoryId == 5) {
      if (freelancerDetails != null && freelancerDetails.workingTime != null && freelancerDetails.workingTime!.isNotEmpty) {
        timeValue = freelancerDetails.workingTime!;
      }
    }else if (item.categoryId == 6) {
      if (tutoringDetails != null && tutoringDetails.courseDuration != null && tutoringDetails.courseDuration!.isNotEmpty) {
        timeValue = tutoringDetails.courseDuration!;
      }
    }

    String fourthColumnText = '';

    if (currentCreatorProfessionId == 5) {
      if (item.categoryId == 5 && freelancerDetails != null && freelancerDetails.portfolioLinks != null && freelancerDetails.portfolioLinks!.isNotEmpty) {
        fourthColumnText = freelancerDetails.portfolioLinks!.take(1).join(', ');
      } else {
        fourthColumnText = 'N/A';
      }
    }
    else if (currentCreatorProfessionId == 6) {
      if (item.categoryId == 6 && tutoringDetails != null && tutoringDetails.googleDriveLink != null && tutoringDetails.googleDriveLink!.isNotEmpty) {
        fourthColumnText = tutoringDetails.googleDriveLink!;
      } else {
        fourthColumnText = 'N/A';
      }
    }
    else {
      if (item.description != null && item.description!.isNotEmpty) {
        fourthColumnText = item.description!;
      } else if (item.categoryId == 3 && hsDetails != null && hsDetails.workingTime != null && hsDetails.workingTime!.isNotEmpty) {
        fourthColumnText = hsDetails.workingTime!;
      } else {
        fourthColumnText = 'N/A';
      }
    }

    List<DataCell> cells = [
      DataCell(Center(child: Text('${item.id}'))),
      DataCell(
        Center(child: Text(item.name ?? '')),
        onTap: () => _showItemDetails(context, item),
      ),
      DataCell(Center(child: Text('${item.price}\$'))),
      DataCell(
        Tooltip(
          message: fourthColumnText,
          child: Center(child: Text(shortText(fourthColumnText))),
        ),
      ),
    ];

    if (currentCreatorProfessionId != 3) {
      cells.add(DataCell(Center(child: Text(timeValue))));
    }

    cells.addAll([
      DataCell(
        InkWell(
          onTap: () => _showFullImage(context, item.pictures?.first),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: item.pictures?.first ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                ),
              ),
            ),
          ),
        ),
      ),
      DataCell(
        IconButton(
          icon: Icon(IconBroken.Edit, color: textColor),
          onPressed: () => _editItem(context, item),
        ),
      ),
      DataCell(
        IconButton(
          icon: Icon(IconBroken.Delete, color: Colors.red[800]),
          onPressed: () => _confirmDelete(context, item.id),
        ),
      ),
    ]);

    return DataRow(cells: cells);
  }

  String shortText(String? text, {int maxLength = 20}) {
    if (text == null || text.isEmpty) return '';
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildOrdersTable(List<CreatorOrder> orders) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              dataRowMinHeight: 60,
              dataRowMaxHeight: 80,
              columnSpacing: 20,
              horizontalMargin: 12,
              columns: [
                DataColumn(label: Text(LocaleKeys.customerName.tr())),
                DataColumn(label: Text(LocaleKeys.phone.tr())),
                DataColumn(label: Text(LocaleKeys.address.tr())),
                DataColumn(
                  label: Text(LocaleKeys.invoice.tr()),
                  numeric: true,
                ),
                DataColumn(label: Text(LocaleKeys.status.tr())),
                DataColumn(label: Text(LocaleKeys.view.tr())),
              ],
              rows: orders.map((order) => _buildOrderRow(order)).toList(),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildOrderRow(CreatorOrder order) {
    return DataRow(
      cells: [
        DataCell(
          Text(order.userFirstName ?? 'Unknown'),
          onTap: () => _showOrderDetails(context, order),
        ),
        DataCell(Text(order.userPhoneNumber ?? 'Not provided')),
        DataCell(Text(order.shippingAddress?? 'Not provided')),
        DataCell(
          Text(
            '\$${order.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.status.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
            onPressed: () => _showOrderDetails(context, order),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showOrderDetails(BuildContext context, CreatorOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBottomSheetHeader(context),
                _buildOrderDetailsContent(context, order),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          LocaleKeys.order_details.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildOrderDetailsContent(BuildContext context, CreatorOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(LocaleKeys.order_id.tr(), '#${order.orderId}'),
        _buildDetailRow(LocaleKeys.status.tr(), order.status,
            valueStyle: TextStyle(color: _getStatusColor(order.status))),
        const SizedBox(height: 16),
        Text(LocaleKeys.customer_info.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        _buildDetailRow(LocaleKeys.name.tr(), order.userFirstName ?? LocaleKeys.unknown.tr()),
        _buildDetailRow(LocaleKeys.address.tr(), order.shippingAddress ?? LocaleKeys.not_provided.tr()),
        const SizedBox(height: 16),
        Text(LocaleKeys.order_items.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        ...order.orderItems.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('${item.quantity}x ${item.itemName ?? LocaleKeys.unknown.tr()}'),
              ),
              Text('\$${(item.pricePerItem * item.quantity).toStringAsFixed(2)}'),
            ],
          ),
        )),
        const Divider(height: 24),
        _buildDetailRow(LocaleKeys.subtotal.tr(), '\$${order.totalAmount.toStringAsFixed(2)}'),
        _buildDetailRow(LocaleKeys.delivery_fee.tr(), '\$0.00'),
        _buildDetailRow(LocaleKeys.total.tr(), '\$${order.totalAmount.toStringAsFixed(2)}',
            isBold: true),
        _buildDetailRow(LocaleKeys.date.tr(), DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt.toLocal())),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: valueStyle ?? TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, CreatorItemModel item) {
    final freelancerDetails = item.details is FreelancerItemDetails
        ? item.details as FreelancerItemDetails
        : null;

    final restaurantDetails = item.details is RestaurantItemDetails
        ? item.details as RestaurantItemDetails
        : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name ?? LocaleKeys.itemDetails.tr()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.pictures?.isNotEmpty ?? false)
                CachedNetworkImage(
                  imageUrl: item.pictures!.first,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) {
                    print('Error loading image: $error');
                    return const Icon(Icons.broken_image, color: Colors.red);
                  },
                ),
              const SizedBox(height: 10),
              Text('${LocaleKeys.price.tr()}: ${item.price ?? 'N/A'}\$'),
              const SizedBox(height: 10),
              Text('${LocaleKeys.description.tr()}: ${item.description ?? 'N/A'}'),

              // --- عرض تفاصيل الـ Freelancer ---
              if (freelancerDetails != null) ...[
                const SizedBox(height: 10),
                if (freelancerDetails.workingTime != null && freelancerDetails.workingTime!.isNotEmpty)
                  Text('${LocaleKeys.workingTime.tr()}: ${freelancerDetails.workingTime}'),

                if (freelancerDetails.portfolioLinks != null && freelancerDetails.portfolioLinks!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        LocaleKeys.portfolioLinks.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      ...freelancerDetails.portfolioLinks!.map((link) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: InkWell(
                          onTap: () async {
                            final uri = Uri.parse(link);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not open link: $link' ,  style: TextStyle(color: Colors.black), ),
                                  backgroundColor: Theme.of(context).primaryColor,

                                ),
                              );
                            }
                            print('Tapped on link: $link');
                          },
                          child: Text(
                            link,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
              ],
              if (item.categoryId == 1 || item.categoryId == 2 || item.categoryId == 4) ...[
                if (restaurantDetails != null && restaurantDetails.time != null && restaurantDetails.time!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text('${LocaleKeys.workingTime.tr()}: ${restaurantDetails.time}'),
                    ],
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocaleKeys.close.tr()),
          ),
        ],
      ),
    );
  }  void _showFullImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null) return;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder:
                (context, url) =>
                Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.broken_image),
          ),
        ),
      ),
    );
  }

  void _editItem(BuildContext context, CreatorItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemScreen(itemToEdit: item),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int itemId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(LocaleKeys.confirmDelete.tr()),
        content: Text(LocaleKeys.areYouSureDeleteItem.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocaleKeys.cancel.tr(), style: TextStyle(color: textColor),),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GetItemsCubit>().deleteItem(itemId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(LocaleKeys.itemDeleted.tr() , style: TextStyle(color: Colors.black),) , backgroundColor: Theme.of(context).primaryColor,),
              );
            },
            child: Text(
              LocaleKeys.delete.tr(),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

String shortText(String? text, {int maxChars = 10}) {
  if (text == null) return '';
  return text.length > maxChars ? '${text.substring(0, maxChars)}...' : text;
}