import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/order_controller.dart';
import '../../helper/responsive_helper.dart';
import '../../helper/route_helper.dart';
import '../../util/dimensions.dart';
import '../../util/images.dart';
import '../../util/styles.dart';
import '../screens/auth/sign_in_screen.dart';
import 'custom_button.dart';

class NotLoggedInBottomSheetWidget extends StatelessWidget {
  const NotLoggedInBottomSheetWidget({super.key});

  callBack(bool val){}
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.only(bottom: 40, top: 15),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.paddingSizeDefault))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40,height: 5,decoration: BoxDecoration(
            color: Theme.of(context).hintColor.withOpacity(.5),
            borderRadius: BorderRadius.circular(20)),),
        const SizedBox(height: 40,),
        Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          child: SizedBox(width: 60,child: Image.asset(Images.guest)),),

        const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
        Text('please_login_to_continue'.tr,
          style: robotoRegular.copyWith(fontSize: MediaQuery.of(context).size.height*0.0175, color: Theme.of(context).disabledColor),
        ),

        Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeLarge),
          child: Text('you_are_not_logged_in'.tr),),


        const SizedBox(height: Dimensions.paddingSizeDefault,),


        SizedBox(
          width: 200,
          child: CustomButton(buttonText: 'login'.tr, height: 40, onPressed: () async {

            if(!ResponsiveHelper.isDesktop(context)) {
              await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
            }else{
              Get.dialog(const SignInScreen(exitFromApp: true, backFromThis: true)).then((value) => callBack(true));
            }
            if(Get.find<OrderController>().showBottomSheet) {
              Get.find<OrderController>().showRunningOrders();
            }
            callBack(true);

          }),
        ),

      ],),
    );
  }
}
