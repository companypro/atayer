import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/banner_controller.dart';
import '../../../controller/campaign_controller.dart';
import '../../../controller/cart_controller.dart';
import '../../../controller/category_controller.dart';
import '../../../controller/coupon_controller.dart';
import '../../../controller/flash_sale_controller.dart';
import '../../../controller/item_controller.dart';
import '../../../controller/location_controller.dart';
import '../../../controller/notification_controller.dart';
import '../../../controller/parcel_controller.dart';
import '../../../controller/splash_controller.dart';
import '../../../controller/store_controller.dart';
import '../../../controller/user_controller.dart';
import '../../../helper/responsive_helper.dart';
import '../../../util/app_constants.dart';
import '../../../util/dimensions.dart';
import '../../../util/images.dart';
import '../../../util/styles.dart';
import '../../base/custom_app_bar.dart';
import '../../base/custom_image.dart';
import '../home/modules/food_home_screen.dart';
import '../home/modules/grocery_home_screen.dart';
import '../home/modules/pharmacy_home_screen.dart';
import '../home/modules/shop_home_screen.dart';
import '../home/widget/module_view.dart';

class Sections extends StatefulWidget {
  const Sections({super.key, });
  static Future<void> loadData(bool reload) async {
    Get.find<LocationController>().syncZoneData();
    Get.find<FlashSaleController>().setEmptyFlashSale();
    if (Get.find<SplashController>().module != null &&
        !Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .isParcel!) {
      Get.find<BannerController>().getBannerList(reload);
      if (Get.find<SplashController>().module!.moduleType.toString() ==
          AppConstants.grocery) {
        Get.find<FlashSaleController>().getFlashSale(reload, false);
      }
      if (Get.find<SplashController>().module!.moduleType.toString() ==
          AppConstants.grocery) {
        Get.find<ItemController>().getFeaturedCategoriesItemList(false, false);
        Get.find<FlashSaleController>().getFlashSale(reload, false);
      }
      Get.find<BannerController>().getPromotionalBanner(reload);
      Get.find<ItemController>().getDiscountedItemList(reload, false);
      Get.find<CategoryController>().getCategoryList(reload);
      Get.find<StoreController>().getPopularStoreList(reload, 'all', false);
      Get.find<CampaignController>().getBasicCampaignList(reload);
      Get.find<CampaignController>().getItemCampaignList(reload);
      Get.find<ItemController>().getPopularItemList(reload, 'all', false);
      Get.find<StoreController>().getLatestStoreList(reload, 'all', false);
      Get.find<ItemController>().getReviewedItemList(reload, 'all', false);
      Get.find<ItemController>().getRecommendedItemList(reload, 'all', false);
      Get.find<StoreController>().getStoreList(1, reload);
      Get.find<StoreController>().getRecommendedStoreList();
    }
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<StoreController>().getVisitAgainStoreList();
      Get.find<CouponController>().getCouponList();
    }
    Get.find<SplashController>().getModules();
    if (Get.find<SplashController>().module == null &&
        Get.find<SplashController>().configModel!.module == null) {
      Get.find<BannerController>().getFeaturedBanner();
      Get.find<StoreController>().getFeaturedStoreList();
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<LocationController>().getAddressList();
      }
    }
    if (Get.find<SplashController>().module != null &&
        Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .isParcel!) {
      Get.find<ParcelController>().getParcelCategoryList();
    }
    if (Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.grocery) {
      Get.find<ItemController>().getBasicMedicine(reload, false);
      Get.find<StoreController>().getFeaturedStoreList();
      await Get.find<ItemController>().getCommonConditions(false);
      if (Get.find<ItemController>().commonConditions!.isNotEmpty) {
        Get.find<ItemController>().getConditionsWiseItem(
            Get.find<ItemController>().commonConditions![0].id!, false);
      }
    }
    // Get.find<SplashController>().switchModuleSections(0, false);

  }

  @override
  State<Sections> createState() => _SectionsState();
}

