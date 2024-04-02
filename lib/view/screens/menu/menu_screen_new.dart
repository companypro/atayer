import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/screens/auth/sign_in_screen.dart';
import 'package:sixam_mart/view/screens/menu/widget/portion_widget.dart';
class MenuScreenNew extends StatefulWidget {
  const MenuScreenNew({Key? key}) : super(key: key);

  @override
  State<MenuScreenNew> createState() => _MenuScreenNewState();
}

class _MenuScreenNewState extends State<MenuScreenNew> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('الاعدادات', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: GetBuilder<UserController>(
        builder: (userController) {
          final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

          return Column(children: [

            // Container(
            //   decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            //   child: Padding(
            //     padding: const EdgeInsets.only(
            //       left: Dimensions.paddingSizeExtremeLarge, right: Dimensions.paddingSizeExtremeLarge,
            //       top: 50, bottom: Dimensions.paddingSizeExtremeLarge,
            //     ),
            //     child: Row(children: [
            //
            //       Container(
            //         decoration: BoxDecoration(
            //           color: Theme.of(context).primaryColor,
            //           shape: BoxShape.circle,
            //         ),
            //         padding: const EdgeInsets.all(1),
            //         child: ClipOval(child: CustomImage(
            //           placeholder: Images.guestIconLight,
            //           image: '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
            //               '/${(userController.userInfoModel != null && isLoggedIn) ? userController.userInfoModel!.image : ''}',
            //           height: 70, width: 70, fit: BoxFit.cover,
            //         )),
            //       ),
            //       const SizedBox(width: Dimensions.paddingSizeDefault),
            //
            //       Expanded(
            //         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            //           Text(
            //             isLoggedIn ? '${userController.userInfoModel?.fName} ${userController.userInfoModel?.lName}' : 'guest_user'.tr,
            //             style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
            //           ),
            //           const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            //
            //           isLoggedIn ? Text(
            //             userController.userInfoModel != null ? DateConverter.containTAndZToUTCFormat(userController.userInfoModel!.createdAt!) : '',
            //             style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
            //           ) : InkWell(
            //             onTap: () async {
            //               if(!ResponsiveHelper.isDesktop(context)) {
            //                 await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
            //               }else{
            //                 Get.dialog(const SignInScreen(exitFromApp: true, backFromThis: true));
            //               }
            //             },
            //             child: Text(
            //               'login_to_view_all_feature'.tr,
            //               style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
            //             ),
            //           ) ,
            //
            //         ]),
            //       ),
            //
            //     ]),
            //   ),
            // ),

            Expanded(child: SingleChildScrollView(
              child: Ink(
                // color: Theme.of(context).primaryColor.withOpacity(0.1),
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                child: Column(children: [

                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                      child: Text(
                        'setting_profile'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color:Colors.grey),
                      ),
                    ),

                    Container(
                      // decoration: BoxDecoration(
                      //     color: Theme.of(context).cardColor,
                      //     // borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      //   boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
                      // ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                      // margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Column(children: [
                        PortionWidget(icon: Images.profileIcon, title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
                        PortionWidget(icon: Images.changePasswordIcon, title: 'change_password'.tr, route: RouteHelper.getAddressRoute()),
                        PortionWidget(icon: Images.changeLangIcon, title: 'language'.tr, hideDivider: true, route: RouteHelper.getLanguageRoute('menu')),
                      ]),
                    )

                  ]),



                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                      child: Text(
                        'other'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color:Colors.grey),
                      ),
                    ),

                    Container(
                      // decoration: BoxDecoration(
                      //   color: Theme.of(context).cardColor,
                      //   borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      //   boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)
                      //   ],
                      // ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                      // margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Column(children: [
                        // PortionWidget(icon: Images.chatIcon, title: 'live_chat'.tr, route: RouteHelper.getConversationRoute()),
                        // PortionWidget(icon: Images.helpIcon, title: 'help_and_support'.tr, route: RouteHelper.getSupportRoute()),
                        // PortionWidget(icon: Images.aboutIcon, title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
                        PortionWidget(icon: Images.termsAndConditions, title: 'terms_conditions'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
                        PortionWidget(icon: Images.privacyPolicy, title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),

                        // (Get.find<SplashController>().configModel!.refundPolicyStatus == 1 ) ? PortionWidget(
                        //     icon: Images.refundIcon, title: 'refund_policy'.tr, route: RouteHelper.getHtmlRoute('refund-policy'),
                        //   hideDivider: (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1 ) ||
                        //       (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? false : true,
                        // ) : const SizedBox(),
                        //
                        // (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1 ) ? PortionWidget(
                        //     icon: Images.cancelationIcon, title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy'),
                        //   hideDivider: (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? false : true,
                        // ) : const SizedBox(),
                        //
                        // (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? PortionWidget(
                        //     icon: Images.shippingIcon, title: 'shipping_policy'.tr, hideDivider: true, route: RouteHelper.getHtmlRoute('shipping-policy'),
                        // ) : const SizedBox(),
                      ]),
                    )
                  ]),

                  InkWell(
                    onTap: (){
                      if(Get.find<AuthController>().isLoggedIn()) {
                        Get.dialog(ConfirmationDialog(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () {
                          Get.find<UserController>().clearUserInfo();
                          Get.find<AuthController>().clearSharedData();
                          Get.find<AuthController>().socialLogout();
                          Get.find<WishListController>().removeWishes();
                          if(ResponsiveHelper.isDesktop(context)){
                            Get.offAllNamed(RouteHelper.getInitialRoute());
                          }else{
                            Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                          }
                        }), useSafeArea: false);
                      }else {
                        Get.find<WishListController>().removeWishes();
                        Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                          child: Icon(Icons.power_settings_new_sharp, size: 18, color: Theme.of(context).cardColor),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text(Get.find<AuthController>().isLoggedIn() ? 'logout'.tr : 'sign_in'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))
                      ]),
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : 100),

                ]),
              ),
            )),
          ]);
        }
      ),
    );
  }
}
