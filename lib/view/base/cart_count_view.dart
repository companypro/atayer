import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import '../../controller/splash_controller.dart';
class CartCountView extends StatelessWidget {
  final Item item;
  final Widget? child;
  final int? index;
  const CartCountView({Key? key, required this.item, this.child,this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
      bool isFirstPress = true;

      return cartQty != 0 ? Center(
        child: Container(
          width: 160,

          // decoration: BoxDecoration(
          //   // color: Theme.of(context).primaryColor,
          //   borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          // ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              InkWell(
                onTap: cartController.isLoading ? null : () {
                  if (cartController.cartList[cartIndex].quantity! > 1) {
                    cartController.setQuantity(false, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].item!.quantityLimit);

                  }
                  else {
                    cartController.removeFromCart(cartIndex);
                  }

                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(.3),
                    shape: BoxShape.circle,
                    // border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.remove, size: 19, color: Colors.black,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: !cartController.isLoading ? Text(
                  cartQty.toString(),
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),
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
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.add, size: 19, color: Colors.white,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ) : InkWell
        (
        onTap: () {



          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: child ?? Container(
          height: 45,
          decoration: BoxDecoration(
            // shape: BoxShape.circle, color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).primaryColor,
            // boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
          ),
          child: Center(child: Text("add_to_cart".tr,style: robotoMedium.copyWith(
            color:  Colors.white,
            fontSize: Dimensions.fontSizeLarge,
          ),)),
        ),
      );
    });
  }
}
class CartCountViewHome extends StatelessWidget {
  final Item item;
  final Widget? child;
  final int? index;
  const CartCountViewHome({Key? key, required this.item, this.child,this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
      bool isFirstPress = true;

      return cartQty != 0 ? Center(
        child: Container(
          width: 160,

          // decoration: BoxDecoration(
          //   // color: Theme.of(context).primaryColor,
          //   borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          // ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              InkWell(
                onTap: cartController.isLoading ? null : () {
                  if (cartController.cartList[cartIndex].quantity! > 1) {
                    cartController.setQuantity(false, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].item!.quantityLimit);

                  }
                  else {
                    cartController.removeFromCart(cartIndex);
                  }

                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(.3),
                    shape: BoxShape.circle,
                    // border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.remove, size: 19, color: Colors.black,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: !cartController.isLoading ? Text(
                  cartQty.toString(),
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),
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
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.add, size: 19, color: Colors.white,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ) : InkWell
        (
        onTap: () {

          if (isFirstPress) {
            Get.find<SplashController>().switchModule(index!, false);
            isFirstPress = false;
          }

          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: child ?? Container(
          height: 45,
          decoration: BoxDecoration(
            // shape: BoxShape.circle, color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).primaryColor,
            // boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
          ),
          child: Center(child: Text("add_to_cart".tr,style: robotoMedium.copyWith(
            color:  Colors.white,
            fontSize: Dimensions.fontSizeLarge,
          ),)),
        ),
      );
    });
  }
}
