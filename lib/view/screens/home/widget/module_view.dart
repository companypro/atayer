import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/banner_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_loader.dart';
import 'package:sixam_mart/view/base/title_widget.dart';
import 'package:sixam_mart/view/screens/address/widget/address_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/home/widget/banner_view.dart';
import 'package:sixam_mart/view/screens/home/widget/popular_store_view.dart';

import '../../../../controller/notification_controller.dart';
import '../../../../helper/route_helper.dart';
import '../../../../util/images.dart';
import '../modules/grocery_home_screen.dart';
import 'grocery/best_reviewed_item_view.dart';
import 'grocery/most_popular_item_view.dart';

class ModuleView extends StatelessWidget {
  final SplashController splashController;
  const ModuleView(
      {Key? key, required this.splashController, required this.scaffoldKey})
      : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
          color: Theme.of(context).primaryColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 5),
            //   child: IconButton(onPressed: (){
            //     scaffoldKey.currentState?.openDrawer();
            //
            //   }, icon: Icon(Icons.menu)),
            // ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                      child: InkWell(
                    onTap: () => Get.find<LocationController>()
                        .navigateToLocationScreen('home'),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.isMobile(context) ? 8 : 0,
                        horizontal: ResponsiveHelper.isDesktop(context)
                            ? Dimensions.paddingSizeSmall
                            : 10,
                      ),
                      child: Container(
                        height: ResponsiveHelper.isMobile(context) ? 60 : 0,
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(10),
                        //     border: Border.symmetric(
                        //       horizontal: BorderSide(
                        //         color: Colors.black.withOpacity(.2),
                        //       ),
                        //       vertical: BorderSide(
                        //         color: Colors.black.withOpacity(.2),
                        //       ),
                        //     )),
                        child: GetBuilder<LocationController>(
                            builder: (locationController) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        Images.locationMaps,
                                        width: 20,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Your_current_location'.tr,
                                        style: robotoMedium.copyWith(
                                          color: Theme.of(context).cardColor,
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 7,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          locationController
                                              .getUserAddress()!
                                              .address!,
                                          style: robotoRegular.copyWith(
                                            color:
                                                Theme.of(context).disabledColor,
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.expand_more,
                                        color: Theme.of(context).disabledColor,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ]),
                          );
                        }),
                      ),
                    ),
                  )),
                  // SizedBox(width: 10,),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: InkWell(
                      child: GetBuilder<NotificationController>(
                          builder: (notificationController) {
                        return Container(
                          decoration: BoxDecoration(
                            // border: Border.all(
                            //     color: Theme.of(context)
                            //         .cardColor.withOpacity(.5),
                            //     width: 1),
                            borderRadius: BorderRadius.circular(8),
                            // borderRadius:
                            // BorderRadius.circular(15),
                            // color: Colors.grey.withOpacity(.1),
                          ),
                          height: 53,
                          width: 53,
                          child: Center(
                            child: Stack(children: [
                              Image.asset(
                                Images.bell,
                                width: 25,
                                color: Theme.of(context).cardColor,
                              ),
                              // Icon(CupertinoIcons.bell, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color),
                              notificationController.hasNotification
                                  ? Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        height: 10,
                                        width: 10,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 1,
                                              color:
                                                  Theme.of(context).cardColor),
                                        ),
                                      ))
                                  : const SizedBox(),
                            ]),
                          ),
                        );
                      }),
                      onTap: () =>
                          Get.toNamed(RouteHelper.getNotificationRoute()),
                    ),
                  ),
                ],
              ),
            ),

            // SizedBox(height: 20,),

            Expanded(
              child: Container(
                height: 50,
                width: Dimensions.webMaxWidth,
                // color: Theme.of(context).colorScheme.background,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withOpacity(.04),
                      border: Border.all(
                          color: Theme.of(context).cardColor.withOpacity(.5),
                          width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      // Icon(
                      //   CupertinoIcons.search,
                      //   size: 25,
                      //   color: Theme.of(context)
                      //       .primaryColor,
                      // ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Expanded(
                          child: Text(
                        Get.find<SplashController>()
                                .configModel!
                                .moduleConfig!
                                .module!
                                .showRestaurantText!
                            ? 'search_food_or_restaurant'.tr
                            : 'search_item_or_store'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor,
                        ),
                      )),

                      Icon(
                        CupertinoIcons.search,
                        size: 25,
                        color: Theme.of(context).cardColor.withOpacity(.8),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
      GetBuilder<BannerController>(builder: (bannerController) {
        return const BannerView(isFeatured: true);
      }),

      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          // (splashController.module != null &&
          //         splashController.configModel!.module == null)
          //     ? InkWell(
          //         onTap: () => splashController.removeModule(),
          //         child: Image.asset(Images.moduleIcon,
          //             height: 25,
          //             width: 25,
          //             color: Theme.of(context).textTheme.bodyLarge!.color),
          //       )
          //     : const SizedBox(),
          // SizedBox(
          //     width: (splashController.module != null &&
          //             splashController.configModel!.module == null)
          //         ? Dimensions.paddingSizeSmall
          //         : 0),
        ]),
      ),


      splashController.moduleListHome != null
          ? splashController.moduleListHome!.isNotEmpty && splashController.moduleList != null
          ? SizedBox(
        height: MediaQuery.of(context).size.height * .7,
        child: ListView.builder(
          itemCount: splashController.moduleListHome!.length -1,
          itemBuilder: (context, index) {

            bool isFirstPress = true;

            return Column(
              children: [
                InkWell(
                  onTap:(){
                    if (isFirstPress) {
                      splashController.switchModule(index, false);
                      isFirstPress = false;
                    }

                    splashController.switchModuleHome(index, false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroceryHomeScreen(
                          title: splashController.moduleListHome![index].moduleName!,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      splashController.moduleListHome![index].moduleName!,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault),
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImage(
                        image:
                        '${splashController.configModel!.baseUrls!.moduleImageUrl}/${splashController.moduleListHome![index].icon}',
                        height: 65,
                        width: 65,
                      ),
                    ),
                      trailing:Column(
                        children: [
                          Text(
                            'view_all'.tr,
                            style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,color: Theme.of(context).primaryColor),
                          ),
                          SizedBox(

                              width: 45,

                              child: Divider(thickness: 2, height: 10,color: Theme.of(context).primaryColor.withOpacity(.4),),
                          ),

                        ],
                      ),


                  ),
                ),
                const SizedBox(height: 15,),
                MostPopularItemView(
                  isFood: false,
                  isShop: false,
                  product: splashController.moduleListHome![index].items!,
                ),
              ],
            );
          },
        ),
      )
          : Center(
        child: Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          child: Text('no_module_found'.tr),
        ),
      )
          : ModuleShimmer(isEnabled: splashController.moduleList == null),


      const SizedBox(height: 120),
    ]);
  }
}

