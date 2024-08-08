import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';
import 'package:sixam_mart/view/screens/auth/sign_in_screen.dart';
import 'package:sixam_mart/view/base/hover/on_hover.dart';

import '../../controller/order_controller.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  MenuDrawerState createState() => MenuDrawerState();
}

class MenuDrawerState extends State<MenuDrawer> with SingleTickerProviderStateMixin {


  final List<Menu> _menuList = [
    Menu(icon: Images.walleticon, title: 'wallet'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getWalletRoute(true));
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
    // Menu(icon: Images.supporticon, title: 'help_support'.tr, onTap: () {
    //   Get.back();
    //   Get.toNamed(RouteHelper.getSupportRoute());
    // }),
    Menu(icon: Images.supporticon, title: 'live_chat'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getConversationRoute());
    }),
    Menu(icon: Images.setting, title: 'settings'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getSetting());
    }),
    // Menu(icon: Images.star, title: 'my_orders'.tr, onTap: () {
    //   Get.back();
    //   Get.toNamed(RouteHelper.getOrderRoute());
    // }),
    Menu(icon: Images.share, title: 'share'.tr, onTap: () {
      Get.back();
      // Get.toNamed(RouteHelper.getReferAndEarnRoute());
      // if(Get.find<OrderController>().shareApp != null){
      //
      // }else{
      //   print('object');
      // }
      return Share.share(Get.find<OrderController>().shareApp!);

    }),
    // Menu(icon: Images.chat, title: 'live_chat'.tr, onTap: () {
    //   Get.back();
    //   Get.toNamed(RouteHelper.getConversationRoute());
    // }),
  ];

  static const _initialDelayTime = Duration(milliseconds: 200);
  static const _itemSlideTime = Duration(milliseconds: 250);
  static const _staggerTime = Duration(milliseconds: 50);
  static const _buttonDelayTime = Duration(milliseconds: 150);
  static const _buttonTime = Duration(milliseconds: 500);
  final _animationDuration = _initialDelayTime + (_staggerTime * 7) + _buttonDelayTime + _buttonTime;

  late AnimationController _staggeredController;
  final List<Interval> _itemSlideIntervals = [];

  @override
  void initState() {
    super.initState();

    Get.find<OrderController>().getShareApp();

    _menuList.add(Menu(icon: Images.logOut, title: Get.find<AuthController>().isLoggedIn() ? 'logout'.tr : 'sign_in'.tr, onTap: () {
      Get.back();
      if(Get.find<AuthController>().isLoggedIn()) {
        Get.dialog(ConfirmationDialog(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () {
          Get.find<UserController>().clearUserInfo();
          Get.find<AuthController>().clearSharedData();
          Get.find<CartController>().clearCartList();
          Get.find<AuthController>().socialLogout();
          Get.find<WishListController>().removeWishes();
          if(ResponsiveHelper.isDesktop(Get.context)) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }else{
            Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
          }
        }), useSafeArea: false);
      }else {
        Get.find<WishListController>().removeWishes();
        if(ResponsiveHelper.isDesktop(context)){
          Get.dialog(const SignInScreen(exitFromApp: false, backFromThis: false,));
        }else{
          Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
        }
      }
    }));

    _createAnimationIntervals();

    _staggeredController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();
  }

  void _createAnimationIntervals() {
    for (var i = 0; i < _menuList.length; ++i) {
      final startTime = _initialDelayTime + (_staggerTime * i);
      final endTime = startTime + _itemSlideTime;
      _itemSlideIntervals.add(
        Interval(
          startTime.inMilliseconds / _animationDuration.inMilliseconds,
          endTime.inMilliseconds / _animationDuration.inMilliseconds,
        ),
      );
    }
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isMobile(context) ? _buildContent() : const SizedBox();
  }

  Widget _buildContent() {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Align(alignment: Get.find<LocalizationController>().isLtr ? Alignment.topRight : Alignment.topLeft, child: Container(
      // width: 300,
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraLarge, horizontal: 25),

          alignment: Alignment.centerLeft,
          child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            //${Get.find<UserController>().userInfoModel!.fName}
            Text(isLoggedIn ?"${Get.find<UserController>().userInfoModel!.fName}" :  'guest_user'.tr, style: robotoBold.copyWith(fontSize: 20 )),
            // IconButton( padding: const EdgeInsets.all(0), onPressed: () => Get.back(), icon: const Icon(Icons.close))
          ],
          ),
        ),
        const Divider(height: 20, thickness: 3),

        Expanded(
          child: ListView.builder(
            itemCount: _menuList.length,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _staggeredController,
                builder: (context, child) {
                  final animationPercent = Curves.easeOut.transform(
                    _itemSlideIntervals[index].transform(_staggeredController.value),
                  );
                  final opacity = animationPercent;
                  final slideDistance = (1.0 - animationPercent) * 150;

                  return Opacity(
                    opacity: opacity,
                    child: Transform.translate(
                      offset: Offset(slideDistance, 0),
                      child: child,
                    ),
                  );
                },
                child: OnHover(
                  isItem: true,
                  fromMenu: true,
                  child: InkWell(
                    onTap: _menuList[index].onTap as void Function()?,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(children: [
                          Image.asset(_menuList[index].icon,  height: 20, width: 20),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(child: Text(_menuList[index].title, style: robotoBold, overflow: TextOverflow.ellipsis, maxLines: 1)),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios_outlined,size: 15,)

                        ]),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    ));
  }
}




class Menu {
  String icon;
  String title;
  Function onTap;

  Menu({required this.icon, required this.title, required this.onTap});
}