import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/presentation/screens/creator/add_items_screen/widgets/add_item_form.dart';
import '../../../../core/theme/LocaleKeys.dart';
import '../../../widgets/compnents.dart';
import 'cubit/add_item_cubit.dart';
import 'cubit/add_item_state.dart';
class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ItemCubit(),
      child: BlocListener<ItemCubit, ItemState>(
        listener: (context, state) {
          if (state is ItemSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                content: Text('Item has been added successfully. 1 points have been deducted.' , style: TextStyle(color: Colors.black),),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
            Navigator.pop(context);
          } else if (state is ItemFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add item: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Image.asset('assets/images/logo.png' , width: 150,),
            leading: popButton(context),

          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const AddItemForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              popButton(context),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
            width: double.infinity,
            height: 45,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Text(
                LocaleKeys.deduce5Points.tr(),
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
