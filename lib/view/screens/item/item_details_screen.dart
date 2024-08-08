import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/theme_controller.dart';
import 'package:sixam_mart/data/model/body/place_order_body.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/cart_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/cart_snackbar.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/screens/checkout/checkout_screen.dart';
import 'package:sixam_mart/view/screens/item/widget/details_app_bar.dart';
import 'package:sixam_mart/view/screens/item/widget/details_web_view.dart';
import 'package:sixam_mart/view/screens/item/widget/item_image_view.dart';
import 'package:sixam_mart/view/screens/item/widget/item_title_view.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sixam_mart/view/base/quantity_button.dart';
// import '../data/model/response/store_model.dart';

import '../../../controller/category_controller.dart';
import '../../../controller/parcel_controller.dart';
import '../../../controller/store_controller.dart';
import '../../../data/model/response/config_model.dart';
import '../../../data/model/response/store_model.dart';
import '../../base/cart_count_view.dart';
import '../../base/cart_widget.dart';
import '../../base/web_constrained_box.dart';
import '../cart/widget/cart_item_widget.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/widget/bottom_nav_item.dart';
import '../dashboard/widget/parcel_bottom_sheet.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Item? item;
  final bool inStorePage;
  Store? store;

   ItemDetailsScreen({Key? key, required this.item, required this.inStorePage,required this.store, }) : super(key: key);

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen>  with TickerProviderStateMixin {
  final Size size = Get.size;
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  final GlobalKey<DetailsAppBarState> _key = GlobalKey();
  TabController? tabController;
  late final bool? inStorePage;
  Store store = Store();
  int _pageIndex = 0;
  PageController? _pageController;


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);

    tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    Future.delayed(Duration.zero, () {
      load();
      Get.find<ItemController>().getProductDetails(widget.item!);
    });

  }
  load()async{
    if(Get.find<StoreController>().store != null && Get.find<StoreController>().store!.name != null ) {
      Get.find<StoreController>().setCategoryList();
    }

    if(Get.find<StoreController>().isSearching) {
      Get.find<StoreController>().changeSearchStatus(isUpdate: false);
    }
    Get.find<StoreController>().hideAnimation();
    await Get.find<StoreController>().getStoreDetails(Store(id: widget.store!.id), false, ).then((value) {
      Get.find<StoreController>().showButtonAnimation();
    });
    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<StoreController>().getStoreBannerList(widget.store!.id ?? Get.find<StoreController>().store!.id);
    Get.find<StoreController>().getRestaurantRecommendedItemList(widget.store!.id ?? Get.find<StoreController>().store!.id, false);
    Get.find<StoreController>().getStoreItemList(widget.store!.id ?? Get.find<StoreController>().store!.id, 1, 'all', false);
    // widget.store = Get.find<StoreController>().store!;
    Get.find<StoreController>().getCartStoreSuggestedItemList(Get.find<CartController>().cartList[0].item!.storeId);
    Get.find<StoreController>().getStoreDetails(Store(id: Get.find<CartController>().cartList[0].item!.storeId, name: null), false, fromCart: true);  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool isParcel = Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!;
    return GetBuilder<CartController>(
        builder: (cartController) {

          return GetBuilder<ItemController>(
            builder: (itemController) {

              int? stock = 0;
              CartModel? cartModel;
              OnlineCart? cart;
              double priceWithAddons = 0;
              int? cartId = cartController.getCartId(itemController.cartIndex);
              if(itemController.item != null && itemController.variationIndex != null){
                List<String> variationList = [];
                for (int index = 0; index < itemController.item!.choiceOptions!.length; index++) {
                  variationList.add(itemController.item!.choiceOptions![index].options![itemController.variationIndex![index]].replaceAll(' ', ''));
                }
                String variationType = '';
                bool isFirst = true;
                for (var variation in variationList) {
                  if (isFirst) {
                    variationType = '$variationType$variation';
                    isFirst = false;
                  } else {
                    variationType = '$variationType-$variation';
                  }
                }

                double? price = itemController.item!.price;
                Variation? variation;
                stock = itemController.item!.stock ?? 0;
                for (Variation v in itemController.item!.variations!) {
                  if (v.type == variationType) {
                    price = v.price;
                    variation = v;
                    stock = v.stock;
                    break;
                  }
                }

                double? discount = (itemController.item!.availableDateStarts != null || itemController.item!.storeDiscount == 0) ? itemController.item!.discount : itemController.item!.storeDiscount;
                String? discountType = (itemController.item!.availableDateStarts != null || itemController.item!.storeDiscount == 0) ? itemController.item!.discountType : 'percent';
                double priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType)!;
                double priceWithQuantity = priceWithDiscount * itemController.quantity!;
                double addonsCost = 0;
                List<AddOnModel> addOnIdList = [];
                List<AddOns> addOnsList = [];
                for (int index = 0; index < itemController.item!.addOns!.length; index++) {
                  if (itemController.addOnActiveList[index]) {
                    addonsCost = addonsCost + (itemController.item!.addOns![index].price! * itemController.addOnQtyList[index]!);
                    addOnIdList.add(AddOnModel(id: itemController.item!.addOns![index].id, quantity: itemController.addOnQtyList[index]));
                    addOnsList.add(itemController.item!.addOns![index]);
                  }
                }

                cartModel = CartModel(
                    id: null,
                    price: price,
                    discountedPrice: priceWithDiscount,
                    variation: variation != null ? [variation] : [],
                    foodVariations: [],
                    discountAmount: (price! - PriceConverter.convertWithDiscount(price, discount, discountType)!),
                    quantity: itemController.quantity,
                    addOnIds: addOnIdList,
                    addOns: addOnsList,
                    isCampaign: itemController.item!.availableDateStarts != null,
                    stock: stock,
                    item: itemController.item,
                    quantityLimit: itemController.item!.quantityLimit != null ? itemController.item!.quantityLimit! : null
                );
                List<int?> listOfAddOnId = CartHelper.getSelectedAddonIds(addOnIdList: addOnIdList);
                List<int?> listOfAddOnQty = CartHelper.getSelectedAddonQtnList(addOnIdList: addOnIdList);
                cart = OnlineCart(
                    cartId, widget.item!.id, null, priceWithDiscount.toString(), '',
                    variation != null ? [variation] : [], null,
                    itemController.cartIndex != -1 ? cartController.cartList[itemController.cartIndex].quantity
                        : itemController.quantity, listOfAddOnId, addOnsList, listOfAddOnQty, 'Item'
                );
                priceWithAddons = priceWithQuantity + (Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? addonsCost : 0);
              }
              // int cartQty = cartController.cartQuantity(itemController.item!.id!);

              return Scaffold(
                key: _globalKey,
                backgroundColor: Theme.of(context).cardColor,
                endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
                appBar: ResponsiveHelper.isDesktop(context)? const CustomAppBar(title: '')  :  DetailsAppBar(key: _key),

                body: SafeArea(child: (itemController.item != null) ? ResponsiveHelper.isDesktop(context) ? DetailsWebView(
                  cartModel: cartModel, stock: stock, priceWithAddOns: priceWithAddons, cart: cart,
                ) : Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(children: [
                    Expanded(child:
                    Scrollbar(child: Center
                      (child: SizedBox(
                        width: Dimensions.webMaxWidth, child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(itemController.item!.name!),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            child: Row( // or Column
                              children: [
                                Flexible(
                                  child: Text(
                                    '${itemController.item!.name!}' ?? '',
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ItemImageView(item: itemController.item),
                          const SizedBox(height: 20),

                          // المبلغ
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(children: [
                              Text('${'total_amount'.tr}:', style:robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text(
                                PriceConverter.convertPrice(
                                    itemController.cartIndex != -1
                                    ? CartHelper.getItemDetailsDiscountPrice(cart: Get.find<CartController>().cartList[itemController.cartIndex])
                                    : priceWithAddons), textDirection: TextDirection.rtl,
                                style:robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                              ),
                            ]),
                          ),
                          const Divider(height: 20, thickness: 3),



                          itemController.item!.choiceOptions!.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(children: [
                                  Image.asset(Images.time, height: 20, width: 20,color: Theme.of(context).primaryColor,),
                                  const SizedBox(width: 10,),
                                  GetBuilder<StoreController>(builder: (storeController){
                                    Store store = Store();
                                    if(storeController.store != null && storeController.store!.name != null ) {
                                      store = storeController.store!;
                                      storeController.setCategoryList();
                                    }
                                    return Text(" ${'delivery_within'.tr} ${store.deliveryTime ?? '...'} ");
                                  })
                                  ,
                                ],),
                                // const Divider(height: 25, thickness: 1),
                                //
                                // Row(children: [
                                //   Image.asset(Images.change, height: 20, width: 20,color: Theme.of(context).primaryColor,),
                                //   SizedBox(width: 10,),
                                //   Text("you_can_replace".tr),
                                // ],),
                              ],
                            ),
                          ),



                          const Divider(height: 20, thickness: 3),

                          Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [



                              InkWell(onTap: ()=> itemController.selectReviewSection(false),
                                  child: Column(children: [
                                    Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,
                                        vertical: Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                          color: !itemController.isReviewSelected? Get.find<ThemeController>().darkTheme?
                                          Theme.of(context).hintColor.withOpacity(.25) :
                                          Theme.of(context).primaryColor.withOpacity(.05):Colors.transparent),
                                      child: Text('description'.tr,
                                        style: robotoRegular.copyWith(color: Get.find<ThemeController>().darkTheme?
                                        Theme.of(context).hintColor : Theme.of(context).primaryColor),),),
                                    if(!itemController.isReviewSelected)
                                      Container(width: 60, height: 3,color: Theme.of(context).primaryColor,)])),
                              const SizedBox(width: Dimensions.paddingSizeDefault),



                              InkWell(onTap: ()=> itemController.selectReviewSection(true),
                                child: Stack(clipBehavior: Clip.none, children: [
                                  Column(children: [
                                    Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,
                                        vertical: Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                          color:  itemController.isReviewSelected? Get.find<ThemeController>().darkTheme?
                                          Theme.of(context).hintColor.withOpacity(.25) :
                                          Theme.of(context).primaryColor.withOpacity(.05): Colors.transparent),
                                      child: Text('product_evaluation'.tr, style: robotoRegular.copyWith(
                                          color: Get.find<ThemeController>().darkTheme?
                                          Theme.of(context).hintColor : Theme.of(context).primaryColor),),),


                                    if(itemController.isReviewSelected)
                                      Container(width: 60, height: 3,color: Theme.of(context).primaryColor)]),
                                ],
                                ),
                              ),



                            ],),
                          ),
                          itemController.isReviewSelected?
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Builder(
                                  builder: (context) {
                                    return ItemTitleView(
                                      item: itemController.item, inStorePage: widget.inStorePage, isCampaign: itemController.item!.availableDateStarts != null,
                                      inStock: (Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0),
                                    );
                                  }
                              ),
                            ],
                          ) : ( (itemController.item!.description != null && itemController.item!.description!.isNotEmpty) ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text('description'.tr, style: robotoMedium),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(itemController.item!.description!, style: robotoRegular.copyWith(fontSize: 16,height: 1.3)),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                            ],
                          ) : const SizedBox()),
                        ],
                      ),
                    ))),
                    )),

                    GetBuilder<CartController>(
                        builder: (cartController) {
                          return Container(
                            width: 1170,
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: CartCountViewDetails(
                              item: itemController.item!, itemController: itemController, keyGlobalKey: _key,
                            ),
                          );
                        }
                    ),

                  ]),
                ) : const Center(child: CircularProgressIndicator())),
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
                ],
                ),
              );
            },
          );
        }
    );
  }
  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

}
class ItemDetailsScreenHome extends StatefulWidget {
  final ItemsHome? item;
  final bool inStorePage;
  Store? store;

