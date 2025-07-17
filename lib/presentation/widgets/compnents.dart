import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mashrou3i/core/theme/icons_broken.dart';
import '../../core/theme/LocaleKeys.dart';
import 'coustem_form_input.dart';
import 'custom_button.dart';


Widget withNav(context) => Positioned(
  top: 0,
  child: Container(
    width: MediaQuery.of(context).size.width,
    height: 200,
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(50),
        bottomLeft: Radius.circular(50),
      ),
    ),
  ),
);
Widget popButton(BuildContext context) => Padding(

  padding: const EdgeInsets.all(8.0),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      color: Color.fromRGBO(255, 255, 255, 0.5),
    ),
    child: IconButton(
      onPressed: () {
        context.pop(); // GoRouter-friendly
      },
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: 18,
      ),
    ),
  ),
);
Widget BackgroundForm({
  required Widget child ,
  double ? height ,
  double paddingHorizontal = 20,
  double paddingVertical = 40,
  double width = double.infinity,
  bool mini = false ,
  Key ? key,

})=>Container(
    key:key,
    width: mini ? null : double.infinity,
    height: height,
    padding: EdgeInsets.symmetric(
      horizontal: paddingHorizontal,
      vertical: paddingVertical,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,

    ),
    child: child,
);
void showErrorDialog(BuildContext context, String errorMessage) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.info,
    animType: AnimType.scale,
    title: 'Error',
    desc: errorMessage,
    btnOkOnPress: () {},
    btnOkColor: Theme.of(context).primaryColor,
    btnCancelColor: Colors.grey,
    customHeader: Icon(
      Icons.error,
      size: 60,
      color: Theme.of(context).primaryColor,
    ),
  ).show();
}
Widget ChangeStoreName (context,cubit,storeController)=> InkWell(
  onTap: () {
    showDialog(

      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          LocaleKeys.editStoreName.tr(),
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding:  EdgeInsetsDirectional.only(
                start: 10,
                bottom: 10,
                top: 10,
                end: 0,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.youHave.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        '${cubit.creatorProfile?.tokens ?? 0}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const Image(
                    image: AssetImage('assets/images/coin.png'),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomFormInput(
              controller: storeController,
              label: 'store name',
              validator: (value) {
                if(value!.isEmpty){
                  return 'store name must be not empty';
                }
                return null;
              },
              keyboardType: TextInputType.text,
              borderColor: Colors.grey,
              fillColor: Colors.grey[200],
              borderRadius: 5,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: AlertDialog(
                            title: Text(
                                LocaleKeys.areYouSureChangeName.tr(),
                                style:TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                            ),
                            actions:
                            [
                              Container(

                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Theme.of(context).primaryColor),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        LocaleKeys.tokenDeductionWarning.tr(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      child:Text(
                                        'Yes'
                                        ,style:TextStyle(
                                        color: Colors.green[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      ),
                                      onPressed: (){
                                        cubit.updateStoreName(storeController.text);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,),
                                  Expanded(
                                    child: ElevatedButton(
                                      child: Text(
                                        'No'
                                        ,style:TextStyle(
                                        color: Colors.red[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      ),
                                      onPressed: (){
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    );
                  },
                  text: '${LocaleKeys.accept.tr()}',
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.black,
                  radios: 5,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: LocaleKeys.cancel.tr(),
                  color: Colors.black12,
                  textColor: Colors.black,
                  radios: 5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  },
  child: Container(
    padding: const EdgeInsets.all(15),
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.grey,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Row(
          children: [
            Icon(Icons.store, color: Colors.grey,),
            SizedBox(width: 10,),
            Text(
              cubit.creatorProfile?.storeName ?? '',
              style: const TextStyle(),
            ),
          ],
        ),
        const Spacer(),
        CircleAvatar(
          radius: 12,
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(
            Icons.edit,
            color: Colors.black87,
            size: 12,
          ),
        ),
      ],
    ),
  ),
);
Widget ChangeDelivery(context, cubit, deliveryValue, deliveryValueProfile) => InkWell(
  onTap: () {
    deliveryValue.text = deliveryValueProfile.toStringAsFixed(2);
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          LocaleKeys.changeDelivery.tr(),
          style: TextStyle(fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            CustomFormInput(
              controller: deliveryValue,
              label: 'delivery charge',
              labelColor: Colors.black,
              validator: (value) {
                if(value!.isEmpty){
                  return 'delivery charge must be not empty';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              borderColor: Colors.grey,
              fillColor: Colors.grey[200],
              borderRadius: 10,


            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: () {
                      final parsedValue = double.tryParse(deliveryValue.text.trim());
                      if (parsedValue != null) {
                        cubit.updateCreatorProfile(
                          deliveryValue: parsedValue,
                          profileImage: cubit.creatorProfile?.profileImage,
                          coverPhoto: cubit.creatorProfile?.coverImage,
                          availability: cubit.creatorProfile?.availability,
                          paymentMethod: cubit.creatorProfile?.paymentMethod,
                        );
                      }
                      Navigator.pop(context);
                    },
                  text: '${LocaleKeys.accept.tr()}',
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.black,
                  radios: 10,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: '${LocaleKeys.cancel.tr()}',
                  color: Colors.black12,
                  textColor: Colors.black,
                  radios: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  },
  child: Container(
    padding: const EdgeInsets.all(15),
    width: 180,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.grey,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Icon(Icons.delivery_dining , color: Colors.grey,),
        SizedBox(width: 10,),
        Text(
          '${cubit.creatorProfile?.deliveryValue?.toStringAsFixed(2) ?? '0.00'} \$',
          style: const TextStyle(),
        ),
        const Spacer(),
        CircleAvatar(
          radius: 12,
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(
            Icons.edit,
            color: Colors.black87,
            size: 12,
          ),
        ),
      ],
    ),
  ),
);