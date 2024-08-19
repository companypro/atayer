import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/coupon_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/item_widget.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:sixam_mart/view/base/web_constrained_box.dart';
import 'package:sixam_mart/view/base/web_page_title_widget.dart';
import 'package:sixam_mart/view/screens/cart/widget/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/cart/widget/web_cart_items_widget.dart';
import 'package:sixam_mart/view/screens/cart/widget/web_suggested_item_view.dart';
import 'package:sixam_mart/view/screens/home/home_screen.dart';
import 'package:sixam_mart/view/screens/store/store_screen.dart';
import 'package:lottie/lottie.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/category_controller.dart';
import '../../../controller/location_controller.dart';
import '../../../controller/order_controller.dart';
import '../../../controller/parcel_controller.dart';
import '../../../controller/user_controller.dart';
import '../../../data/model/response/order_model.dart';
import '../../../helper/cart_helper.dart';
import '../../../helper/checkout_helper.dart';
import '../../base/cart_widget.dart';
import '../checkout/widget/checkout_screen_shimmer_view.dart';
import '../checkout/widget/coupon_section.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/widget/bottom_nav_item.dart';
import '../dashboard/widget/parcel_bottom_sheet.dart';
import 'widget/not_available_bottom_sheet.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  final Store store;

  const CartScreen({Key? key, required this.fromNav, required this.store}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController scrollController = ScrollController();
  int _pageIndex = 3;
  PageController? _pageController;
  double? _taxPercent = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);

    initCall();

  }

  Future<void> initCall() async {


    Get.find<OrderController>().setGuestAddress(null, isUpdate: false);




    if(Get.find<CartController>().cartList.isEmpty) {
      await Get.find<CartController>().getCartDataOnline();
    }
    if(Get.find<CartController>().cartList.isNotEmpty){
      if (kDebugMode) {
        print('----cart item : ${Get.find<CartController>().cartList[0].toJson()}');
      }
      if(Get.find<CartController>().addCutlery){
        Get.find<CartController>().updateCutlery(isUpdate: false);
      }
      Get.find<CartController>().setAvailableIndex(-1, isUpdate: false);

      Get.find<StoreController>().getCartStoreSuggestedItemList(Get.find<CartController>().cartList[0].item!.storeId);
      Get.find<StoreController>().getStoreDetails(Store(id: Get.find<CartController>().cartList[0].item!.storeId, name: null), false, fromCart: false);
      Get.find<CartController>().calculationCart();
    }



  }
  // OrderController(orderRepo: Get.find()))

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool isParcel = Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!;
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,

      appBar: CustomAppBar(title: 'my_cart'.tr, backButton: (ResponsiveHelper.isDesktop(context) || !widget.fromNav)),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<CartController>(builder: (cartController) {
        return GetBuilder<StoreController>(builder: (storeController) {
          return   GetBuilder<LocationController>(builder: (locationController){
            return  GetBuilder<CouponController>(builder: (couponController){
              return  GetBuilder<OrderController>(
                  builder: (orderController) {
                    // print("Delivery Charge: $deliveryCharge");
                    // print("Delivery Charge: $orderAmount");
                    print("Delivery store: ${Get.find<StoreController>().store}");
                    print("Delivery Charge: ${Get.find<LocationController>().getUserAddress()!}");
                    print("Delivery distance: ${Get.find<OrderController>().distance}");
                    print("Delivery extraCharge: ${Get.find<OrderController>().extraCharge}");
                    print("Delivery orderType: ${Get.find<OrderController>().orderType}");
                    print("Delivery calculateOrderAmount: ${calculateOrderAmount()}");
                    double orderAmount = calculateOrderAmount();
                    double deliveryCharge = CheckoutHelper.calculateDeliveryCharge(
                      store: Get.find<StoreController>().store,
                      address: Get.find<LocationController>().getUserAddress()!,
                      distance: Get.find<OrderController>().distance??0,
                      extraCharge: Get.find<OrderController>().extraCharge??0,
                      orderType: Get.find<OrderController>().orderType??'',
                      orderAmount: orderAmount,
                    );

                    print("Delivery Charge: $deliveryCharge");
                    print("Delivery Charge: $orderAmount");
                    print("Delivery Charge: ${Get.find<StoreController>().store}");
                    print("Delivery Charge: ${Get.find<LocationController>().getUserAddress()!}");
                    print("Delivery Charge: ${Get.find<OrderController>().distance}");
                    print("Delivery Charge: ${Get.find<OrderController>().extraCharge}");
                    print("Delivery Charge: ${Get.find<OrderController>().orderType}");
                    return cartController.cartList.isNotEmpty  ? (Get.find<OrderController>().distance != null && Get.find<StoreController>().store != null && Get.find<OrderController>().extraCharge != null && Get.find<OrderController>().orderType != null && deliveryCharge != null) ? Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child:  Column(
                        children: [
                          // Optional: WebScreenTitleWidget(title: 'cart_list'.tr),
                          const Divider(thickness: 4, height: 5),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(Images.time, width: 35,),
                                const SizedBox(width: 10),
                                Text("delivery_within".tr, style: robotoBold.copyWith(color: Theme.of(context).colorScheme.error, fontSize: 16))
                              ],
                            ),
                          ),

                          const Divider(thickness: 1, height: 5),

                          // Properly use Expanded for ListView
                          Expanded(
                            child: ListView.builder(
                              itemCount: cartController.cartList.length,
                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                              itemBuilder: (context, index) {
                                // print('/////////////////////////${Get.find<CartController>().cartList![1]!.item!.storeId}');
                                return CartItemWidget(
                                    cart: cartController.cartList[index],
                                    cartIndex: index,
                                    addOns: cartController.addOnsList[index],
                                    isAvailable: cartController.availableList[index]
                                );
                              },
                            ),
                          ),

                          pricingView(cartController, cartController.cartList[0].item!,storeController,locationController,couponController,deliveryCharge),

                          ResponsiveHelper.isDesktop(context) ? const SizedBox.shrink() : CheckoutButton(cartController: cartController, availableList: cartController.availableList),
                        ],
                      ),
                    ): const CardScreenShimmerView() : const NoDataScreen(isCart: true, text: '', showFooter: true);
                  });



            });

          });


        });
      }),
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
              title: 'search'.tr, selectedIcon: Images.searchIcon, unSelectedIcon: Images.searchIcon,
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
  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  Widget pricingView(CartController cartController, Item item,StoreController storeController,LocationController locationController,CouponController couponController,deliveryCharge){
    double priceWithAddons = 0;
    // double orderAmount = CheckoutHelper.calculateOrderAmount(
    //   price: price, variations: variations, discount: discount, addOns: addOns,
    //   couponDiscount: couponDiscount, cartList: _cartList,


    // );
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        // borderRadius: BorderRadius.circular( ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : Dimensions.radiusSmall),
        // boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: GetBuilder<OrderController>(
          builder: (orderController) {






            return  Column(children: [


              const Divider(thickness: 1, height: 15),


              const SizedBox(height: 10,),

              !ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().getModuleConfig(item.moduleType)!.newVariation! && (storeController.store != null && storeController.store!.cutlery!) ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Image.asset(Images.cutlery, height: 18, width: 18),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('add_cutlery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text('do_not_have_cutlery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                    ]),
                  ),

                  Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      value: cartController.addCutlery,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool? value) {
                        cartController.updateCutlery();
                      },
                      trackColor: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  )

                ]),
              ) : const SizedBox(),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('subtotal'.tr, style: robotoMedium),
                          PriceConverter.convertAnimationPrice(cartController.subTotal, textStyle: robotoBold),
                          // Text(
                          //   PriceConverter.convertPrice(cartController.subTotal),
                          //   style: robotoMedium.copyWith(color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                          // ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                        Text('item_price'.tr, style: robotoMedium),
                        //orderController
                        // PriceConverter.convertAnimationPrice(tax, textStyle: robotoBold),
                        Text(
                          '${PriceConverter.convertPrice(deliveryCharge)}', style: robotoBold, textDirection: TextDirection.rtl,
                        ),

                        // Text(PriceConverter.convertPrice(cartController.itemPrice), style: robotoRegular, textDirection: TextDirection.ltr),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      const Divider(thickness: 1, height: 5),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total_shipment'.tr, style: robotoBold),

                          PriceConverter.convertAnimationPrice(cartController.subTotal + deliveryCharge, textStyle: robotoBold),
                          // Text(
                          //   PriceConverter.convertPrice(cartController.subTotal),
                          //   style: robotoMedium.copyWith(color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                          // ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      // ResponsiveHelper.isDesktop(context) ? const SizedBox.shrink() : CustomButton(onPressed:(){
                      //   Get.toNamed(RouteHelper.getCouponRoute());
                      // },buttonText: 'Add_the_coupon'.tr,color: Theme.of(context).primaryColor.withOpacity(.5)),

                      // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      //   Text('discount'.tr, style: robotoBold),
                      //   storeController.store != null ? Row(children: [
                      //     Text('(-)', style: robotoBold),
                      //     PriceConverter.convertAnimationPrice(cartController.itemDiscountPrice, textStyle: robotoBold),
                      //   ]) : Text('calculating'.tr, style: robotoBold),
                      //   // Text('(-) ${PriceConverter.convertPrice(cartController.itemDiscountPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                      // ]),
                      // SizedBox(height: cartController.variationPrice > 0 ? Dimensions.paddingSizeSmall : 0),

                      Get.find<SplashController>().getModuleConfig(item.moduleType)!.newVariation! && cartController.variationPrice > 0 ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('variations'.tr, style: robotoRegular),
                          Text('(+) ${PriceConverter.convertPrice(cartController.variationPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                        ],
                      ) : const SizedBox(),
                      SizedBox(height: Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? 10 : 0),

                      Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('addons'.tr, style: robotoRegular),
                          Text('(+) ${PriceConverter.convertPrice(cartController.addOns)}', style: robotoRegular, textDirection: TextDirection.ltr),
                        ],
                      ) : const SizedBox(),
                      // const SizedBox(height: Dimensions.paddingSizeSmall),
                      //     Text('Delivery_to_me'.tr, style: robotoBold),
                      //     TextButton(onPressed: () =>Get.find<LocationController>().navigateToLocationScreen('home'),
                      //         child: Text('Select_a_topic'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor,fontSize: 15))),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      //   child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                      // ),
                    ]),
              ),


              ResponsiveHelper.isDesktop(context) ? CheckoutButton(cartController: cartController, availableList: cartController.availableList) : const SizedBox.shrink(),

            ]);
          }),
    );
  }
  double calculateOrderAmount() {
    // Calculate the order amount based on the price, variations, discount, add-ons, and coupon discount
    double price = CheckoutHelper.calculatePrice(store: Get.find<StoreController>().store, cartList: Get.find<CartController>().cartList);
    double addOns = CheckoutHelper.calculateAddonsPrice(store: Get.find<StoreController>().store, cartList: Get.find<CartController>().cartList);
    double variations = CheckoutHelper.calculateVariationPrice(store: Get.find<StoreController>().store, cartList: Get.find<CartController>().cartList, calculateWithoutDiscount: true);
    double? discount = CheckoutHelper.calculateDiscount(
      store: Get.find<StoreController>().store, cartList: Get.find<CartController>().cartList, price: price, addOns: addOns,
    );
    double couponDiscount = PriceConverter.toFixed(Get.find<CouponController>().discount!);
    return CheckoutHelper.calculateOrderAmount(
      price: price, variations: variations, discount: discount, addOns: addOns,
      couponDiscount: couponDiscount, cartList: Get.find<CartController>().cartList,
    );
  }
  Widget suggestedItemView(List<CartModel> cartList){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        // boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 10)]
      ),
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        GetBuilder<StoreController>(builder: (storeController) {
          List<Item>? suggestedItems;
          if(storeController.cartSuggestItemModel != null){
            suggestedItems = [];
            List<int> cartIds = [];
            for (CartModel cartItem in cartList) {
              cartIds.add(cartItem.item!.id!);
            }
            for (Item item in storeController.cartSuggestItemModel!.items!) {
              if(!cartIds.contains(item.id)){
                suggestedItems.add(item);
              }
            }
          }
          return storeController.cartSuggestItemModel != null && suggestedItems!.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                child: Text('you_may_also_like'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
              ),

              SizedBox(
                height: ResponsiveHelper.isDesktop(context) ? 160 : 125,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestedItems.length,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(left: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: 20) : const EdgeInsets.symmetric(vertical: 10) ,
                      child: Container(
                        width: ResponsiveHelper.isDesktop(context) ? 500 : 300,
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: ItemWidget(
                          isStore: false, item: suggestedItems![index], fromCartSuggestion: true,
                          store: null, index: index, length: null, isCampaign: false, inStore: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ) : const SizedBox();
        }),
      ]),
    );
  }



}