  ItemDetailsScreenHome({Key? key, required this.item, required this.inStorePage,required this.store, }) : super(key: key);

  @override
  State<ItemDetailsScreenHome> createState() => _ItemDetailsScreenHomeState();
}

class _ItemDetailsScreenHomeState extends State<ItemDetailsScreenHome>  with TickerProviderStateMixin {
  final Size size = Get.size;
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  final GlobalKey<DetailsAppBarState> _key = GlobalKey();
  TabController? tabController;
  late final bool? inStorePage;
  Store store = Store();
  int _pageIndex = 0;
  PageController? _pageController;


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);

    tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    Future.delayed(Duration.zero, () {
      load();
      Get.find<ItemController>().getProductDetailsHome(widget.item!);
    });

  }
  load()async{
    if(Get.find<StoreController>().store != null && Get.find<StoreController>().store!.name != null ) {
      Get.find<StoreController>().setCategoryList();
    }

    if(Get.find<StoreController>().isSearching) {
      Get.find<StoreController>().changeSearchStatus(isUpdate: false);
    }
    Get.find<StoreController>().hideAnimation();
    await Get.find<StoreController>().getStoreDetails(Store(id: widget.store!.id), false, ).then((value) {
      Get.find<StoreController>().showButtonAnimation();
    });
    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<StoreController>().getStoreBannerList(widget.store!.id ?? Get.find<StoreController>().store!.id);
    Get.find<StoreController>().getRestaurantRecommendedItemList(widget.store!.id ?? Get.find<StoreController>().store!.id, false);
    Get.find<StoreController>().getStoreItemList(widget.store!.id ?? Get.find<StoreController>().store!.id, 1, 'all', false);
    // widget.store = Get.find<StoreController>().store!;
    Get.find<StoreController>().getCartStoreSuggestedItemList(Get.find<CartController>().cartList[0].item!.storeId);
    Get.find<StoreController>().getStoreDetails(Store(id: Get.find<CartController>().cartList[0].item!.storeId, name: null), false, fromCart: true);  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool isParcel = Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!;
    return GetBuilder<CartController>(
        builder: (cartController) {

          return GetBuilder<ItemController>(
            builder: (itemController) {

              int? stock = 0;
              CartModel? cartModel;
              OnlineCart? cart;
              double priceWithAddons = 0;
              int? cartId = cartController.getCartId(itemController.cartIndex);
              if(itemController.item != null && itemController.variationIndex != null){
                List<String> variationList = [];
                for (int index = 0; index < itemController.item!.choiceOptions!.length; index++) {
                  variationList.add(itemController.item!.choiceOptions![index].options![itemController.variationIndex![index]].replaceAll(' ', ''));
                }
                String variationType = '';
                bool isFirst = true;
                for (var variation in variationList) {
                  if (isFirst) {
                    variationType = '$variationType$variation';
                    isFirst = false;
                  } else {
                    variationType = '$variationType-$variation';
                  }
                }

                double? price = itemController.item!.price;
                Variation? variation;
                stock = itemController.item!.stock ?? 0;
                for (Variation v in itemController.item!.variations!) {
                  if (v.type == variationType) {
                    price = v.price;
                    variation = v;
                    stock = v.stock;
                    break;
                  }
                }

                double? discount = (itemController.item!.availableDateStarts != null || itemController.item!.storeDiscount == 0) ? itemController.item!.discount : itemController.item!.storeDiscount;
                String? discountType = (itemController.item!.availableDateStarts != null || itemController.item!.storeDiscount == 0) ? itemController.item!.discountType : 'percent';
                double priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType)!;
                double priceWithQuantity = priceWithDiscount * itemController.quantity!;
                double addonsCost = 0;
                List<AddOnModel> addOnIdList = [];
                List<AddOns> addOnsList = [];
                for (int index = 0; index < itemController.item!.addOns!.length; index++) {
                  if (itemController.addOnActiveList[index]) {
                    addonsCost = addonsCost + (itemController.item!.addOns![index].price! * itemController.addOnQtyList[index]!);
                    addOnIdList.add(AddOnModel(id: itemController.item!.addOns![index].id, quantity: itemController.addOnQtyList[index]));
                    addOnsList.add(itemController.item!.addOns![index]);
                  }
                }

                cartModel = CartModel(
                    id: null,
                    price: price,
                    discountedPrice: priceWithDiscount,
                    variation: variation != null ? [variation] : [],
                    foodVariations: [],
                    discountAmount: (price! - PriceConverter.convertWithDiscount(price, discount, discountType)!),
                    quantity: itemController.quantity,
                    addOnIds: addOnIdList,
                    addOns: addOnsList,
                    isCampaign: itemController.item!.availableDateStarts != null,
                    stock: stock,
                    item: itemController.item,
                    quantityLimit: itemController.item!.quantityLimit != null ? itemController.item!.quantityLimit! : null
                );
                List<int?> listOfAddOnId = CartHelper.getSelectedAddonIds(addOnIdList: addOnIdList);
                List<int?> listOfAddOnQty = CartHelper.getSelectedAddonQtnList(addOnIdList: addOnIdList);
                cart = OnlineCart(
                    cartId, widget.item!.id, null, priceWithDiscount.toString(), '',
                    variation != null ? [variation] : [], null,
                    itemController.cartIndex != -1 ? cartController.cartList[itemController.cartIndex].quantity
                        : itemController.quantity, listOfAddOnId, addOnsList, listOfAddOnQty, 'Item'
                );
                priceWithAddons = priceWithQuantity + (Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? addonsCost : 0);
              }
              // int cartQty = cartController.cartQuantity(itemController.item!.id!);

              return Scaffold(
                key: _globalKey,
                backgroundColor: Theme.of(context).cardColor,
                endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
                appBar: ResponsiveHelper.isDesktop(context)? const CustomAppBar(title: '')  :  DetailsAppBar(key: _key),

                body: SafeArea(child: (itemController.item != null) ? ResponsiveHelper.isDesktop(context) ? DetailsWebView(
                  cartModel: cartModel, stock: stock, priceWithAddOns: priceWithAddons, cart: cart,
                ) : Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(children: [
                    Expanded(child:
                    Scrollbar(child: Center
                      (child: SizedBox(
                        width: Dimensions.webMaxWidth, child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(itemController.item!.name!),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            child: Row( // or Column
                              children: [
                                Flexible(
                                  child: Text(
                                    '${itemController.item!.name!}' ?? '',
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ItemImageView(item: itemController.item),
                          const SizedBox(height: 20),

                          // المبلغ
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(children: [
                              Text('${'total_amount'.tr}:', style:robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text(
                                PriceConverter.convertPrice(
                                    itemController.cartIndex != -1
                                        ? CartHelper.getItemDetailsDiscountPrice(cart: Get.find<CartController>().cartList[itemController.cartIndex])
                                        : priceWithAddons), textDirection: TextDirection.rtl,
                                style:robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                              ),
                            ]),
                          ),
                          const Divider(height: 20, thickness: 3),



                          itemController.item!.choiceOptions!.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(children: [
                                  Image.asset(Images.time, height: 20, width: 20,color: Theme.of(context).primaryColor,),
                                  const SizedBox(width: 10,),
                                  GetBuilder<StoreController>(builder: (storeController){
                                    Store store = Store();
                                    if(storeController.store != null && storeController.store!.name != null ) {
                                      store = storeController.store!;
                                      storeController.setCategoryList();
                                    }
                                    return Text(" ${'delivery_within'.tr} ${store.deliveryTime ?? '...'} ");
                                  })
                                  ,
                                ],),
                                // const Divider(height: 25, thickness: 1),
                                //
                                // Row(children: [
                                //   Image.asset(Images.change, height: 20, width: 20,color: Theme.of(context).primaryColor,),
                                //   SizedBox(width: 10,),
                                //   Text("you_can_replace".tr),
                                // ],),
                              ],
                            ),
                          ),



                          const Divider(height: 20, thickness: 3),

                          Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [



                              InkWell(onTap: ()=> itemController.selectReviewSection(false),
                                  child: Column(children: [
                                    Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,
                                        vertical: Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                          color: !itemController.isReviewSelected? Get.find<ThemeController>().darkTheme?
                                          Theme.of(context).hintColor.withOpacity(.25) :
                                          Theme.of(context).primaryColor.withOpacity(.05):Colors.transparent),
                                      child: Text('description'.tr,
                                        style: robotoRegular.copyWith(color: Get.find<ThemeController>().darkTheme?
                                        Theme.of(context).hintColor : Theme.of(context).primaryColor),),),
                                    if(!itemController.isReviewSelected)
                                      Container(width: 60, height: 3,color: Theme.of(context).primaryColor,)])),
                              const SizedBox(width: Dimensions.paddingSizeDefault),



                              InkWell(onTap: ()=> itemController.selectReviewSection(true),
                                child: Stack(clipBehavior: Clip.none, children: [
                                  Column(children: [
                                    Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,
                                        vertical: Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                          color:  itemController.isReviewSelected? Get.find<ThemeController>().darkTheme?
                                          Theme.of(context).hintColor.withOpacity(.25) :
                                          Theme.of(context).primaryColor.withOpacity(.05): Colors.transparent),
                                      child: Text('product_evaluation'.tr, style: robotoRegular.copyWith(
                                          color: Get.find<ThemeController>().darkTheme?
                                          Theme.of(context).hintColor : Theme.of(context).primaryColor),),),


                                    if(itemController.isReviewSelected)
                                      Container(width: 60, height: 3,color: Theme.of(context).primaryColor)]),
                                ],
                                ),
                              ),



                            ],),
                          ),
                          itemController.isReviewSelected?
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Builder(
                                  builder: (context) {
                                    return ItemTitleView(
                                      item: itemController.item, inStorePage: widget.inStorePage, isCampaign: itemController.item!.availableDateStarts != null,
                                      inStock: (Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0),
                                    );
                                  }
                              ),
                            ],
                          ) : ( (itemController.item!.description != null && itemController.item!.description!.isNotEmpty) ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text('description'.tr, style: robotoMedium),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(itemController.item!.description!, style: robotoRegular.copyWith(fontSize: 16,height: 1.3)),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                            ],
                          ) : const SizedBox()),
                        ],
                      ),
                    ))),
                    )),

                    GetBuilder<CartController>(
                        builder: (cartController) {
                          return Container(
                            width: 1170,
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: CartCountViewDetails(
                              item: itemController.item!, itemController: itemController, keyGlobalKey: _key,
                            ),
                          );
                        }
                    ),

                  ]),
                ) : const Center(child: CircularProgressIndicator())),
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
                ],
                ),
              );
            },
          );
        }
    );
  }
  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

}

