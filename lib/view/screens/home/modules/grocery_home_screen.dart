import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/view/screens/flash_sale/flash_sale_view.dart';
import 'package:sixam_mart/view/screens/home/widget/bad_weather_widget.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/banner_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/best_reviewed_item_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/store_wise_banner_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/best_store_nearby_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/category_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/promo_code_banner_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/item_that_you_love_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/just_for_you_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/most_popular_item_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/new_on_mart_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/middle_section_banner_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/special_offer_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/promotional_banner_view.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/visit_again_view.dart';

import '../../../../controller/notification_controller.dart';
import '../../../../controller/parcel_controller.dart';
import '../../../../controller/splash_controller.dart';
import '../../../../helper/route_helper.dart';
import '../../../../util/app_constants.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/images.dart';
import '../../../../util/styles.dart';
import '../../../base/cart_widget.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../dashboard/widget/bottom_nav_item.dart';
import '../../dashboard/widget/parcel_bottom_sheet.dart';


class GroceryHomeScreen extends StatelessWidget {
  const GroceryHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Container(
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).disabledColor.withOpacity(0.1),
        child:  const Column(
          children: [
            BadWeatherWidget(),

            BannerView(isFeatured: false),
            SizedBox(height: 12),
          ],
        ),
      ),

      const CategoryView(),
      isLoggedIn ? const VisitAgainView() : const SizedBox(),
      const SpecialOfferView(isFood: false, isShop: false),
      // const FlashSaleView(),
      // const BestStoreNearbyView(),
      const MostPopularItemView(isFood: false, isShop: false),
      // const MiddleSectionBannerView(),
      const BestReviewItemView(),
      // const StoreWiseBannerView(),
      const JustForYouView(),
      const ItemThatYouLoveView(forShop: false),
      // isLoggedIn ? const PromoCodeBannerView() : const SizedBox(),
      // const NewOnMartView(isPharmacy: false, isShop: false),
      // const PromotionalBannerView(),
    ]);
  }
}


class GroceryHomeScreenSections extends StatefulWidget {

  final String? title;

  const GroceryHomeScreenSections({Key? key,required this.title}) : super(key: key);

  @override
  State<GroceryHomeScreenSections> createState() => _GroceryHomeScreenSectionsState();
}

class _GroceryHomeScreenSectionsState extends State<GroceryHomeScreenSections> {
  bool isGrocery = Get.find<SplashController>().module != null &&
      Get.find<SplashController>().module!.moduleType.toString() ==
          AppConstants.grocery;
  int _pageIndex = 1;
  PageController? _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: _pageIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool isParcel = Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!;
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!),),
      body:SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).disabledColor.withOpacity(0.1),
            child:  const Column(
              children: [
                BadWeatherWidget(),

                BannerView(isFeatured: false),
                SizedBox(height: 12),
              ],
            ),
          ),

          const CategoryViewSections(),


        ]),
      ) ,
      bottomNavigationBar: Stack(children: [
        // CustomPaint(size: Size(size.width, GetPlatform.isIOS ? 95 : 80), painter: BNBCustomPainter()),

        Center(
          heightFactor: 0.6,
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
          width: size.width, height: 80,
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
              isSelected: _pageIndex == 1, onTap: () => _setPage(1),
            ),
            Container(width: size.width * 0.2),
            BottomNavItem(
              title: 'search'.tr, selectedIcon: Images.searchIcon, unSelectedIcon: Images.searchIcon,
              isSelected: _pageIndex == 3, onTap: () => Get.toNamed(
                RouteHelper.getSearchRoute()),
            ),
            BottomNavItem(
              title: 'menu'.tr, selectedIcon: Images.menu, unSelectedIcon: Images.menu,
              isSelected: _pageIndex == 4, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> const DashboardScreen(pageIndex: 4,))),
            ),
          ]),
        ),
      ],),
    );
  }
  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

}