class ModuleShimmer extends StatelessWidget {
  final bool isEnabled;
  const ModuleShimmer({Key? key, required this.isEnabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        childAspectRatio: (1 / 1),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[Get.isDarkMode ? 700 : 200]!,
                  spreadRadius: 1,
                  blurRadius: 5)
            ],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: isEnabled,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Colors.grey[300]),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Center(
                  child: Container(
                      height: 15, width: 50, color: Colors.grey[300])),
            ]),
          ),
        );
      },
    );
  }
}

class AddressShimmer extends StatelessWidget {
  final bool isEnabled;
  const AddressShimmer({Key? key, required this.isEnabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall),
          child: TitleWidget(title: 'deliver_to'.tr),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        SizedBox(
          height: 70,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: 5,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                padding:
                    const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context)
                      ? Dimensions.paddingSizeDefault
                      : Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                          blurRadius: 5,
                          spreadRadius: 1)
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      Icons.location_on,
                      size: ResponsiveHelper.isDesktop(context) ? 50 : 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Shimmer(
                        duration: const Duration(seconds: 2),
                        enabled: isEnabled,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  height: 15,
                                  width: 100,
                                  color: Colors.grey[300]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                              Container(
                                  height: 10,
                                  width: 150,
                                  color: Colors.grey[300]),
                            ]),
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