class ItemDetailsScreenSections extends StatefulWidget {
  final Item? item;
  final bool inStorePage;
  Store? store;

  ItemDetailsScreenSections({Key? key, required this.item, required this.inStorePage,required this.store, }) : super(key: key);

  @override
  State<ItemDetailsScreenSections> createState() => _ItemDetailsScreenStateSections();
}

class _ItemDetailsScreenStateSections extends State<ItemDetailsScreenSections>  with TickerProviderStateMixin {
  final Size size = Get.size;
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  final GlobalKey<DetailsAppBarState> _key = GlobalKey();
  TabController? tabController;
  late final bool? inStorePage;
  Store store = Store();
  int _pageIndex = 1;
  PageController? _pageController;


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);

    tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    Future.delayed(Duration.zero, () {
      load();
      Get.find<ItemController>().getProductDetails(widget.item!);
    });

  }
  load()async{
    if(Get.find<StoreController>().store != null && Get.find<StoreController>().store!.name != null ) {
      Get.find<StoreController>().setCategoryList();
    }

    if(Get.find<StoreController>().isSearching) {
      Get.find<StoreController>().changeSearchStatus(isUpdate: false);
    }
    Get.find<StoreController>().hideAnimation();
    await Get.find<StoreController>().getStoreDetails(Store(id: widget.store!.id), false, ).then((value) {
      Get.find<StoreController>().showButtonAnimation();
    });
    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<StoreController>().getStoreBannerList(widget.store!.id ?? Get.find<StoreController>().store!.id);
    Get.find<StoreController>().getRestaurantRecommendedItemList(widget.store!.id ?? Get.find<StoreController>().store!.id, false);
    Get.find<StoreController>().getStoreItemList(widget.store!.id ?? Get.find<StoreController>().store!.id, 1, 'all', false);
    // widget.store = Get.find<StoreController>().store!;
    Get.find<StoreController>().getCartStoreSuggestedItemList(Get.find<CartController>().cartList[0].item!.storeId);
    Get.find<StoreController>().getStoreDetails(Store(id: Get.find<CartController>().cartList[0].item!.storeId, name: null), false, fromCart: true);  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool isParcel = Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!;
    return GetBuilder<CartController>(
        builder: (cartController) {

          return GetBuilder<ItemController>(
            builder: (itemController) {

              int? stock = 0;
              CartModel? cartModel;
              OnlineCart? cart;
              double priceWithAddons = 0;
              int? cartId = cartController.getCartId(itemController.cartIndex);
              if(itemController.item != null && itemController.variationIndex != null){
                List<String> variationList = [];
                for (int index = 0; index < itemController.item!.choiceOptions!.length; index++) {
                  variationList.add(itemController.item!.choiceOptions![index].options![itemController.variationIndex![index]].replaceAll(' ', ''));
                }
                String variationType = '';
                bool isFirst = true;
                for (var variation in variationList) {
                  if (isFirst) {
                    variationType = '$variationType$variation';
                    isFirst = false;
                  } else {
                    variationType = '$variationType-$variation';
                  }
                }

                double? price = itemController.item!.price;
                Variation? variation;
                stock = itemController.item!.stock ?? 0;
                for (Variation v in itemController.item!.variations!) {
                  if (v.type == variationType) {
                    price = v.price;
                    variation = v;
                    stock = v.stock;
                    break;
                  }
                }

                double? discount = (itemController.item!.availableDateStarts != null || itemController.item!.storeDiscount == 0) ? itemController.item!.discount : itemController.item!.storeDiscount;
                String? discountType = (itemController.item!.availableDateStarts != null || itemController.item!.storeDiscount == 0) ? itemController.item!.discountType : 'percent';
                double priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType)!;
                double priceWithQuantity = priceWithDiscount * itemController.quantity!;
                double addonsCost = 0;
                List<AddOnModel> addOnIdList = [];
                List<AddOns> addOnsList = [];
                for (int index = 0; index < itemController.item!.addOns!.length; index++) {
                  if (itemController.addOnActiveList[index]) {
                    addonsCost = addonsCost + (itemController.item!.addOns![index].price! * itemController.addOnQtyList[index]!);
                    addOnIdList.add(AddOnModel(id: itemController.item!.addOns![index].id, quantity: itemController.addOnQtyList[index]));
                    addOnsList.add(itemController.item!.addOns![index]);
                  }
                }


                cartModel = CartModel(
                    id: null,
                    price: price,
                    discountedPrice: priceWithDiscount,
                    variation: variation != null ? [variation] : [],
                    foodVariations: [],
                    discountAmount: (price! - PriceConverter.convertWithDiscount(price, discount, discountType)!),
                    quantity: itemController.quantity,
                    addOnIds: addOnIdList,
                    addOns: addOnsList,
                    isCampaign: itemController.item!.availableDateStarts != null,
                    stock: stock,
                    item: itemController.item,
                    quantityLimit: itemController.item!.quantityLimit
                );
                List<int?> listOfAddOnId = CartHelper.getSelectedAddonIds(addOnIdList: addOnIdList);
                List<int?> listOfAddOnQty = CartHelper.getSelectedAddonQtnList(addOnIdList: addOnIdList);
                cart = OnlineCart(
                    cartId, widget.item!.id, null, priceWithDiscount.toString(), '',
                    variation != null ? [variation] : [], null,
                    itemController.cartIndex != -1 ? cartController.cartList[itemController.cartIndex].quantity
                        : itemController.quantity, listOfAddOnId, addOnsList, listOfAddOnQty, 'Item'
                );
                priceWithAddons = priceWithQuantity + (Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? addonsCost : 0);
              }
              // int cartQty = cartController.cartQuantity(itemController.item!.id!);

              return Scaffold(
                key: _globalKey,
                backgroundColor: Theme.of(context).cardColor,
                endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
                appBar: ResponsiveHelper.isDesktop(context)? const CustomAppBar(title: '')  :  DetailsAppBar(key: _key),

                body: SafeArea(child: (itemController.item != null) ? ResponsiveHelper.isDesktop(context) ? DetailsWebView(
                  cartModel: cartModel, stock: stock, priceWithAddOns: priceWithAddons, cart: cart,
                ) : Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(children: [
                    Expanded(child:
                    Scrollbar(child: Center
                      (child: SizedBox(
                        width: Dimensions.webMaxWidth, child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(itemController.item!.name!),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            child: Row( // or Column
                              children: [
                                Flexible(
                                  child: Text(
                                    '${itemController.item!.name!}' ?? '',
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ItemImageView(item: itemController.item),
                          const SizedBox(height: 20),

                          // المبلغ
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(children: [
                              Text('${'total_amount'.tr}:', style:robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text(
                                PriceConverter.convertPrice(
                                    itemController.cartIndex != -1
                                        ? CartHelper.getItemDetailsDiscountPrice(cart: Get.find<CartController>().cartList[itemController.cartIndex])
                                        : priceWithAddons), textDirection: TextDirection.rtl,
                                style:robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                              ),
                            ]),
                          ),
                          const Divider(height: 20, thickness: 3),



                          itemController.item!.choiceOptions!.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(children: [
                                  Image.asset(Images.time, height: 20, width: 20,color: Theme.of(context).primaryColor,),
                                  const SizedBox(width: 10,),
                                  GetBuilder<StoreController>(builder: (storeController){
                                    Store store = Store();
                                    if(storeController.store != null && storeController.store!.name != null ) {
                                      store = storeController.store!;
                                      storeController.setCategoryList();
                                    }
                                    return Text(" ${'delivery_within'.tr} ${store.deliveryTime ?? '...'} ");
                                  })
                                  ,
                                ],),
                                // const Divider(height: 25, thickness: 1),
                                //
                                // Row(children: [
                                //   Image.asset(Images.change, height: 20, width: 20,color: Theme.of(context).primaryColor,),
                                //   SizedBox(width: 10,),
                                //   Text("you_can_replace".tr),
                                // ],),
                              ],
                            ),
                          ),



                          const Divider(height: 20, thickness: 3),

                          Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [



                              InkWell(onTap: ()=> itemController.selectReviewSection(false),
                                  child: Column(children: [
                                    Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,
                                        vertical: Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                          color: !itemController.isReviewSelected? Get.find<ThemeController>().darkTheme?
                                          Theme.of(context).hintColor.withOpacity(.25) :
                                          Theme.of(context).primaryColor.withOpacity(.05):Colors.transparent),
                                      child: Text('description'.tr,
                                        style: robotoRegular.copyWith(color: Get.find<ThemeController>().darkTheme?
                                        Theme.of(context).hintColor : Theme.of(context).primaryColor),),),
                                    if(!itemController.isReviewSelected)
                                      Container(width: 60, height: 3,color: Theme.of(context).primaryColor,)])),
                              const SizedBox(width: Dimensions.paddingSizeDefault),



                              InkWell(onTap: ()=> itemController.selectReviewSection(true),
                                child: Stack(clipBehavior: Clip.none, children: [
                                  Column(children: [
                                    Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,
                                        vertical: Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                          color:  itemController.isReviewSelected? Get.find<ThemeController>().darkTheme?
                                          Theme.of(context).hintColor.withOpacity(.25) :
                                          Theme.of(context).primaryColor.withOpacity(.05): Colors.transparent),
                                      child: Text('product_evaluation'.tr, style: robotoRegular.copyWith(
                                          color: Get.find<ThemeController>().darkTheme?
                                          Theme.of(context).hintColor : Theme.of(context).primaryColor),),),


                                    if(itemController.isReviewSelected)
                                      Container(width: 60, height: 3,color: Theme.of(context).primaryColor)]),
                                ],
                                ),
                              ),



                            ],),
                          ),
                          itemController.isReviewSelected?
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Builder(
                                  builder: (context) {
                                    return ItemTitleView(
                                      item: itemController.item, inStorePage: widget.inStorePage, isCampaign: itemController.item!.availableDateStarts != null,
                                      inStock: (Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0),
                                    );
                                  }
                              ),
                            ],
                          ) : ( (itemController.item!.description != null && itemController.item!.description!.isNotEmpty) ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text('description'.tr, style: robotoMedium),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(itemController.item!.description!, style: robotoRegular.copyWith(fontSize: 16,height: 1.3)),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                            ],
                          ) : const SizedBox()),
                        ],
                      ),
                    ))),
                    )),

                    GetBuilder<CartController>(
                        builder: (cartController) {
                          return Container(
                            width: 1170,
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: CartCountViewDetails(
                              item: itemController.item!, itemController: itemController, keyGlobalKey: _key,
                            ),
                          );
                        }
                    ),

                  ]),
                ) : const Center(child: CircularProgressIndicator())),
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
                        title: 'orders'.tr, selectedIcon: Images.searchIcon, unSelectedIcon: Images.searchIcon,
                        isSelected: _pageIndex == 3, onTap: () => Get.toNamed(
                          RouteHelper.getSearchRoute()),
                      ),
                      BottomNavItem(
                        title: 'menu'.tr, selectedIcon: Images.menu, unSelectedIcon: Images.menu,
                        isSelected: _pageIndex == 4, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> const DashboardScreen(pageIndex: 4,))),
                      ),
                    ]),
                  ),
                ],
                ),
              );
            },
          );
        }
    );
  }
  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

}
class CartCountViewDetails extends StatefulWidget {
  final Item item;
  final Widget? child;
  final ItemController? itemController;
  final GlobalKey<DetailsAppBarState> keyGlobalKey;
  const CartCountViewDetails({Key? key, required this.item, this.child, required this.itemController, required this.keyGlobalKey}) : super(key: key);

