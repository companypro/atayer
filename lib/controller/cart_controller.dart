import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/api/api_checker.dart';
import 'package:sixam_mart/data/model/body/place_order_body.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart'
    as item_variation;
import 'package:sixam_mart/data/model/response/module_model.dart';
import 'package:sixam_mart/data/model/response/online_cart_model.dart';
import 'package:sixam_mart/data/repository/cart_repo.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/cart_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/screens/home/home_screen.dart';

import '../view/screens/sections/sections.dart';

class CartController extends GetxController implements GetxService {
  final CartRepo cartRepo;
  CartController({required this.cartRepo});

  List<CartModel> _cartList = [];
  List<OnlineCartModel> _onlineCartList = [];
  List<OnlineCartModel> newOnlineCartList = [];
  List<CartModel> freshCartList = [];

  double _subTotal = 0;
  double _itemPrice = 0;
  double _itemDiscountPrice = 0;
  double _addOns = 0;
  double _variationPrice = 0;
  List<List<AddOns>> _addOnsList = [];
  List<bool> _availableList = [];
  List<String> notAvailableList = [
    'Remove it from my cart',
    'I’ll wait until it’s restocked',
    'Please cancel the order',
    'Call me ASAP',
    'Notify me when it’s back'
  ];
  bool _addCutlery = false;
  int _notAvailableIndex = -1;
  int _currentIndex = 0;
  bool _isLoading = false;
  bool isAdd = true;

  List<CartModel> get cartList => _cartList;
  List<OnlineCartModel> get onlineCartList => _onlineCartList;
  double get subTotal => _subTotal;
  double get itemPrice => _itemPrice;
  double get itemDiscountPrice => _itemDiscountPrice;
  double get addOns => _addOns;
  double get variationPrice => _variationPrice;
  List<List<AddOns>> get addOnsList => _addOnsList;
  List<bool> get availableList => _availableList;
  bool get addCutlery => _addCutlery;
  int get notAvailableIndex => _notAvailableIndex;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;

  void setAvailableIndex(int index, {bool isUpdate = true}) {
    if (_notAvailableIndex == index) {
      _notAvailableIndex = -1;
    } else {
      _notAvailableIndex = index;
    }
    if (isUpdate) {
      update();
    }
  }

  void updateCutlery({bool isUpdate = true}) {
    _addCutlery = !_addCutlery;
    if (isUpdate) {
      update();
    }
  }

