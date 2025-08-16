import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/core/theme/color.dart'; // Assuming textColor is defined here
import 'package:mashrou3i/data/models/user_order_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/helper/user_data_manager.dart';
import 'orders/user_order_cubit.dart';
import 'orders/user_order_statrs.dart';
import 'orders/whish_service.dart';

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({super.key});

  @override
  State<UserOrdersScreen> createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  String _currentFilter = 'all'.tr();

  @override
  void initState() {
    super.initState();
    context.read<UserOrdersCubit>().fetchUserOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('My-Orders'.tr(), style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: _buildFilterTabs(),
        ),
      ),
      body: BlocConsumer<UserOrdersCubit, UserOrdersState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is UserOrdersInitial ||
              state is UserOrdersLoading ||
              state is UserOrdersUpdating) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserOrdersLoaded) {
            final filteredOrders = state.orders.where((order) {
              if (_currentFilter == 'all') {
                return true;
              }
              return order.status.toLowerCase() == _currentFilter;
            }).toList();

            if (filteredOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(width: 2, color: textColor),
                      ),
                      child: Icon(
                        Icons.shopping_bag,
                        size: 40,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _currentFilter == 'all'
                          ? "Place your first order!".tr()
                          : "No $_currentFilter orders.".tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<UserOrdersCubit>().fetchUserOrders();
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return _buildOrderCard(order, context);
                },
              ),
            );
          } else if (state is UserOrdersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserOrdersCubit>().fetchUserOrders();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildFilterTabs() {
    final List<Map<String, String>> filters = [
      {'label': 'All'.tr(), 'value': 'all'},
      {'label': 'Pending'.tr(), 'value': 'pending'},
      {'label': 'Accepted'.tr(), 'value': 'accepted'},
      {'label': 'Completed'.tr(), 'value': 'completed'},
      {'label': 'Canceled'.tr(), 'value': 'canceled'},
    ];

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _currentFilter == filter['value'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(filter['label']!, style: const TextStyle(fontSize: 14)),
                selected: isSelected,
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentFilter = filter['value']!;
                    });
                  }
                },
                labelStyle: TextStyle(
                  color: isSelected ? textColor : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(UserOrder order, BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (order.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusText = 'Pending'.tr();
        break;
      case 'accepted':
        statusColor = Colors.teal;
        statusIcon = Icons.delivery_dining;
        statusText = 'Accepted'.tr();
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed'.tr();
        break;
      case 'canceled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Canceled'.tr();
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = order.status;
    }

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: statusColor,
              width: 4,
            ),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Date'.tr(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.createdAt),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Chip(
                      backgroundColor: statusColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'View Details'.tr(),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date.toLocal());
  }

  void _showOrderDetails(BuildContext context, UserOrder order) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBottomSheetHeader(context),
                const SizedBox(height: 16),
                _buildDetailRow('Order ID:'.tr(), '#${order.orderId}'),
                _buildDetailRow('Status:'.tr(), order.status.toUpperCase(),
                    valueColor: _getStatusColor(order.status),
                    isValueBold: true),
                _buildDetailRow('Payment Status:'.tr(), order.paymentStatus.toUpperCase(),
                    valueColor:
                    order.paymentStatus.toLowerCase() == 'paid' ? Colors.green : Colors.orange),
                _buildDetailRow('Order Date:'.tr(), _formatDate(order.createdAt)),
                const Divider(height: 24),
                Text('Order Items:'.tr(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                const SizedBox(height: 8),
                ...order.orderItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                                '${item.quantity}x ${item.itemName ?? 'Unknown item'}',
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          Text('\$${(item.pricePerItem * item.quantity).toStringAsFixed(2)}'),
                        ],
                      ),
                      if (item.specialRequest != null && item.specialRequest!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                          child: Text(
                            'Note: ${item.specialRequest}',
                            style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600]),
                          ),
                        ),
                      if (item.extrasDetails != null && item.extrasDetails!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: item.extrasDetails!.map((extra) {
                              return Text(
                                '+ ${extra['name'] ?? 'Extra'} (\$${(extra['price'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'})',
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                )),
                const Divider(height: 24),
                _buildDetailRow('Total Amount:'.tr(), '\$${order.totalAmount.toStringAsFixed(2)}',
                    isBold: true),
                const SizedBox(height: 16),
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
          'Order Details'.tr(),
          style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, Color? valueColor, bool isValueBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
                  color: valueColor ?? Colors.black)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, UserOrder order) {
    if (order.status.toLowerCase() == 'accepted' &&
        order.paymentStatus.toLowerCase() == 'unpaid') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.payment, size: 20, color: Colors.black),
          label: const Text('Confirm Payment', style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _showPaymentOptionsDialog(context, order),
        ),
      );
    } else if (order.status.toLowerCase() == 'completed' &&
        order.paymentStatus.toLowerCase() == 'paid') {
      return Center(
        child: Text(
          'Order completed and paid!'.tr(),
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      );
    } else if (order.status.toLowerCase() == 'canceled') {
      return Center(
        child: Text(
          'This order has been canceled.'.tr(),
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showPaymentOptionsDialog(BuildContext context, UserOrder order) {
    if (order.creatorPaymentMethods.isEmpty) {
      showMainSnackBar(context, SnackBar(
        content: Text('No payment methods available for this creator.'.tr()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payment),
                    const SizedBox(width: 8),
                    Text(
                      'Select Payment Method'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...order.creatorPaymentMethods.map((method) {
                  String imagePath;
                  switch (method.method.toLowerCase()) {
                    case 'wishmoney':
                      imagePath = 'assets/images/whish.png';
                      break;
                    case 'cash_on_delivery':
                      imagePath = 'assets/images/cash.png';
                      break;
                    case 'omt':
                      imagePath = 'assets/images/omt.png';
                      break;
                    default:
                      imagePath = 'assets/images/cash.png';
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      border: Border.all(color: textColor, width: 1),
                    ),
                    child: ListTile(
                      leading: Image.asset(
                        imagePath,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.payment, size: 40),
                      ),
                      title: Text(
                        method.method.toUpperCase().replaceAll('_', ' '),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: method.accountInfo != null && method.accountInfo!.isNotEmpty
                          ? Text(
                        method.accountInfo!,
                        style: TextStyle(color: Theme.of(context).hintColor),
                      )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _confirmPaymentAction(context, order.orderId, method.method, order: order);
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void showMainSnackBar(BuildContext context, SnackBar snackBar) {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger != null && context.mounted) {
      scaffoldMessenger.showSnackBar(snackBar);
    }
  }




  void _confirmPaymentAction(
      BuildContext context, int orderId, String paymentMethod, {UserOrder? order}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Confirm Payment'.tr(), style: const TextStyle(fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to confirm payment with:'.tr()),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                paymentMethod,
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: Theme.of(dialogContext).primaryColor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel'.tr(), style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).primaryColor,
            ),
            child: Text('Confirm'.tr(), style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (loadingCtx) => const Center(child: CircularProgressIndicator()),
    );

    final rootNavigator = Navigator.of(context, rootNavigator: true);

    // Whish payment
    if (paymentMethod.toLowerCase() == 'wishmoney') {
      try {
        UserOrder? thisOrder = order;
        if (thisOrder == null) {
          final state = context.read<UserOrdersCubit>().state;
          if (state is UserOrdersLoaded) {
            thisOrder = state.orders.firstWhere(
                  (o) => o.orderId == orderId,
              orElse: () => throw Exception("Order not found"),
            );
          }
        }
        if (thisOrder == null) throw Exception("Order not found");

        final url = await WhishService.generateWhishPaymentUrl(
          amount: thisOrder.totalAmount,
          currency: "USD",
          invoice: "Order #$orderId",
          externalId: orderId,
          successUrl: "https://mashru3i.com/success",
          failureUrl: "https://mashru3i.com/failure",
        );

        if (rootNavigator.canPop()) rootNavigator.pop(); // Dismiss loading
        if (!mounted) return;

        if (url != null && url.isNotEmpty) {
          await launchUrl(
            url.startsWith('http') ? Uri.parse(url) : Uri.parse('https://$url'),
            mode: LaunchMode.externalApplication,
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Whish returned empty URL'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (rootNavigator.canPop()) rootNavigator.pop(); // Dismiss loading
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Whish Payment Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Other payment methods
    try {
      await context.read<UserOrdersCubit>().confirmPayment(
        orderId: orderId,
        paymentMethod: paymentMethod,
      );

      if (rootNavigator.canPop()) rootNavigator.pop(); // Dismiss loading
      if (!mounted) return;

      final user = UserDataManager.getUserModel();
      user?.points++;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment confirmed successfully!'.tr(), style: const TextStyle(color: Colors.black)),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (rootNavigator.canPop()) rootNavigator.pop(); // Dismiss loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to confirm payment: ${e.toString()}'.tr()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
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