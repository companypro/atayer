import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:share_plus/share_plus.dart';

import '../../controller/auth_controller.dart';
import '../../controller/cart_controller.dart';
import '../../controller/localization_controller.dart';
import '../../controller/order_controller.dart';
import '../../controller/splash_controller.dart';
import '../../controller/user_controller.dart';
import '../../controller/wishlist_controller.dart';
import '../../helper/responsive_helper.dart';
import '../../helper/route_helper.dart';
import '../../util/dimensions.dart';
import '../../util/images.dart';
import '../../util/styles.dart';
import '../screens/auth/sign_in_screen.dart';
import 'confirmation_dialog.dart';
import 'custom_button.dart';
import 'hover/on_hover.dart';
import 'menu_drawer.dart';

class NoMenuDrawer extends StatefulWidget {
  const NoMenuDrawer({super.key});

  @override
  State<NoMenuDrawer> createState() => _NoMenuDrawerState();
}

class _NoMenuDrawerState extends State<NoMenuDrawer> with SingleTickerProviderStateMixin{
  final List<Menu> _menuList = [
    Menu(icon: Images.setting, title: 'settings'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getSetting());
    }),
    Menu(icon: Images.star, title: 'Rate_the_app'.tr, onTap: () {
      Get.back();
      Get.toNamed(RouteHelper.getReviewRoute());
    }),
    Menu(icon: Images.share, title: 'share'.tr, onTap: () {
      Get.back();
      return Share.share(Get.find<OrderController>().shareApp!);

    }),
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

  callBack(bool val){}
  Widget _buildContent() {
    return Align(alignment: Get.find<LocalizationController>().isLtr ? Alignment.topRight : Alignment.topLeft, child: Container(
      // width: 300,
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * .8,

            child: CustomButton(buttonText: 'login'.tr, height: 55, onPressed: () async {

              if(!ResponsiveHelper.isDesktop(context)) {
                await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
              }else{
                Get.dialog(const SignInScreen(exitFromApp: true, backFromThis: true,)).then((value) => callBack(true));
              }
              if(Get.find<OrderController>().showBottomSheet) {
                Get.find<OrderController>().showRunningOrders();
              }
              callBack(true);

            }),
          ),
        ),
        SizedBox(height: Dimensions.paddingSizeDefault,),

        const Divider(height: 50, thickness: 3),

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