  @override
  State<CartCountViewDetails> createState() => _CartCountViewDetailsState();
}

class _CartCountViewDetailsState extends State<CartCountViewDetails> {
  int? stock = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(widget.item.id!);
      int cartIndex = cartController.isExistInCart(widget.item.id, cartController.cartVariant(widget.item.id!), false, null);
      CartModel? cartModel;
      OnlineCart? cart;
      double priceWithAddons = 0;
      int? cartId = cartController.getCartId(widget.itemController!.cartIndex);
      if(widget.itemController!.item != null && widget.itemController!.variationIndex != null){
        List<String> variationList = [];
        for (int index = 0; index < widget.itemController!.item!.choiceOptions!.length; index++) {
          variationList.add(widget.itemController!.item!.choiceOptions![index].options![widget.itemController!.variationIndex![index]].replaceAll(' ', ''));
        }
        String variationType = '';
        bool isFirst = true;
        for (var variation in variationList) {
          if (isFirst) {
            variationType = '$variationType$variation';
            isFirst = false;
          } else {
            variationType = '$variationType-$variation';
          }
        }

        double? price = widget.itemController!.item!.price;
        Variation? variation;
        stock = widget.itemController!.item!.stock ?? 0;
        for (Variation v in widget.itemController!.item!.variations!) {
          if (v.type == variationType) {
            price = v.price;
            variation = v;
            stock = v.stock;
            break;
          }
        }

        double? discount = (widget.itemController!.item!.availableDateStarts != null || widget.itemController!.item!.storeDiscount == 0) ? widget.itemController!.item!.discount : widget.itemController!.item!.storeDiscount;
        String? discountType = (widget.itemController!.item!.availableDateStarts != null || widget.itemController!.item!.storeDiscount == 0) ? widget.itemController!.item!.discountType : 'percent';
        double priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType)!;
        double priceWithQuantity = priceWithDiscount * widget.itemController!.quantity!;
        double addonsCost = 0;
        List<AddOnModel> addOnIdList = [];
        List<AddOns> addOnsList = [];
        for (int index = 0; index < widget.itemController!.item!.addOns!.length; index++) {
          if (widget.itemController!.addOnActiveList[index]) {
            addonsCost = addonsCost + (widget.itemController!.item!.addOns![index].price! * widget.itemController!.addOnQtyList[index]!);
            addOnIdList.add(AddOnModel(id: widget.itemController!.item!.addOns![index].id, quantity: widget.itemController!.addOnQtyList[index]));
            addOnsList.add(widget.itemController!.item!.addOns![index]);
          }
        }