class CheckoutButton extends StatelessWidget {
  final CartController cartController;
  final List<bool> availableList;
  const CheckoutButton({Key? key, required this.cartController, required this.availableList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percentage = 0;

    return Container(
      width: Dimensions.webMaxWidth,
      padding:  const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),
          boxShadow: ResponsiveHelper.isDesktop(context) ? null : [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 10)]
      ),
      child: GetBuilder<StoreController>(
          builder: (storeController) {
            if(Get.find<StoreController>().store != null && !Get.find<StoreController>().store!.freeDelivery! && Get.find<SplashController>().configModel!.freeDeliveryOver != null){
              percentage = cartController.subTotal/Get.find<SplashController>().configModel!.freeDeliveryOver!;
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                (storeController.store != null && !storeController.store!.freeDelivery! && Get.find<SplashController>().configModel!.freeDeliveryOver != null && percentage < 1)
                    ? Column(children: [
                  Row(children: [
                    Image.asset(Images.percentTag, height: 20, width: 20),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(
                      PriceConverter.convertPrice(Get.find<SplashController>().configModel!.freeDeliveryOver! - cartController.subTotal),
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text('more_for_free_delivery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  LinearProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    value: percentage,
                  ),
                ]) : const SizedBox(),

                ResponsiveHelper.isDesktop(context) ? const Divider(height: 1) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                // Padding(
                //   padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text('subtotal'.tr, style: robotoMedium.copyWith(color:  ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor)),
                //       PriceConverter.convertAnimationPrice(cartController.subTotal, textStyle: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                //       // Text(
                //       //   PriceConverter.convertPrice(cartController.subTotal),
                //       //   style: robotoMedium.copyWith(color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                //       // ),
                //     ],
                //   ),
                // ),

                ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().getModuleConfig(cartController.cartList[0].item!.moduleType)!.newVariation!
                    && (storeController.store != null && storeController.store!.cutlery!) ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Image.asset(Images.cutlery, height: 18, width: 18),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('add_cutlery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Text('do_not_have_cutlery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                      ]),
                    ),

                    Transform.scale(
                      scale: 0.7,
                      child: CupertinoSwitch(
                        value: cartController.addCutlery,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (bool? value) {
                          cartController.updateCutlery();
                        },
                        trackColor: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                    )
                  ]),
                ) : const SizedBox(),
                ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

                !ResponsiveHelper.isDesktop(context) ? const SizedBox() :
                Container(
                  width: Dimensions.webMaxWidth,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Theme.of(context).primaryColor, width: 0.5)),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  //margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: (){
                          if(ResponsiveHelper.isDesktop(context)){
                            Get.dialog(const Dialog(child: NotAvailableBottomSheet()));
                          }else{
                            showModalBottomSheet(
                              context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                              builder: (con) => const NotAvailableBottomSheet(),
                            );
                          }
                        },
                        child: Row(children: [
                          Expanded(child: Text('if_any_product_is_not_available'.tr, style: robotoMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.keyboard_arrow_down, size: 18),
                        ]),
                      ),

