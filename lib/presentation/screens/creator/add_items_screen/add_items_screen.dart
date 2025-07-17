// import 'dart:io';
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mashrou3i_app/core/theme/LocaleKeys.dart';
// import 'package:mashrou3i_app/presentation/screens/creator/dashboard_screen/logic/dashboard_cibit.dart';
// import 'package:mashrou3i_app/presentation/screens/creator/dashboard_screen/logic/dashboard_states.dart';
// import '../../../../core/network/local/cach_helper.dart';
// import '../../../widgets/compnents.dart';
// import '../../../widgets/coustem_form_input.dart';
// import '../../../widgets/custom_button.dart';
//
// class AddItemsScreen extends StatefulWidget {
//   final DashBoardCubit dashboardCubit;
//   const AddItemsScreen({super.key, required this.dashboardCubit});
//
//   @override
//   State<AddItemsScreen> createState() => _AddItemsScreenState();
// }
// class _AddItemsScreenState extends State<AddItemsScreen> {
//   List<File?> _selectedImages = [];
//   final ImagePicker _picker = ImagePicker();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController priceController = TextEditingController();
//   TextEditingController timeController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   DashBoardCubit? _dashboardCubit;
//   int? _professionId;
//   @override
//   void initState() {
//     super.initState();
//     _loadProfessionId();
//   }
//   void _loadProfessionId() {
//     if (widget.dashboardCubit.state is ProfileLoaded) {
//       _professionId = (widget.dashboardCubit.state as ProfileLoaded).profile?.professionId;
//     }
//     if (_professionId == null) {
//       _professionId = CacheHelper.getData(key: 'professionId');
//     }
//
//     if (_professionId == null) {
//       widget.dashboardCubit.getProfileData();
//     }
//   }
//   Future<void> _pickImage() async {
//     final XFile? pickedFile = await _picker.pickImage(
//       source: ImageSource.gallery,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImages.add(File(pickedFile.path));
//       });
//     }
//   }
//
//   Future<void> _pickMultipleImages() async {
//     final List<XFile>? pickedFiles = await _picker.pickMultiImage();
//     if (pickedFiles != null) {
//       setState(() {
//         _selectedImages.addAll(
//           pickedFiles.map((xFile) => File(xFile.path)).toList(),
//         );
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: BlocConsumer<DashBoardCubit, DashBoardStates>(
//         bloc: widget.dashboardCubit,
//         listener: (context, state) {
//           if (state is ProfileLoaded) {
//             setState(() {
//               _professionId = state.profile.professionId;
//               CacheHelper.saveData(key: 'professionId', value: _professionId);
//             });
//           }
//         },
//         builder: (context, state) {
//           if (state is ProfileLoaded) {
//             _professionId = state.profile.professionId;
//           }
//           String labelName = '';
//           String description = 'Description';
//
//           if (_professionId == 1 || _professionId == 2) {
//             labelName = 'Name of food';
//             description = 'Ingredients';
//           } else if (_professionId == 3) {
//             labelName = 'Name of HS';
//           } else if (_professionId == 4) {
//             labelName = 'Name of HS';
//           } else {
//             labelName = 'Name of serves';
//           }
//           return Scaffold(
//             body: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: popButton(context),
//                       ),
//                       Center(
//                         child: Image(
//                           width: 200,
//                           image: const AssetImage('assets/images/logo.png'),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     width: double.infinity,
//                     height: 45,
//                     color: Theme.of(context).primaryColor,
//                     child: Center(child: Text(LocaleKeys.deduce5Points.tr())),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Column(
//                           children: [
//                             Text(
//                               LocaleKeys.addNewItem.tr(),
//                               style: Theme.of(context).textTheme.titleSmall,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         CustomFormInput(
//                           controller: nameController,
//                           label: labelName,
//                           validator: (value) {},
//                           keyboardType: TextInputType.text,
//                           fillColor: Colors.transparent,
//                           borderColor: Colors.grey,
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: CustomFormInput(
//                                 controller: nameController,
//                                 label: labelName,
//                                 validator: (value) {},
//                                 keyboardType: TextInputType.text,
//                                 fillColor: Colors.transparent,
//                                 borderColor: Colors.grey,
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Container(
//                               padding: const EdgeInsets.all(18),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(20),
//                                 border: Border.all(color: Colors.grey),
//                                 color: Colors.transparent,
//                               ),
//                               child: const Text(
//                                 '\$',
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Text(
//                           LocaleKeys.choosePictures,
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                         SizedBox(height: 10),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: GestureDetector(
//                                 onTap:
//                                     _selectedImages.length < 2
//                                         ? _pickImage
//                                         : null,
//                                 child: Container(
//                                   width: 80,
//                                   height: 100,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child:
//                                       _selectedImages.isNotEmpty
//                                           ? ClipRRect(
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                             child: Image.file(
//                                               _selectedImages[0]!,
//                                               fit: BoxFit.cover,
//                                             ),
//                                           )
//                                           : Icon(
//                                             Icons.image,
//                                             color: Colors.grey,
//                                           ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: GestureDetector(
//                                 onTap:
//                                     _selectedImages.length < 2
//                                         ? _pickImage
//                                         : null,
//                                 child: Container(
//                                   width: 80,
//                                   height: 100,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child:
//                                       _selectedImages.length > 1
//                                           ? ClipRRect(
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                             child: Image.file(
//                                               _selectedImages[1]!,
//                                               fit: BoxFit.cover,
//                                             ),
//                                           )
//                                           : Icon(
//                                             Icons.image,
//                                             color: Colors.grey,
//                                           ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             GestureDetector(
//                               onTap: _pickMultipleImages,
//                               child: Container(
//                                 width: 60,
//                                 height: 60,
//                                 decoration: BoxDecoration(
//                                   color: Theme.of(context).primaryColor,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.add,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         if (_professionId == 1 ||
//                             _professionId == 2 ||
//                             _professionId == 4)
//                           CustomFormInput(
//                             controller: timeController,
//                             label: 'Time',
//                             validator: (value) {},
//                             keyboardType: TextInputType.text,
//                             fillColor: Colors.transparent,
//                             borderColor: Colors.grey,
//                             onTap: () {
//                               showTimePicker(
//                                 context: context,
//                                 initialTime: TimeOfDay.now(),
//                                 barrierColor: Theme.of(context).primaryColor,
//                                 builder: (BuildContext context, Widget? child) {
//                                   return Theme(
//                                     data: ThemeData.light().copyWith(
//                                       primaryColor:
//                                           Theme.of(
//                                             context,
//                                           ).primaryColor, // Change primary color
//                                       hintColor:
//                                           Theme.of(
//                                             context,
//                                           ).primaryColor, // Change accent color
//                                       colorScheme: ColorScheme.light(
//                                         primary: Theme.of(context).primaryColor,
//                                       ),
//                                       buttonTheme: ButtonThemeData(
//                                         textTheme: ButtonTextTheme.primary,
//                                       ),
//                                     ),
//                                     child: child!,
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                         const SizedBox(height: 20),
//                         if (_professionId == 1 ||
//                             _professionId == 2 ||
//                             _professionId == 4 ||
//                             _professionId == 3)
//                           CustomFormInput(
//                             controller: descriptionController,
//                             label: description,
//                             validator: (value) {},
//                             keyboardType: TextInputType.text,
//                             borderColor: Colors.grey,
//                             maxLines: 3,
//                           ),
//                         const SizedBox(height: 20),
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: Colors.white,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.5),
//                                 spreadRadius: 3,
//                                 blurRadius: 5,
//                                 offset: Offset(0, 3),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Theme(
//                                   data: Theme.of(
//                                     context,
//                                   ).copyWith(dividerColor: Colors.transparent),
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 5,
//                                     ),
//                                     child: ExpansionTile(
//                                       title: Text(
//                                         'You can only add 3 items',
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey[400],
//                                         ),
//                                       ),
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               flex: 3,
//                                               child: CustomFormInput(
//                                                 controller: timeController,
//                                                 label: 'item',
//                                                 validator: (value) {
//                                                   if (value!.isEmpty) {
//                                                     return 'time must be not empty';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                                 borderRadius: 10,
//                                               ),
//                                             ),
//                                             SizedBox(width: 10),
//                                             Expanded(
//                                               flex: 2,
//                                               child: CustomFormInput(
//                                                 controller: timeController,
//                                                 label: 'item',
//                                                 validator: (value) {
//                                                   if (value!.isEmpty) {
//                                                     return 'time must be not empty';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                                 borderRadius: 10,
//                                               ),
//                                             ),
//                                             SizedBox(width: 10),
//                                             FloatingActionButton(
//                                               mini: true,
//                                               backgroundColor:
//                                                   Theme.of(
//                                                     context,
//                                                   ).primaryColor,
//                                               onPressed: () {},
//                                               child: Icon(
//                                                 Icons.add,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(height: 10),
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               flex: 3,
//                                               child: CustomFormInput(
//                                                 controller: timeController,
//                                                 label: 'item',
//                                                 validator: (value) {
//                                                   if (value!.isEmpty) {
//                                                     return 'time must be not empty';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                                 borderRadius: 10,
//                                               ),
//                                             ),
//                                             SizedBox(width: 10),
//                                             Expanded(
//                                               flex: 2,
//                                               child: CustomFormInput(
//                                                 controller: timeController,
//                                                 label: 'item',
//                                                 validator: (value) {
//                                                   if (value!.isEmpty) {
//                                                     return 'time must be not empty';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                                 borderRadius: 10,
//                                               ),
//                                             ),
//                                             SizedBox(width: 10),
//                                             FloatingActionButton(
//                                               mini: true,
//                                               backgroundColor:
//                                                   Theme.of(
//                                                     context,
//                                                   ).primaryColor,
//                                               onPressed: () {},
//                                               child: Icon(
//                                                 Icons.add,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(height: 10),
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               flex: 3,
//                                               child: CustomFormInput(
//                                                 controller: timeController,
//                                                 label: 'item',
//                                                 validator: (value) {
//                                                   if (value!.isEmpty) {
//                                                     return 'time must be not empty';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                                 borderRadius: 10,
//                                               ),
//                                             ),
//                                             SizedBox(width: 10),
//                                             Expanded(
//                                               flex: 2,
//                                               child: CustomFormInput(
//                                                 controller: timeController,
//                                                 label: 'item',
//                                                 validator: (value) {
//                                                   if (value!.isEmpty) {
//                                                     return 'time must be not empty';
//                                                   }
//                                                   return null;
//                                                 },
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                                 borderRadius: 10,
//                                               ),
//                                             ),
//                                             SizedBox(width: 10),
//                                             FloatingActionButton(
//                                               mini: true,
//                                               backgroundColor:
//                                                   Theme.of(
//                                                     context,
//                                                   ).primaryColor,
//                                               onPressed: () {},
//                                               child: Icon(
//                                                 Icons.add,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               IconButton(
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder:
//                                         (BuildContext context) =>
//                                             AlertDialog.adaptive(
//                                               title: Text('INFO HERE'),
//                                               actions: [
//                                                 TextButton(
//                                                   onPressed: () {
//                                                     Navigator.pop(context);
//                                                   },
//                                                   child: Text(
//                                                     'OK',
//                                                     style: TextStyle(
//                                                       color:
//                                                           Theme.of(
//                                                             context,
//                                                           ).primaryColor,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                   );
//                                 },
//                                 icon: Icon(Icons.info, color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: CustomButton(
//                                 onPressed: () {},
//                                 color: Color.fromRGBO(49, 49, 49, 1),
//                                 textColor: Theme.of(context).primaryColor,
//                                 text: 'Save',
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: CustomButton(
//                                 onPressed: () {},
//                                 color: Color.fromRGBO(172, 190, 177, 1),
//                                 textColor: Colors.black,
//                                 text: 'Cancel',
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
