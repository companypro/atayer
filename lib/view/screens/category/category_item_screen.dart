import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/category_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/cart_widget.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/veg_filter_widget.dart';
import 'package:sixam_mart/view/base/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/home/home_screen.dart';

import '../../../controller/parcel_controller.dart';
import '../../../util/images.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/widget/bottom_nav_item.dart';
import '../dashboard/widget/parcel_bottom_sheet.dart';
import '../menu/menu_screen_new.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryItemScreen({Key? key, required this.categoryID, required this.categoryName}) : super(key: key);

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController storeScrollController = ScrollController();
  TabController? _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _pageIndex = 0;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    Get.find<CategoryController>().getSubCategoryList(widget.categoryID);
    Get.find<CartController>().addItem();

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryItemList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryItemList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,
          );
        }
      }
    });
    storeScrollController.addListener(() {
      if (storeScrollController.position.pixels == storeScrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryStoreList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().restPageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryStoreList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool isParcel = Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!;

    return GetBuilder<CategoryController>(builder: (catController) {

      List<Item>? item;
      List<Store>? stores;
      if(catController.isSearching ? catController.searchItemList != null : catController.categoryItemList != null) {
        item = [];
        if (catController.isSearching) {
          item.addAll(catController.searchItemList!);
        } else {
          item.addAll(catController.categoryItemList!);
        }
      }
      if(catController.isSearching ? catController.searchStoreList != null : catController.categoryStoreList != null) {
        stores = [];
        if (catController.isSearching) {
          stores.addAll(catController.searchStoreList!);
        } else {
          stores.addAll(catController.categoryStoreList!);
        }
      }

      return WillPopScope(
        onWillPop: () async {
          if(catController.isSearching) {
            catController.toggleSearch();
            return false;
          }else {
            return true;
          }
        },
        child: Scaffold(
          appBar: (ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : AppBar(
            title: catController.isSearching ? TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
              onSubmitted: (String query) {
                catController.searchData(
                  query, catController.subCategoryIndex == 0 ? widget.categoryID
                    : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                  catController.type,
                );
              }
            ) : Text(widget.categoryName, style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color,
            )),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () {
                if(catController.isSearching) {
                  catController.toggleSearch();
                }else {
                  Get.back();
                }
              },
            ),
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => catController.toggleSearch(),
                icon: Icon(
                  catController.isSearching ? Icons.close_sharp : Icons.search,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              IconButton(
                onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                icon: CartWidget(color: Theme.of(context).textTheme.bodyLarge!.color, size: 25),
              ),

              VegFilterWidget(type: catController.type, fromAppBar: true, onSelected: (String type) {
                if(catController.isSearching) {
                  catController.searchData(
                    catController.subCategoryIndex == 0 ? widget.categoryID
                        : catController.subCategoryList![catController.subCategoryIndex].id.toString(), '1', type,
                  );
                }else {
                  if(catController.isStore) {
                    catController.getCategoryStoreList(
                      catController.subCategoryIndex == 0 ? widget.categoryID
                          : catController.subCategoryList![catController.subCategoryIndex].id.toString(), 1, type, true,
                    );
                  }else {
                    catController.getCategoryItemList(
                      catController.subCategoryIndex == 0 ? widget.categoryID
                          : catController.subCategoryList![catController.subCategoryIndex].id.toString(), 1, type, true,
                    );
                  }
                }
              }),
            ],
          )) as PreferredSizeWidget?,
          endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
          body: Center(child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Column(children: [

              (catController.subCategoryList != null && !catController.isSearching) ? Center(child: Container(
                height: 40, width: Dimensions.webMaxWidth, color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                child: ListView.builder(
                  key: scaffoldKey,
                  scrollDirection: Axis.horizontal,
                  itemCount: catController.subCategoryList!.length,
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => catController.setSubCategoryIndex(index, widget.categoryID),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          color: index == catController.subCategoryIndex ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            catController.subCategoryList![index].name!,
                            style: index == catController.subCategoryIndex
                                ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              )) : const SizedBox(),

              // Center(child: Container(
              //   width: Dimensions.webMaxWidth,
              //   color: Theme.of(context).cardColor,
              //   child: TabBar(
              //     controller: _tabController,
              //     indicatorColor: Theme.of(context).primaryColor,
              //     indicatorWeight: 3,
              //     labelColor: Theme.of(context).primaryColor,
              //     unselectedLabelColor: Theme.of(context).disabledColor,
              //     unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
              //     labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
              //     tabs: [
              //       Tab(text: 'item'.tr),
              //     ],
              //   ),
              // )),


              Expanded(child: NotificationListener(
                onNotification: (dynamic scrollNotification) {
                  if (scrollNotification is ScrollEndNotification) {
                    if((_tabController!.index == 1 && !catController.isStore) || _tabController!.index == 0 && catController.isStore) {
                      catController.setRestaurant(_tabController!.index == 1);
                      if(catController.isSearching) {
                        catController.searchData(
                          catController.searchText, catController.subCategoryIndex == 0 ? widget.categoryID
                            : catController.subCategoryList![catController.subCategoryIndex].id.toString(), catController.type,
                        );
                      }else {
                        if(_tabController!.index == 1) {
                          catController.getCategoryStoreList(
                            catController.subCategoryIndex == 0 ? widget.categoryID
                                : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                            1, catController.type, false,
                          );
                        }else {
                          catController.getCategoryItemList(
                            catController.subCategoryIndex == 0 ? widget.categoryID
                                : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                            1, catController.type, false,
                          );
                        }
                      }
                    }
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: ItemsView(
                    isStore: false, items: item, stores: null, noDataText: 'no_category_item_found'.tr,
                  ),
                ),
              )),

              catController.isLoading ? Center(child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
              )) : const SizedBox(),

            ]),
          )),
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
                  isSelected: _pageIndex == 1, onTap: () {
                  // Navigator.pushNamed(context, RouteHelper.sections);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const DashboardScreen(pageIndex: 1,)));
                },
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
        ),
      );
    });
  }
  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

}