        cartModel = CartModel(
            id: null,
            price: price,
            discountedPrice: priceWithDiscount,
            variation: variation != null ? [variation] : [],
            foodVariations: [],
            discountAmount: (price! - PriceConverter.convertWithDiscount(price, discount, discountType)!),
            quantity: widget.itemController!.quantity,
            addOnIds: addOnIdList,
            addOns: addOnsList,
            isCampaign: widget.itemController!.item!.availableDateStarts != null,
            stock: stock,
            item: widget.itemController!.item,
            quantityLimit: widget.itemController!.item!.quantityLimit
        );
        List<int?> listOfAddOnId = CartHelper.getSelectedAddonIds(addOnIdList: addOnIdList);
        List<int?> listOfAddOnQty = CartHelper.getSelectedAddonQtnList(addOnIdList: addOnIdList);
        cart = OnlineCart(
            cartId, widget.item!.id, null, priceWithDiscount.toString(), '',
            variation != null ? [variation] : [], null,
            widget.itemController!.cartIndex != -1 ? cartController.cartList[widget.itemController!.cartIndex].quantity
                : widget.itemController!.quantity, listOfAddOnId, addOnsList, listOfAddOnQty, 'Item'
        );
        priceWithAddons = priceWithQuantity + (Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? addonsCost : 0);
      }
      return cartQty != 0 ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          InkWell(
            onTap: cartController.isLoading ? null : () {
              if (cartController.cartList[cartIndex].quantity! > 1) {
                cartController.setQuantity(false, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].item!.quantityLimit);
              }else {
                cartController.removeFromCart(cartIndex);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withOpacity(.3),
                shape: BoxShape.circle,
                // border: Border.all(color: Theme.of(context).primaryColor),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Icon(
                Icons.remove, size: 16,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: !cartController.isLoading ? Text(
              cartQty.toString(),
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.black),
            ) : SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Theme.of(context).cardColor)),
          ),

          InkWell(
            onTap: cartController.isLoading ? null : () {
              cartController.setQuantity(true, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].quantityLimit);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                // border: Border.all(color: Theme.of(context).primaryColor),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Icon(
                Icons.add, size: 16, color: Theme.of(context).cardColor,
              ),
            ),
          ),
        ]),
      ): CustomButton(
        isLoading: cartController.isLoading,
        buttonText: (Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0) ? 'out_of_stock'.tr
            : widget.itemController!.item!.availableDateStarts != null ? 'order_now'.tr : widget.itemController!.cartIndex != -1 ? 'update_in_cart'.tr : 'add_to_cart'.tr,
        onPressed: (!Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || stock! > 0) ?  () async {
          if(!Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || stock! > 0) {
            cartController.updateAdd();

            if(widget.itemController!.item!.availableDateStarts != null) {

              Get.toNamed(RouteHelper.getCheckoutRoute('campaign'), arguments: CheckoutScreen(
                storeId: null, fromCart: false, cartList: [cartModel!],
              ));
            }else {
              if (cartController.existAnotherStoreItem(cartModel!.item!.storeId, Get.find<SplashController>().module == null ? Get.find<SplashController>().cacheModule!.id : Get.find<SplashController>().module!.id)) {
                Get.dialog(ConfirmationDialog(
                  icon: Images.warning,
                  title: 'are_you_sure_to_reset'.tr,
                  description: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                      ? 'if_you_continue'.tr : 'if_you_continue_without_another_store'.tr,
                  onYesPressed: () {
                    Get.back();
                    cartController.clearCartOnline().then((success) async {
                      if(success) {
                        await cartController.addToCartOnline(cart!);
                        widget.itemController!.setExistInCart(widget.item);
                        showCartSnackBar();
                      }
                    });

                  },
                ), barrierDismissible: false);
              } else {
                if(widget.itemController!.cartIndex == -1) {
                  await cartController.addToCartOnline(cart!).then((success) {
                    if(success){
                      widget.itemController!.setExistInCart(widget.item);
                      showCartSnackBar();
                      widget.keyGlobalKey.currentState!.shake();
                    }
                  });
                } else {
                  await cartController.updateCartOnline(cart!).then((success) {
                    if(success) {
                      showCartSnackBar();
                      widget.keyGlobalKey.currentState!.shake();
                    }
                  });
                }

              }
            }
          }
        } : null,
      );
    });
  }
}



