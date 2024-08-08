import 'package:flutter/cupertino.dart';
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

import '../../../controller/order_controller.dart';
import '../../base/menu_drawer.dart';
import '../../base/no_conacted_menu_drawer.dart';
class MenuScreenNew extends StatefulWidget {
  const MenuScreenNew({Key? key}) : super(key: key);

  @override
  State<MenuScreenNew> createState() => _MenuScreenNewState();
}

class _MenuScreenNewState extends State<MenuScreenNew> {
  int _pageIndex = 4;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);

    Get.find<OrderController>().getShareApp();

  }
   // bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

  final List<Menu> _noMenuList = [
    Menu(icon: Images.walleticon, title: 'wallet'.tr, onTap: () {
      Get.back();

      // (Get.find<SplashController>().configModel!.customerWalletStatus == 1) ? PortionWidget(
      //   icon: Images.walletIcon, title: 'my_wallet'.tr, hideDivider: true, route: ,
      //   suffix: !Get.find<AuthController>().isLoggedIn() ? null : PriceConverter.convertPrice(Get.find<UserController>().userInfoModel != null ? Get.find<UserController>().userInfoModel!.walletBalance : 0),
      // ) : const SizedBox();
      RouteHelper.getWalletRoute(true);

    }),
    Menu(icon: Images.requestIcon, title: 'orders'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getOrderRoute());
    }),
    Menu(icon: Images.favIcon, title: 'fav_prodects'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getFavouriteScreen());
    }),

    Menu(icon: Images.addressicon, title: 'my_address'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getAddressRoute());
    }),
    Menu(icon: Images.notaIcon, title: 'notification'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getNotificationRoute());
    }),
    Menu(icon: Images.supporticon, title: 'help_support'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getSupportRoute());
    }),
    Menu(icon: Images.setting, title: 'profile'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getProfileRoute());
    }),
    // Menu(icon: Images.star, title: 'my_orders'.tr, onTap: () {
    //   Get.back();
    //   Get.toNamed(RouteHelper.getOrderRoute());
    // }),
    Menu(icon: Images.share, title: 'share'.tr, onTap: () {
      Get.back();
      // Get.toNamed(RouteHelper.getAddressRoute());
    }),
    // Menu(icon: Images.chat, title: 'live_chat'.tr, onTap: () {
    //   Get.back();
    //   Get.toNamed(RouteHelper.getConversationRoute());
    // }),
  ];
  final List<Menu> _menuList = [
    Menu(icon: Images.setting, title: 'settings'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getProfileRoute());
    }),
    Menu(icon: Images.star, title: 'my_orders'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getOrderRoute());
    }),
    Menu(icon: Images.share, title: 'my_address'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getAddressRoute());
    }),
  ];
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool isParcel = Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('settings'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: GetBuilder<UserController>(
        builder: (userController) {
          final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

          return Get.find<AuthController>().isLoggedIn() ? const MenuDrawer() : const NoMenuDrawer();
        }
      ),
    );
  }
  Widget NoLoginIn(){
    final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraLarge, horizontal: 25),

          alignment: Alignment.centerLeft,
          child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(isLoggedIn ?"${Get.find<UserController>().userInfoModel!.fName}" :  'guest_user'.tr, style: robotoBold.copyWith(fontSize: 20 )),
            IconButton( padding: const EdgeInsets.all(0), onPressed: () => Get.back(), icon: const Icon(Icons.close))
          ],
          ),
        ),
        const Divider(height: 20, thickness: 3),

        Expanded(
          child: ListView.builder(itemBuilder: (context,index){
            return InkWell(
              onTap: _noMenuList[index].onTap as void Function()?,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(children: [
                    Image.asset(_noMenuList[index].icon,  height: 20, width: 20),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Text(_noMenuList[index].title, style: robotoMedium, overflow: TextOverflow.ellipsis, maxLines: 1)),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios_outlined,size: 15,)

                  ]),
                ),
              ),
            );
          }),
        )
      ],
    );
  }

  Widget LoginIn(){
    return ListView.builder(itemBuilder: (context,index){
      return InkWell(
        onTap: _menuList[index].onTap as void Function()?,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(children: [
              Image.asset(_menuList[index].icon,  height: 20, width: 20),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(child: Text(_menuList[index].title, style: robotoMedium, overflow: TextOverflow.ellipsis, maxLines: 1)),
              Spacer(),
              Icon(Icons.arrow_forward_ios_outlined,size: 15,)

            ]),
          ),
        ),
      );

    });
  }
}