class CategoryItemScreenSections extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryItemScreenSections({Key? key, required this.categoryID, required this.categoryName}) : super(key: key);

  @override
  CategoryItemScreenStateSections createState() => CategoryItemScreenStateSections();
}

class CategoryItemScreenStateSections extends State<CategoryItemScreenSections> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController storeScrollController = ScrollController();
  TabController? _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _pageIndex = 1;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    Get.find<CategoryController>().getSubCategoryList(widget.categoryID);
    Get.find<CartController>().addItem();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryItemList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryItemList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,
          );
        }
      }
    });
    storeScrollController.addListener(() {
      if (storeScrollController.position.pixels == storeScrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryStoreList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().restPageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryStoreList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool isParcel = Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!;

    return GetBuilder<CategoryController>(builder: (catController) {

      List<Item>? item = [];
      List<Store>? stores;
      if(catController.isSearching ? catController.searchItemList != null : catController.categoryItemList != null) {
        if (catController.isSearching) {
          item.addAll(catController.searchItemList!);
        } else {
          item.addAll(catController.categoryItemList!);
        }
      }
      if(catController.isSearching ? catController.searchStoreList != null : catController.categoryStoreList != null) {
        stores = [];
        if (catController.isSearching) {
          stores.addAll(catController.searchStoreList!);
        } else {
          stores.addAll(catController.categoryStoreList!);
        }
      }

      return WillPopScope(
        onWillPop: () async {
          if(catController.isSearching) {
            catController.toggleSearch();
            return false;
          }else {
            return true;
          }
        },
        child: Scaffold(
          appBar: (ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : AppBar(
            title: catController.isSearching ? TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                onSubmitted: (String query) {
                  catController.searchData(
                    query, catController.subCategoryIndex == 0 ? widget.categoryID
                      : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                    catController.type,
                  );
                }
            ) : Text(widget.categoryName, style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color,
            )),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () {
                if(catController.isSearching) {
                  catController.toggleSearch();
                }else {
                  Get.back();
                }
              },
            ),
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => catController.toggleSearch(),
                icon: Icon(
                  catController.isSearching ? Icons.close_sharp : Icons.search,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              IconButton(
                onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                icon: CartWidget(color: Theme.of(context).textTheme.bodyLarge!.color, size: 25),
              ),

              VegFilterWidget(type: catController.type, fromAppBar: true, onSelected: (String type) {
                if(catController.isSearching) {
                  catController.searchData(
                    catController.subCategoryIndex == 0 ? widget.categoryID
                        : catController.subCategoryList![catController.subCategoryIndex].id.toString(), '1', type,
                  );
                }else {
                  if(catController.isStore) {
                    catController.getCategoryStoreList(
                      catController.subCategoryIndex == 0 ? widget.categoryID
                          : catController.subCategoryList![catController.subCategoryIndex].id.toString(), 1, type, true,
                    );
                  }else {
                    catController.getCategoryItemList(
                      catController.subCategoryIndex == 0 ? widget.categoryID
                          : catController.subCategoryList![catController.subCategoryIndex].id.toString(), 1, type, true,
                    );
                  }
                }
              }),
            ],
          )) as PreferredSizeWidget?,
          endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
          body: Center(child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Column(children: [

              (catController.subCategoryList != null && !catController.isSearching) ? Center(child: Container(
                height: 40, width: Dimensions.webMaxWidth, color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                child: ListView.builder(
                  key: scaffoldKey,
                  scrollDirection: Axis.horizontal,
                  itemCount: catController.subCategoryList!.length,
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => catController.setSubCategoryIndex(index, widget.categoryID),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          color: index == catController.subCategoryIndex ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            catController.subCategoryList![index].name!,
                            style: index == catController.subCategoryIndex
                                ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              )) : const SizedBox(),



              Expanded(child: NotificationListener(
                onNotification: (dynamic scrollNotification) {
                  if (scrollNotification is ScrollEndNotification) {
                    if((_tabController!.index == 1 && !catController.isStore) || _tabController!.index == 0 && catController.isStore) {
                      catController.setRestaurant(_tabController!.index == 1);
                      if(catController.isSearching) {
                        catController.searchData(
                          catController.searchText, catController.subCategoryIndex == 0 ? widget.categoryID
                            : catController.subCategoryList![catController.subCategoryIndex].id.toString(), catController.type,
                        );
                      }else {
                        if(_tabController!.index == 1) {
                          catController.getCategoryStoreList(
                            catController.subCategoryIndex == 0 ? widget.categoryID
                                : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                            1, catController.type, false,
                          );
                        }else {
                          catController.getCategoryItemList(
                            catController.subCategoryIndex == 0 ? widget.categoryID
                                : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                            1, catController.type, false,
                          );
                        }
                      }
                    }
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: ItemsViewSections(
                    isStore: false, items: item, stores: null, noDataText: 'no_category_item_found'.tr,
                  ),
                ),
              )),

              catController.isLoading ? Center(child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
              )) : const SizedBox(),

            ]),
          )),
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
        ),
      );
    });
  }
  void _setPage(int pageIndex) {
    setState(() {
      // _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

}