                      cartController.notAvailableIndex != -1 ? Row(children: [
                        Text(cartController.notAvailableList[cartController.notAvailableIndex].tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),

                        IconButton(
                          onPressed: ()=> cartController.setAvailableIndex(-1),
                          icon: const Icon(Icons.clear, size: 18),
                        )
                      ]) : const SizedBox(),
                    ],
                  ),
                ),
                ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

                SafeArea(
                  child: CustomButton(
                      buttonText: 'proceed_to_checkout'.tr,
                      fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeLarge,
                      isBold:  ResponsiveHelper.isDesktop(context) ? false : true,
                      radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                      onPressed: () {
                        if(!cartController.cartList.first.item!.scheduleOrder! && availableList.contains(false)) {
                          showCustomSnackBar('one_or_more_product_unavailable'.tr);
                        } /*else if(Get.find<AuthController>().isGuestLoggedIn() && !Get.find<SplashController>().configModel!.guestCheckoutStatus!) {
                    showCustomSnackBar('currently_your_zone_have_no_permission_to_place_any_order'.tr);
                  }*/ else {
                          if(Get.find<SplashController>().module == null) {
                            int i = 0;
                            for(i = 0; i < Get.find<SplashController>().moduleList!.length; i++){
                              if(cartController.cartList[0].item!.moduleId == Get.find<SplashController>().moduleList![i].id){
                                break;
                              }
                            }
                            Get.find<SplashController>().setModule(Get.find<SplashController>().moduleList![i]);
                            HomeScreen.loadData(true);
                          }
                          Get.find<CouponController>().removeCouponData(false);

                          Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                        }
                      }),
                ),
              ],
            );
          }
      ),
    );
  }
}