  double calculationCart() {
    _addOnsList = [];
    _availableList = [];
    _itemPrice = 0;
    _itemDiscountPrice = 0;
    _addOns = 0;
    _variationPrice = 0;
    bool isFoodVariation = false;
    double variationWithoutDiscountPrice = 0;
    bool haveVariation = false;
    for (var cartModel in cartList) {
      isFoodVariation = Get.find<SplashController>()
          .getModuleConfig(cartModel.item!.moduleType)!
          .newVariation!;
      double? discount = cartModel.item!.storeDiscount == 0
          ? cartModel.item!.discount
          : cartModel.item!.storeDiscount;
      String? discountType = cartModel.item!.storeDiscount == 0
          ? cartModel.item!.discountType
          : 'percent';

      List<AddOns> addOnList = [];
      for (var addOnId in cartModel.addOnIds!) {
        for (AddOns addOns in cartModel.item!.addOns!) {
          if (addOns.id == addOnId.id) {
            addOnList.add(addOns);
            break;
          }
        }
      }
      _addOnsList.add(addOnList);

      _availableList.add(DateConverter.isAvailable(
          cartModel.item!.availableTimeStarts,
          cartModel.item!.availableTimeEnds));

      for (int index = 0; index < addOnList.length; index++) {
        _addOns = _addOns +
            (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
      }

      if (isFoodVariation) {
        for (int index = 0;
            index < cartModel.item!.foodVariations!.length;
            index++) {
          for (int i = 0;
              i <
                  cartModel
                      .item!.foodVariations![index].variationValues!.length;
              i++) {
            if (cartModel.foodVariations![index][i]!) {
              _variationPrice += (PriceConverter.convertWithDiscount(
                      cartModel.item!.foodVariations![index].variationValues![i]
                          .optionPrice!,
                      discount,
                      discountType)! *
                  cartModel.quantity!);
            }
          }
        }
      } else {
        String variationType = '';
        for (int i = 0; i < cartModel.variation!.length; i++) {
          variationType = cartModel.variation![i].type!;
        }

        for (item_variation.Variation variation
            in cartModel.item!.variations!) {
          if (variation.type == variationType) {
            _variationPrice = (PriceConverter.convertWithDiscount(
                    variation.price!, discount, discountType)! *
                cartModel.quantity!);
            variationWithoutDiscountPrice =
                (variation.price! * cartModel.quantity!);
            haveVariation = true;
            break;
          }
        }
      }

      double price = haveVariation
          ? variationWithoutDiscountPrice
          : (cartModel.item!.price! * cartModel.quantity!);
      double discountPrice = haveVariation
          ? (variationWithoutDiscountPrice - _variationPrice)
          : (price -
              (PriceConverter.convertWithDiscount(
                      cartModel.item!.price!, discount, discountType)! *
                  cartModel.quantity!));

      _itemPrice = _itemPrice + price;
      _itemDiscountPrice = _itemDiscountPrice + discountPrice;

      haveVariation = false;
    }
    if (isFoodVariation) {
      _subTotal = (_itemPrice - _itemDiscountPrice) + _addOns + _variationPrice;
    } else {
      _subTotal = (_itemPrice - _itemDiscountPrice);
    }

    return _subTotal;
  }

  void getCartData() {
    getCartDataOnline();
  }

  int? getCartId(int cartIndex) {
    if (cartIndex != -1) {
      return _cartList[cartIndex].id!;
    } else {
      return null;
    }
  }

  void setQuantity(
      bool isIncrement, int cartIndex, int? stock, int? quantityLimit) {
    _isLoading = true;
    update();

    int currentQuantity = _cartList[cartIndex].quantity!;
    int newQuantity = isIncrement ? currentQuantity + 1 : currentQuantity - 1;

    if (isIncrement) {
      if ((stock != null && newQuantity > stock) ||
          (quantityLimit != null && newQuantity > quantityLimit)) {
        showCustomSnackBar('out_of_stock'.tr);
        _isLoading = false;
        update();
        return;
      }
    } else if (newQuantity < 0) {
      showCustomSnackBar('cannot_reduce_quantity'.tr);
      _isLoading = false;
      update();
      return;
    }

    _cartList[cartIndex].quantity = newQuantity;
    double discountedPrice =
        calculateDiscountedPrice(_cartList[cartIndex], newQuantity);
    updateCartQuantityOnline(_cartList[cartIndex].id!, discountedPrice,
        newQuantity);
  }

  double calculateDiscountedPrice(CartModel cartModel, int quantity) {
    double? discount = cartModel.item!.storeDiscount == 0
        ? cartModel.item!.discount
        : cartModel.item!.storeDiscount;
    String? discountType = cartModel.item!.storeDiscount == 0
        ? cartModel.item!.discountType
        : 'percent';
    double variationPrice = 0;
    double addonPrice = 0;

    if (Get.find<SplashController>()
        .getModuleConfig(cartModel.item!.moduleType)!
        .newVariation!) {
      for (int index = 0;
          index < cartModel.item!.foodVariations!.length;
          index++) {
        for (int i = 0;
            i < cartModel.item!.foodVariations![index].variationValues!.length;
            i++) {
          if (cartModel.foodVariations![index][i]!) {
            variationPrice += (PriceConverter.convertWithDiscount(
                    cartModel.item!.foodVariations![index].variationValues![i]
                        .optionPrice!,
                    discount,
                    discountType)! *
                cartModel.quantity!);
          }
        }
      }

      List<AddOns> addOnList = [];
      for (var addOnId in cartModel.addOnIds!) {
        for (AddOns addOns in cartModel.item!.addOns!) {
          if (addOns.id == addOnId.id) {
            addOnList.add(addOns);
            break;
          }
        }
      }
      for (int index = 0; index < addOnList.length; index++) {
        addonPrice = addonPrice +
            (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
      }
    }
    double discountedPrice = addonPrice +
        variationPrice +
        (cartModel.item!.price! * quantity) -
        PriceConverter.calculation(
            cartModel.item!.price!, discount, discountType!, quantity);
    return discountedPrice;
  }

  void removeFromCart(int index, {Item? item}) {
    removeCartItemOnline(_cartList[index].id!, item: item);
    if (Get.find<ItemController>().item != null) {
      Get.find<ItemController>().cartIndexSet();
    }
  }

  void removeAddOn(int index, int addOnIndex) {
    _cartList[index].addOnIds!.removeAt(addOnIndex);
    cartRepo.addToCartList(_cartList);
    calculationCart();
    update();
  }

  void clearCartList() {
    _cartList = [];
    _cartList.clear();
    _onlineCartList.clear();
    freshCartList.clear();
    if ((Get.find<AuthController>().isLoggedIn() ||
            Get.find<AuthController>().isGuestLoggedIn()) &&
        (Get.find<SplashController>().module != null ||
            Get.find<SplashController>().cacheModule != null)) {
      clearCartOnline();
    }
  }

  int isExistInCart(
      int? itemID, String variationType, bool isUpdate, int? cartIndex) {
    for (int index = 0; index < _cartList.length; index++) {
      if (_cartList[index].item!.id == itemID &&
          (_cartList[index].variation!.isNotEmpty
              ? _cartList[index].variation![0].type == variationType
              : true)) {
        if ((isUpdate && index == cartIndex)) {
          return -1;
        } else {
          return index;
        }
      }
    }
    return -1;
  }

  bool existAnotherStoreItem(int? storeID, int? moduleId) {
    for (CartModel cartModel in _cartList) {
      if (cartModel.item!.storeId != storeID &&
          cartModel.item!.moduleId == moduleId) {
        return true;
      }
    }
    return false;
  }

  void removeAllAndAddToCart(CartModel cartModel) async {
    _cartList = [];
    for (CartModel cartItem in cartRepo.getCartList()) {
      if (cartItem.item!.moduleId != cartModel.item!.moduleId) {
        _cartList.add(cartItem);
      }
    }
    _cartList.add(cartModel);
    await cartRepo.addToCartList(_cartList);
    getCartData();
    calculationCart();
    Get.find<ItemController>().setExistInCart(cartModel.item, notify: true);
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) {
      update();
    }
  }

  // Future<bool> addToCartOnline(OnlineCart cart) async {
  //   bool success = false;
  //
  //   _isLoading = true;
  //   update();
  //   Response response = await cartRepo.addToCartOnline(cart);
  //   if (response.statusCode == 200) {
  //     List<OnlineCartModel> newOnlineCartList = [];
  //     response.body.forEach((cartJson) => newOnlineCartList.add(OnlineCartModel.fromJson(cartJson)));
  //     List<CartModel> freshCartList = CartHelper.formatOnlineCartToLocalCart(onlineCartModel: newOnlineCartList);
  //
  //     for (var freshCartItem in freshCartList) {
  //       int existingIndex = _cartList.indexWhere((existingItem) => existingItem.id == freshCartItem.id);
  //
  //       if (existingIndex == -1) {  // إذا لم يكن العنصر موجودًا بالفعل، أضفه
  //         _cartList.add(freshCartItem);
  //       } else {
  //         // إذا كان العنصر موجودًا بالفعل، تحديث الكمية فقط إذا أردت ذلك
  //         _cartList[existingIndex].quantity = freshCartItem.quantity; // أو استخدم += لزيادة الكمية
  //       }
  //     }
  //
  //     calculationCart();
  //     success = true;
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   _isLoading = false;
  //   update();
  //
  //   return success;
  // }
  // Future<bool> addToCartOnline(OnlineCart cart) async {
  //   bool success = false;
  //
  //   _isLoading = true;
  //   update();
  //   Response response = await cartRepo.addToCartOnline(cart);
  //   if (response.statusCode == 200) {
  //     List<OnlineCartModel> newOnlineCartList = [];
  //     response.body.forEach((cartJson) => newOnlineCartList.add(OnlineCartModel.fromJson(cartJson)));
  //     List<CartModel> freshCartList = CartHelper.formatOnlineCartToLocalCart(onlineCartModel: newOnlineCartList);
  //     print('freshCartList $freshCartList');
  //     for (var freshCartItem in freshCartList) {
  //       int existingIndex = _cartList.indexWhere((existingItem) => existingItem.id == freshCartItem.id);
  //
  //       if (existingIndex == -1) {  // إذا لم يكن العنصر موجودًا بالفعل، أضفه
  //         _cartList.add(freshCartItem);
  //       } else {
  //         // إذا كان العنصر موجودًا بالفعل، تحديث الكمية فقط إذا أردت ذلك
  //         _cartList[existingIndex].quantity = freshCartItem.quantity; // أو استخدم += لزيادة الكمية
  //       }
  //     }
  //
  //     calculationCart();
  //     success = true;
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   _isLoading = false;
  //   update();
  //
  //   return success;
  // }
  // Future<bool> addToCartOnline(OnlineCart cart) async {
  //   _isLoading = true;
  //   bool success = false;
  //   update();
  //   Response response = await cartRepo.addToCartOnline(cart);
  //   if(response.statusCode == 200) {
  //     _onlineCartList = [];
  //     _cartList = [];
  //     response.body.forEach((cart) => _onlineCartList.add(OnlineCartModel.fromJson(cart)));
  //     _cartList.addAll(CartHelper.formatOnlineCartToLocalCart(onlineCartModel: _onlineCartList));
  //     calculationCart();
  //     success = true;
  //   }else {
  //     ApiChecker.checkApi(response);
  //   }
  //   _isLoading = false;
  //   update();
  //
  //   return success;
  // }

  // Future<bool> addToCartOnline(OnlineCart cart) async {
  //   bool success = false;
  //
  //   _isLoading = true;
  //   update();
  //
  //   // تفريغ قائمة freshCartList قبل إضافة عناصر جديدة
  //   freshCartList.clear();
  //   _onlineCartList.clear();
  //
  //   Response response = await cartRepo.addToCartOnline(cart);
  //
  //   if (response.statusCode == 200) {
  //     print('response ${response.body}');
  //     _onlineCartList = [];
  //
  //     response.body.forEach((cartJson) => _onlineCartList.add(OnlineCartModel.fromJson(cartJson)));
  //
  //     // تحديث قائمة freshCartList من جديد بالعناصر الجديدة فقط
  //     freshCartList = CartHelper.formatOnlineCartToLocalCart(onlineCartModel: _onlineCartList);
  //
  //     print('freshCartList ${freshCartList}');
  //     print('_onlineCartList ${_onlineCartList}');
  //     print('_cartList ${_cartList}');
  //
  //     if (_onlineCartList.isNotEmpty) {
  //
  //
  //       for (var freshCartItem in freshCartList) {
  //         int existingIndex = _cartList.indexWhere(
  //                 (existingItem) => existingItem.id == freshCartItem.id);
  //
  //         if (existingIndex == -1) {
  //           // إذا لم يكن العنصر موجودًا بالفعل، أضفه
  //           _cartList.add(freshCartItem);
  //           print('_cartList ${_cartList}');
  //
  //         } else {
  //           // إذا كان العنصر موجودًا بالفعل، تحديث الكمية فقط إذا أردت ذلك
  //           _cartList[existingIndex].quantity =
  //               freshCartItem.quantity; // أو استخدم += لزيادة الكمية
  //         }
  //
  //       }
  //     }
  //
  //     calculationCart();
  //     _onlineCartList.clear();  // تفريغ القائمة بعد تحويلها إلى freshCartList
  //     freshCartList.clear();    // تفريغ القائمة بعد إضافتها إلى _cartList
  //     // _cartList.clear();    // تفريغ القائمة بعد إضافتها إلى _cartList
  //     success = true;
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //
  //   _isLoading = false;
  //   update();
  //
  //   return success;
  // }
  // Future<bool> addToCartOnline(OnlineCart cart) async {
  //   bool success = false;
  //   _isLoading = true;
  //   update();
  //
  //   // تفريغ قائمة freshCartList و _onlineCartList قبل إضافة عناصر جديدة
  //   freshCartList.clear();
  //   _onlineCartList.clear();
  //
  //   Response response = await cartRepo.addToCartOnline(cart);
  //
  //   if (response.statusCode == 200) {
  //     print('freshCartList ${freshCartList}');
  //     _onlineCartList = [];
  //     freshCartList = [];
  //     response.body.forEach((cartJson) => _onlineCartList.add(OnlineCartModel.fromJson(cartJson)));
  //
  //     // تحديث قائمة freshCartList من جديد بالعناصر الجديدة فقط
  //     freshCartList = CartHelper.formatOnlineCartToLocalCart(onlineCartModel: _onlineCartList);
  //
  //     print(' response.body ${ response.body}');
  //     print('_onlineCartList ${_onlineCartList}');
  //     print('_cartList ${_cartList}');
  //
  //     if ( freshCartList.isNotEmpty) {
  //       for (var freshCartItem in freshCartList) {
  //         int existingIndex = _cartList.indexWhere(
  //                 (existingItem) => existingItem.id == freshCartItem.id);
  //
  //         if (existingIndex == -1) {
  //           // إذا لم يكن العنصر موجودًا بالفعل، أضفه
  //           _cartList.add(freshCartItem);
  //           print('_cartList ${_cartList}');
  //         } else {
  //           // إذا كان العنصر موجودًا بالفعل، تحديث الكمية فقط إذا أردت ذلك
  //           _cartList[existingIndex].quantity = freshCartItem.quantity;
  //         }
  //       }
  //     }
  //
  //     calculationCart();
  //     success = true;
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //
  //   _isLoading = false;
  //   update();
  //
  //   return success;
  // }
  // Future<bool> addToCartOnline(OnlineCart cart, {bool hasPaid = false}) async {
  //   bool success = false;
  //   _isLoading = true;
  //   update();
  //
  //   // Clear lists only if not paid yet
  //   if (!Get.find<OrderController>().hasPaid) {
  //     freshCartList.clear();
  //     _onlineCartList.clear();
  //   }
  //
  //   Response response = await cartRepo.addToCartOnline(cart);
  //
  //   if (response.statusCode == 200) {
  //     _onlineCartList = [];
  //     response.body.forEach((cartJson) => _onlineCartList.add(OnlineCartModel.fromJson(cartJson)));
  //
  //     // Updating freshCartList with new items only
  //     freshCartList = CartHelper.formatOnlineCartToLocalCart(onlineCartModel: _onlineCartList);
  //
  //     if (!hasPaid && freshCartList.isNotEmpty) {
  //       for (var freshCartItem in freshCartList) {
  //         int existingIndex = _cartList.indexWhere((existingItem) => existingItem.id == freshCartItem.id);
  //
  //         if (existingIndex == -1) {
  //           _cartList.add(freshCartItem);
  //           print('_cartList ${_cartList}');
  //         } else {
  //           _cartList[existingIndex].quantity = freshCartItem.quantity;
  //         }
  //       }
  //     }
  //
  //     calculationCart();
  //     success = true;
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //
  //   _isLoading = false;
  //   update();
  //
  //   return success;
  // }
  Future<bool> addToCartOnline(OnlineCart cart) async {
    _isLoading = true;
    bool success = false;
    update();
    Response response = await cartRepo.addToCartOnline(cart);
    if(response.statusCode == 200) {
      _onlineCartList = [];
      _cartList = [];
      response.body.forEach((cart) => _onlineCartList.add(OnlineCartModel.fromJson(cart)));
      _cartList.addAll(CartHelper.formatOnlineCartToLocalCart(onlineCartModel: _onlineCartList));
      print(_cartList);
      calculationCart();
      success = true;
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();

    return success;
  }


  Future<bool> updateCartOnline(OnlineCart cart) async {
    _isLoading = true;
    bool success = false;
    update();
    Response response = await cartRepo.updateCartOnline(cart);

    if (response.statusCode == 200) {
      List<OnlineCartModel> updatedCartList = [];
      for (var cartJson in response.body) {
        updatedCartList.add(OnlineCartModel.fromJson(cartJson));
      }

      // تحديث العناصر الموجودة فقط بدلاً من إعادة كتابة القائمة
      for (var updatedCart in updatedCartList) {
        int index = _onlineCartList
            .indexWhere((element) => element.id == updatedCart.id);
        if (index != -1) {
          _onlineCartList[index] = updatedCart; // تحديث العنصر الموجود
        } else {
          _onlineCartList.add(updatedCart); // إضافة عنصر جديد إذا لم يكن موجود
        }
      }

      // تحديث القائمة المحلية
      List<CartModel> updatedLocalCartList =
          CartHelper.formatOnlineCartToLocalCart(
              onlineCartModel: _onlineCartList);
      _cartList.clear();
      _cartList.addAll(updatedLocalCartList);

      // إعادة حساب تكاليف العربة
      calculationCart();
      success = true;
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();

    return success;
  }

  void addItem() {
    if (_onlineCartList.isNotEmpty) {


      for (var freshCartItem in freshCartList) {
        int existingIndex = _cartList.indexWhere(
                (existingItem) => existingItem.id == freshCartItem.id);

        if (existingIndex == -1) {
          // إذا لم يكن العنصر موجودًا بالفعل، أضفه
          _cartList.add(freshCartItem);
          print('_cartList ${_cartList}');

        } else {
          // إذا كان العنصر موجودًا بالفعل، تحديث الكمية فقط إذا أردت ذلك
          _cartList[existingIndex].quantity =
              freshCartItem.quantity; // أو استخدم += لزيادة الكمية
        }

      }
    }
  }

  Future<void> updateCartQuantityOnline(
      int cartId, double price, int quantity) async {
    _isLoading = true;
    update();
    Response response =
        await cartRepo.updateCartQuantityOnline(cartId, price, quantity);
    if (response.statusCode == 200) {
      getCartDataOnline();
      calculationCart();
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> getCartDataOnline() async {
    if (Get.find<SplashController>().module != null ||
        Get.find<SplashController>().cacheModule != null) {
      _isLoading = true;
      Response response = await cartRepo.getCartDataOnline();
      if (response.statusCode == 200) {
        _onlineCartList = [];
        _cartList = [];
        response.body.forEach(
            (cart) => _onlineCartList.add(OnlineCartModel.fromJson(cart)));
        print('---------cart data call------');

        print('response.body ${response.body}');

        _cartList.addAll(CartHelper.formatOnlineCartToLocalCart(
            onlineCartModel: _onlineCartList));
        print('_onlineCartList-------vvvvv->>>> $_onlineCartList');
        print('_cartList-------vvvvv->>>> $_cartList');
        calculationCart();
      } else {
        ApiChecker.checkApi(response);
      }
      _isLoading = false;
      update();
    }
  }

  Future<bool> removeCartItemOnline(int cartId, {Item? item}) async {
    _isLoading = true;
    bool isSuccess = false;
    update();
    Response response = await cartRepo.removeCartItemOnline(
        cartId,
        Get.find<AuthController>().isLoggedIn()
            ? null
            : Get.find<AuthController>().getGuestId());
    if (response.statusCode == 200) {
      isSuccess = true;
      _cartList.removeWhere((item) => item.id == cartId);
      calculationCart();
      update();
      if (item != null) {
        Get.find<ItemController>().setExistInCart(item, notify: true);
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    return isSuccess;
  }

  Future<bool> clearCartOnline() async {
    _isLoading = true;
    bool isSuccess = false;
    update();
    Response response = await cartRepo.clearCartOnline();
    if (response.statusCode == 200) {
      isSuccess = true;
      _cartList.clear();
      _onlineCartList.clear();
      freshCartList.clear();

      update();
      getCartDataOnline();
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
    return isSuccess;
  }

  clearCard(){
    // _cartList = [];
    // // freshCartList = [];
    // // _onlineCartList = [];
    freshCartList.clear();
    _cartList.clear();
    _onlineCartList.clear();
    update();
  }

  int cartQuantity(int itemId) {
    int quantity = 0;
    for (CartModel cart in _cartList) {
      if (cart.item!.id == itemId) {
        quantity += cart.quantity!;
      }
    }
    return quantity;
  }

  String cartVariant(int itemId) {
    String variant = '';
    for (CartModel cart in _cartList) {
      if (cart.item!.id == itemId) {
        if (!Get.find<SplashController>()
            .getModuleConfig(cart.item!.moduleType)!
            .newVariation!) {
          variant = (cart.variation != null && cart.variation!.isNotEmpty)
              ? cart.variation![0].type!
              : '';
        }
      }
    }
    return variant;
  }

  void updateAdd() {
    isAdd = !isAdd;
    update();
  }
}
