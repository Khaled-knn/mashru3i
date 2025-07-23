import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/core/network/local/cach_helper.dart'; // تأكد من المسار الصحيح
import 'package:mashrou3i/core/theme/color.dart';
import 'package:mashrou3i/presentation/widgets/compnents.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/icons_broken.dart'; // تأكد من المسار الصحيح
import '../../../../../data/models/crator_order_model.dart'; // تأكد من المسار الصحيح
import '../../order/order_cubit.dart'; // تأكد من المسار الصحيح
import '../../order/order_states.dart'; // تأكد من المسار الصحيح
import 'dart:convert';

enum TimeUnit { minutes, hours, days }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _deliveryTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() {
    final token = CacheHelper.getData(key: 'token');
    if (token != null) {
      context.read<CreatorOrderCubit>().fetchCreatorOrders(token);
    } else {
      // Handle case where token is null (e.g., show error or redirect to login)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found. Please log in.'.tr())),
      );
    }
  }

  @override
  void dispose() {
    _deliveryTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        title: const Text('My Orders', style: TextStyle(fontSize: 18)),
        leading: popButton(context),
      ),
      body: BlocConsumer<CreatorOrderCubit, CreatorOrderState>(
        listener: (context, state) {
          if (state is CreatorOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is CreatorOrderUpdating) {
          }
        },
        builder: (context, state) {
          if (state is CreatorOrderInitial || state is CreatorOrderLoading || state is CreatorOrderUpdating) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CreatorOrderError) {
            return Center(child: Text(state.message));
          } else if (state is CreatorOrderLoaded) {
            return _buildOrderTabs(context, state.orders);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
  Widget _buildOrderTabs(BuildContext context, List<CreatorOrder> allOrders) {
    final pendingOrders = allOrders.where((o) => o.status.toLowerCase() == 'pending').toList();
    final acceptedOrders = allOrders.where((o) => o.status.toLowerCase() == 'accepted').toList();
    final completedOrders = allOrders.where((o) => o.status.toLowerCase() == 'completed').toList();
    final cancelledOrders = allOrders.where((o) => o.status.toLowerCase() == 'canceled').toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: TabBar(
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: textColor,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Pending'.tr()),
                Tab(text: '${LocaleKeys.accepted.tr()} (${acceptedOrders.length})'),
                Tab(text: '${LocaleKeys.completed.tr()} (${completedOrders.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrderList(context, pendingOrders),
                _buildOrderList(context, acceptedOrders),
                _buildOrderList(context, completedOrders),
              ],
            ),
          ),
          if (cancelledOrders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: Colors.red),
                ),
                child: TextButton(
                  onPressed: () {
                    _showCancelledOrdersDialog(context, cancelledOrders);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cancel, color: Colors.red),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${LocaleKeys.view_canceled_orders.tr()} (${cancelledOrders.length})',
                          style: const TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelledOrdersDialog(BuildContext context, List<CreatorOrder> orders) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.cancel, color: Colors.red),
              const SizedBox(width: 5),
              Text(LocaleKeys.canceled_orders.tr(), style: const TextStyle(fontSize: 15)),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: orders.isEmpty
                ? Center(child: Text(LocaleKeys.no_canceled_orders.tr()))
                : ListView.builder(
              shrinkWrap: true,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text('${LocaleKeys.order.tr()} #${order.orderId}'),
                    subtitle: Text('${LocaleKeys.total.tr()} \$${order.totalAmount.toStringAsFixed(2)}'),
                    trailing: Text(order.status.toUpperCase(), style: const TextStyle(color: Colors.red)),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.close.tr(), style: TextStyle(color: textColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderList(BuildContext context, List<CreatorOrder> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.no_orders_found.tr(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _fetchOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(context, order);
        },
      ),
    );
  }


  Widget _buildOrderCard(BuildContext context, CreatorOrder order) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(order.status).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          _showOrderDetails(context, order);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${LocaleKeys.customer.tr()}: ${order.userFirstName ?? LocaleKeys.unknown.tr()}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (order.status.toLowerCase() == 'accepted' || order.status.toLowerCase() == 'completed')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${LocaleKeys.phone.tr()}: ${order.userPhoneNumber ?? LocaleKeys.not_provided.tr()}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '${LocaleKeys.address.tr()}: ${order.shippingAddress ?? LocaleKeys.not_provided.tr()}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          )
                        else
                          Text(
                            LocaleKeys.contact_info_upon_acceptance.tr(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.total.tr(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        LocaleKeys.date.tr(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(order.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
                _buildActionButtons(context, order),
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
          style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildOrderDetailsContent(BuildContext context, CreatorOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.order_id.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            Text('#${order.orderId}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(LocaleKeys.status.tr()),
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
          ],
        ),
        const SizedBox(height: 16),
        Text(
          LocaleKeys.customer_info.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),

        _buildDetailRow(LocaleKeys.name.tr(), order.userFirstName ?? LocaleKeys.unknown.tr(), isName: true),
        _buildDetailRow(LocaleKeys.address.tr(), order.shippingAddress ?? LocaleKeys.not_provided.tr()),

        if (order.status.toLowerCase() == 'completed' || order.status.toLowerCase() == 'completed')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(LocaleKeys.phone.tr(), order.userPhoneNumber ?? LocaleKeys.not_provided.tr()),
              _buildDetailRow(LocaleKeys.payment_method.tr(), order.paymentMethod ?? LocaleKeys.not_provided.tr()),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
            child: _buildDetailRow(LocaleKeys.contact_info.tr(), LocaleKeys.available_upon_payment.tr(), isBold: true),
          ),

        const SizedBox(height: 16),
        Text(
          LocaleKeys.order_items.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),

        ...order.orderItems.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${item.quantity}x ${item.itemName ?? LocaleKeys.unknown_item.tr()}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('\$${(item.pricePerItem * item.quantity).toStringAsFixed(2)}'),
                ],
              ),

              // Extras
              if (item.extrasDetails != null && item.extrasDetails!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: item.extrasDetails!.map((extra) {
                        return Text(
                          '+ ${extra['name'] ?? LocaleKeys.extra.tr()} (\$${(extra['price'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'})',
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                        );
                      }).toList(),
                    ),
                  ),
                ),

              // Special Request
              if (item.specialRequest != null && item.specialRequest!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sticky_note_2_rounded, size: 18, color: textColor),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '${LocaleKeys.note.tr()}: ${item.specialRequest}',
                            style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        )),

        const Divider(height: 24),

        _buildDetailRow(LocaleKeys.subtotal.tr(), '\$${order.totalAmount.toStringAsFixed(2)}'),
        _buildDetailRow(LocaleKeys.total.tr(), '\$${order.totalAmount.toStringAsFixed(2)}', isBold: true),

        const SizedBox(height: 8),

        _buildDetailRow(LocaleKeys.order_date.tr(), DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isName = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: isName ? 1 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CreatorOrder order) {
    if (order.status.toLowerCase() == 'pending') {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.black),
                label: Text(LocaleKeys.accept_order.tr(), style: const TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showDeliveryTimeDialog(context, order),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined, size: 20),
                label: Text(LocaleKeys.cancel_order.tr()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _confirmCancellation(context, order);
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _confirmCancellation(BuildContext context, CreatorOrder order) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(LocaleKeys.confirm_cancellation.tr(), style: const TextStyle(fontSize: 16)),
          content: Text(LocaleKeys.confirm_cancellation_question.tr(), style: const TextStyle(fontSize: 15)),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleKeys.no.tr(), style: TextStyle(color: textColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(LocaleKeys.yes_cancel.tr(), style: const TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.pop(context); // Close bottom sheet
                final token = CacheHelper.getData(key: 'token');
                if (token != null) {
                  await context.read<CreatorOrderCubit>().acceptOrCancelOrder(
                    orderId: order.orderId,
                    status: 'canceled',
                    token: token,
                    deliveryTimeValue: null,
                    deliveryTimeUnit: null,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeliveryTimeDialog(BuildContext context, CreatorOrder order) {
    _deliveryTimeController.clear();
    TimeUnit _dialogSelectedTimeUnit = TimeUnit.minutes;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delivery_dining, size: 25, color: Colors.grey),
              const SizedBox(width: 10),
              Text(
                LocaleKeys.set_delivery_time.tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _deliveryTimeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.time_value.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ChoiceChip(
                            label: Text(LocaleKeys.minutes.tr()),
                            selected: _dialogSelectedTimeUnit == TimeUnit.minutes,
                            onSelected: (selected) {
                              setState(() {
                                _dialogSelectedTimeUnit = TimeUnit.minutes;
                              });
                            },
                          ),
                          ChoiceChip(
                            label: Text(LocaleKeys.hours.tr()),
                            selected: _dialogSelectedTimeUnit == TimeUnit.hours,
                            onSelected: (selected) {
                              setState(() {
                                _dialogSelectedTimeUnit = TimeUnit.hours;
                              });
                            },
                          ),
                        ],
                      ),
                      ChoiceChip(
                        label: Text(LocaleKeys.days.tr()),
                        selected: _dialogSelectedTimeUnit == TimeUnit.days,
                        onSelected: (selected) {
                          setState(() {
                            _dialogSelectedTimeUnit = TimeUnit.days;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(LocaleKeys.cancel.tr(), style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                final value = double.tryParse(_deliveryTimeController.text);
                if (value != null && value > 0) {
                  final token = CacheHelper.getData(key: 'token');
                  if (token != null) {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                    await context.read<CreatorOrderCubit>().acceptOrCancelOrder(
                      orderId: order.orderId,
                      status: 'accepted',
                      token: token,
                      deliveryTimeValue: value,
                      deliveryTimeUnit: _dialogSelectedTimeUnit.toString().split('.').last,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(LocaleKeys.order_accepted_successfully.tr()),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(LocaleKeys.enter_valid_delivery_time.tr())),
                  );
                }
              },
              child: const Text('Confirm', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}