class _SectionsState extends State<Sections> {
  final ScrollController _scrollController = ScrollController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    Get.find<CartController>().addItem();

    Sections.loadData(true);
    if (!ResponsiveHelper.isWeb()) {
      Get.find<LocationController>().getZone(
          Get.find<LocationController>().getUserAddress()!.latitude,
          Get.find<LocationController>().getUserAddress()!.longitude,
          false,
          updateInAddress: true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {

        bool isGrocery = splashController.module != null &&
            splashController.module!.moduleType.toString() ==
                AppConstants.grocery;
        // bool isTaxiBooking = splashController.module != null && splashController.configModel!.moduleConfig!.module!.isTaxi!;

      return RefreshIndicator(
        onRefresh: () async {
          splashController.setRefreshing(true);
          if (Get.find<SplashController>().module != null) {
            await Get.find<LocationController>().syncZoneData();
            await Get.find<BannerController>().getBannerList(true);
            if (isGrocery) {
              await Get.find<FlashSaleController>()
                  .getFlashSale(true, true);
            }
            await Get.find<BannerController>()
                .getPromotionalBanner(true);
            await Get.find<ItemController>()
                .getDiscountedItemList(true, false);
            await Get.find<CategoryController>()
                .getCategoryList(true);
            await Get.find<StoreController>()
                .getPopularStoreList(true, 'all', false);
            await Get.find<CampaignController>()
                .getItemCampaignList(true);
            Get.find<CampaignController>().getBasicCampaignList(true);
            await Get.find<ItemController>()
                .getPopularItemList(true, 'all', false);
            await Get.find<StoreController>()
                .getLatestStoreList(true, 'all', false);
            await Get.find<ItemController>()
                .getReviewedItemList(true, 'all', false);
            await Get.find<StoreController>().getStoreList(1, true);
            if (Get.find<AuthController>().isLoggedIn()) {
              await Get.find<UserController>().getUserInfo();
              await Get.find<NotificationController>()
                  .getNotificationList(true);
              Get.find<CouponController>().getCouponList();
            }

          } else {
            await Get.find<BannerController>().getFeaturedBanner();
            await Get.find<SplashController>().getModules();
            if (Get.find<AuthController>().isLoggedIn()) {
              await Get.find<LocationController>().getAddressList();
            }
            await Get.find<StoreController>().getFeaturedStoreList();
          }
          splashController.setRefreshing(false);
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          appBar: CustomAppBar(title: 'sections'.tr, backButton: ResponsiveHelper.isDesktop(context)),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Get.find<SplashController>().moduleList != null ? Get.find<SplashController>().moduleList!.isNotEmpty ? GridView.builder(
                      gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: Dimensions.paddingSizeSmall,
                        crossAxisSpacing: Dimensions.paddingSizeSmall,
                        childAspectRatio: (1 / 1),
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      itemCount: Get.find<SplashController>().moduleList!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Get.find<SplashController>().switchModuleSections(index, false);
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> GroceryHomeScreenSections(title: Get.find<SplashController>().moduleList![index].moduleName!,)));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                              color: Theme.of(context).cardColor,
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 0.15),
                              boxShadow: [
                                BoxShadow(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3)
                              ],
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall),
                                    child: CustomImage(
                                      image:
                                      '${Get.find<SplashController>().configModel!.baseUrls!.moduleImageUrl}/${Get.find<SplashController>().moduleList![index].icon}',
                                      height: 50,
                                      width: 50,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeSmall),
                                  Center(
                                      child: Text(
                                        Get.find<SplashController>().moduleList![index].moduleName!,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall),
                                      )),
                                ]),
                          ),
                        );
                      },
                    )
                        : Center(child: Padding(
                          padding:
                          const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                          child: Text('no_module_found'.tr),
                        ))
                        :
                    ModuleShimmer(isEnabled: Get.find<SplashController>().moduleList == null),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      },
    );
  }
}
