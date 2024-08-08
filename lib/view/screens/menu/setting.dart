import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/screens/menu/widget/portion_widget.dart';

import '../../../controller/parcel_controller.dart';
import '../../../controller/splash_controller.dart';
import '../../../controller/user_controller.dart';
import '../../../controller/wishlist_controller.dart';
import '../../../helper/date_converter.dart';
import '../../../helper/price_converter.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../util/images.dart';
import '../../../util/styles.dart';
import '../../base/cart_widget.dart';
import '../../base/confirmation_dialog.dart';
import '../../base/custom_app_bar.dart';
import '../auth/sign_in_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/widget/bottom_nav_item.dart';
import '../dashboard/widget/parcel_bottom_sheet.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int _pageIndex = 5;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);


  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool isParcel = Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!;
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppBar(title: 'profile'.tr,),

      // AppBar(
      //   title: Text('profile'.tr),
      // ),
      body: GetBuilder<UserController>(
          builder: (userController) {
            final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

            return Column(children: [


              Expanded(child: SingleChildScrollView(
                child: Ink(
                  // color: Theme.of(context).primaryColor.withOpacity(0.1),
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                  child: Column(children: [

                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                        child: Text(
                          'general'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          // borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                        margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Column(children: [

                          PortionWidget(icon: Images.profileIcon, title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
                          PortionWidget(icon: Images.addressIcon, title: 'my_address'.tr, route: RouteHelper.getAddressRoute()),
                          PortionWidget(icon: Images.languageIcon, title: 'language'.tr, hideDivider: true, route: RouteHelper.getLanguageRoute('menu')),
                          PortionWidget(icon: Images.changePasswordIcon, title: 'change_password'.tr, route: RouteHelper.getResetPasswordRoute('', Get.find<AuthController>().verificationCode, 'reset-password')),

                        ]),
                      )

                    ]),


                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                        child: Text(
                          'help_and_support'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                        margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Column(children: [
                          // PortionWidget(icon: Images.helpIcon, title: 'help_and_support'.tr, route: RouteHelper.getSupportRoute()),
                          // PortionWidget(icon: Images.aboutIcon, title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
                          PortionWidget(icon: Images.termsIcon, title: 'terms_conditions'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
                          PortionWidget(icon: Images.privacyIcon, title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),

                          // (Get.find<SplashController>().configModel!.refundPolicyStatus == 1 ) ? PortionWidget(
                          //   icon: Images.refundIcon, title: 'refund_policy'.tr, route: RouteHelper.getHtmlRoute('refund-policy'),
                          //   hideDivider: (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1 ) ||
                          //       (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? false : true,
                          // ) : const SizedBox(),

                          // (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1 ) ? PortionWidget(
                          //   icon: Images.cancelationIcon, title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy'),
                          //   hideDivider: (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? false : true,
                          // ) : const SizedBox(),

                          // (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? PortionWidget(
                          //   icon: Images.shippingIcon, title: 'shipping_policy'.tr, hideDivider: true, route: RouteHelper.getHtmlRoute('shipping-policy'),
                          // ) : const SizedBox(),
                        ]),
                      )
                    ]),

                    // InkWell(
                    //   onTap: (){
                    //     if(Get.find<AuthController>().isLoggedIn()) {
                    //       Get.dialog(ConfirmationDialog(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () {
                    //         Get.find<UserController>().clearUserInfo();
                    //         Get.find<AuthController>().clearSharedData();
                    //         Get.find<AuthController>().socialLogout();
                    //         Get.find<WishListController>().removeWishes();
                    //         if(ResponsiveHelper.isDesktop(context)){
                    //           Get.offAllNamed(RouteHelper.getInitialRoute());
                    //         }else{
                    //           Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                    //         }
                    //       }), useSafeArea: false);
                    //     }else {
                    //       Get.find<WishListController>().removeWishes();
                    //       Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                    //     }
                    //   },
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    //     child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    //       Container(
                    //         padding: const EdgeInsets.all(2),
                    //         decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                    //         child: Icon(Icons.power_settings_new_sharp, size: 18, color: Theme.of(context).cardColor),
                    //       ),
                    //       const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    //
                    //       Text(Get.find<AuthController>().isLoggedIn() ? 'logout'.tr : 'sign_in'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))
                    //     ]),
                    //   ),
                    // ),

                    SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : 100),

                  ]),
                ),
              )),
            ]);
          }
      ),
      bottomNavigationBar: Stack(children: [
        // CustomPaint(size: Size(size.width, GetPlatform.isIOS ? 95 : 80), painter: BNBCustomPainter()),

        Center(
          heightFactor: 0.9,
          child: Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).cardColor, width: 5),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, -2), spreadRadius: 0)]
            ),
            // margin: EdgeInsets.only(bottom: GetPlatform.isIOS ? 0 : Dimensions.paddingSizeLarge),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                if(isParcel) {
                  showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                    builder: (con) => ParcelBottomSheet(parcelCategoryList: Get.find<ParcelController>().parcelCategoryList),
                  );
                } else {
                  Get.toNamed(RouteHelper.getCartRoute());
                }
              },
              elevation: 0,
              child: isParcel
                  ? Icon(CupertinoIcons.add, size: 34, color: Theme.of(context).cardColor)
                  : CartWidget(color: Theme.of(context).cardColor, size: 22),
            ),
          ),
        ),

        SizedBox(
          width: size.width, height: 70,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            BottomNavItem(
              title: 'home'.tr, selectedIcon: Images.homeSelect,
              unSelectedIcon: Images.homeUnselect, isSelected: _pageIndex == 0,
              onTap: () => Navigator.pushNamed(context, RouteHelper.initial),
            ),
            BottomNavItem(
              title: isParcel ? 'address'.tr : 'sections'.tr,
              selectedIcon: isParcel ? Images.addressSelect : Images.sections,
              unSelectedIcon: isParcel ? Images.addressUnselect : Images.sectionsEmpty,
              isSelected: _pageIndex == 1, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> const DashboardScreen(pageIndex: 1,))),
            ),
            Container(width: size.width * 0.2),
            BottomNavItem(
              title: 'orders'.tr, selectedIcon: Images.searchIcon, unSelectedIcon: Images.searchIcon,
              isSelected: _pageIndex == 4, onTap: () => Get.toNamed(
                RouteHelper.getSearchRoute()),
            ),
            BottomNavItem(
              title: 'menu'.tr, selectedIcon: Images.menu, unSelectedIcon: Images.menu,
              isSelected: _pageIndex == 5, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> const DashboardScreen(pageIndex: 4,))),
            ),
          ]),
        ),
      ],),

    );
  }
}
