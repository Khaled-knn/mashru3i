import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mashrou3i/core/theme/color.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../core/theme/icons_broken.dart';
import '../../../../../data/models/items_model/creator_item_model.dart';
import '../../../../../data/models/items_model/freelancer_item_details.dart';
import '../../../../../data/models/items_model/restaurant_item_details.dart';
import '../../../../../data/models/items_model/hc_item_details.dart';
import '../../../../../data/models/items_model/hs_item_details.dart';
import '../../../../../data/models/items_model/teaching_item_details.dart';

import '../../../../widgets/compnents.dart';
import '../../add_items_screen/cubit/get_item_cubit.dart';
import '../../add_items_screen/cubit/get_item_state.dart';
import '../../add_items_screen/widgets/edit_item_screen.dart';

class RecentItems extends StatelessWidget {
  const RecentItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(LocaleKeys.recentItems.tr(), style: TextStyle(fontSize: 18)),
        leading: popButton(context),
      ),
      body: BlocBuilder<GetItemsCubit, GetItemsState>(
        builder: (context, state) {
          List<CreatorItemModel> items = [];

          if (state is GetItemsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GetItemsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(LocaleKeys.errorLoadingItems.tr()),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.read<GetItemsCubit>().fetchMyItems(),
                    child: Text(LocaleKeys.retry.tr()),
                  ),
                ],
              ),
            );
          }

          if (state is GetItemsSuccess) {
            items = state.items.reversed.toList();
          }

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2, size: 50, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(LocaleKeys.noItemsFound.tr()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/AddItemsScreen'),
                    child: Text(LocaleKeys.addNewItem.tr()),
                  ),
                ],
              ),
            );
          }

          int? currentCreatorProfessionId = items.isNotEmpty ? items[0].categoryId : null;

          List<DataColumn> columns = [
            DataColumn(label: Text(LocaleKeys.id.tr())),
            DataColumn(label: Text(LocaleKeys.name.tr())),
            DataColumn(label: Text(LocaleKeys.price.tr())),
          ];

          if (currentCreatorProfessionId == 5) {
            columns.add(DataColumn(label: Text(LocaleKeys.portfolioLink.tr())));
          } else if (currentCreatorProfessionId == 6) {
            columns.add(DataColumn(label: Text(LocaleKeys.driveLink.tr())));
          } else {
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

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<GetItemsCubit>().fetchMyItems();
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                  child: DataTable(
                    dataRowMinHeight: 60,
                    dataRowMaxHeight: 80,
                    columnSpacing: 20,
                    horizontalMargin: 12,
                    columns: columns,
                    rows: items.map((item) {
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
                      } else if (item.categoryId == 6) {
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
                      } else if (currentCreatorProfessionId == 6) {
                        if (item.categoryId == 6 && tutoringDetails != null && tutoringDetails.googleDriveLink != null && tutoringDetails.googleDriveLink!.isNotEmpty) {
                          fourthColumnText = tutoringDetails.googleDriveLink!;
                        } else {
                          fourthColumnText = 'N/A';
                        }
                      } else {
                        if (item.description != null && item.description!.isNotEmpty) {
                          fourthColumnText = item.description!;
                        } else if (item.categoryId == 3 && hsDetails != null && hsDetails.workingTime != null && hsDetails.workingTime!.isNotEmpty) {
                          fourthColumnText = hsDetails.workingTime!;
                        }else {
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
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(
                              IconBroken.Edit,
                              color: textColor,
                            ),
                            onPressed: () => _editItem(context, item),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(
                              IconBroken.Delete,
                              color: Colors.red[800],
                            ),
                            onPressed: () => _confirmDelete(context, item.id),
                          ),
                        ),
                      ]);
                      return DataRow(cells: cells);
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String shortText(String? text, {int maxChars = 10}) {
    if (text == null) return '';
    return text.length > maxChars ? '${text.substring(0, maxChars)}...' : text;
  }

  void _showItemDetails(BuildContext context, CreatorItemModel item) {
    final freelancerDetails = item.details is FreelancerItemDetails
        ? item.details as FreelancerItemDetails
        : null;
    final restaurantDetails = item.details is RestaurantItemDetails ? item.details as RestaurantItemDetails : null;
    final hcDetails = item.details is HcItemDetails ? item.details as HcItemDetails : null;
    final hsDetails = item.details is HsItemDetails ? item.details as HsItemDetails : null;
    final tutoringDetails = item.details is TeachingItemDetails ? item.details as TeachingItemDetails : null;

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

              Builder(
                builder: (BuildContext innerContext) {
                  String label = LocaleKeys.description.tr();
                  String value = item.description ?? 'N/A';

                  if (item.categoryId == 5 && freelancerDetails != null) {
                    label = LocaleKeys.portfolioLinks.tr();
                    if (freelancerDetails.portfolioLinks != null && freelancerDetails.portfolioLinks!.isNotEmpty) {
                      value = freelancerDetails.portfolioLinks!.join(', ');
                    } else {
                      value = 'N/A';
                    }
                  } else if (item.categoryId == 6 && tutoringDetails != null) {
                    label = LocaleKeys.driveLink.tr();
                    if (tutoringDetails.googleDriveLink != null && tutoringDetails.googleDriveLink!.isNotEmpty) {
                      value = tutoringDetails.googleDriveLink!;
                    } else {
                      value = 'N/A';
                    }
                  } else if (item.categoryId == 3 && hsDetails != null && hsDetails.workingTime != null && hsDetails.workingTime!.isNotEmpty) {
                    label = LocaleKeys.workingTime.tr();
                    value = hsDetails.workingTime!;
                  }

                  return Text('$label: $value');
                },
              ),
              const SizedBox(height: 10),

              Builder(
                builder: (BuildContext innerContext) {
                  String label = LocaleKeys.time.tr();
                  String value = 'N/A';

                  if (item.categoryId == 1 || item.categoryId == 2) {
                    if (restaurantDetails != null && restaurantDetails.time != null && restaurantDetails.time!.isNotEmpty) {
                      value = restaurantDetails.time!;
                    }
                  } else if (item.categoryId == 4) {
                    if (hcDetails != null && hcDetails.time != null && hcDetails.time!.isNotEmpty) {
                      value = hcDetails.time!;
                    }
                  } else if (item.categoryId == 5) {
                    label = LocaleKeys.workingTime.tr();
                    if (freelancerDetails != null && freelancerDetails.workingTime != null && freelancerDetails.workingTime!.isNotEmpty) {
                      value = freelancerDetails.workingTime!;
                    }
                  } else if (item.categoryId == 6) {
                    label = LocaleKeys.courseDuration.tr();
                    if (tutoringDetails != null && tutoringDetails.courseDuration != null && tutoringDetails.courseDuration!.isNotEmpty) {
                      value = tutoringDetails.courseDuration!;
                    }
                  }

                  if (item.categoryId != 3) {
                    return Text('$label: $value');
                  }
                  return const SizedBox.shrink();
                },
              ),

              if (freelancerDetails != null) ...[
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
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not open link: $link')),
                              );
                            }
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

              if (tutoringDetails != null) ...[
                if (tutoringDetails.syllabus != null && tutoringDetails.syllabus!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text('${LocaleKeys.syllabus.tr()}: ${tutoringDetails.syllabus}'),
                    ],
                  ),
                if (tutoringDetails.googleDriveLink != null && tutoringDetails.googleDriveLink!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(LocaleKeys.driveLink.tr(), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () async {
                          final uri = Uri.parse(tutoringDetails.googleDriveLink!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not open Google Drive link: ${tutoringDetails.googleDriveLink}')),
                            );
                          }
                        },
                        child: Text(
                          tutoringDetails.googleDriveLink!,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],

              if (hsDetails != null) ...[
                if (hsDetails.behanceLink != null && hsDetails.behanceLink!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(LocaleKeys.behanceLink.tr(), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () async {
                          final uri = Uri.parse(hsDetails.behanceLink!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not open Behance link: ${hsDetails.behanceLink}')),
                            );
                          }
                        },
                        child: Text(
                          hsDetails.behanceLink!,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (hsDetails.portfolioLinks != null && hsDetails.portfolioLinks!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(LocaleKeys.portfolioLinks.tr(), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      ...hsDetails.portfolioLinks!.map((link) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: InkWell(
                          onTap: () async {
                            final uri = Uri.parse(link);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not open link: $link')),
                              );
                            }
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

              if (restaurantDetails != null) ...[
                if (restaurantDetails.ingredients != null && restaurantDetails.ingredients!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(LocaleKeys.ingredients.tr(), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      ...restaurantDetails.ingredients!.map((ing) => Text('- ${ing.name} (${ing.price}\$)')).toList(),
                    ],
                  ),
              ],

              if (hcDetails != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(LocaleKeys.ingredients.tr(), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 5),
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
  }

  void _showFullImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image),
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
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.confirmDelete.tr()),
        content: Text(LocaleKeys.areYouSureDeleteItem.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GetItemsCubit>().deleteItem(itemId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(LocaleKeys.itemDeleted.tr())),
              );
            },
            child: Text(
              LocaleKeys.delete.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}