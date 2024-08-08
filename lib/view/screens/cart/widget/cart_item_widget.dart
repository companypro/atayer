import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/cart_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/item_bottom_sheet.dart';
import 'package:sixam_mart/view/base/quantity_button.dart';
import 'package:sixam_mart/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../util/images.dart';

class CartItemWidget extends StatelessWidget {
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;
  const CartItemWidget({Key? key, required this.cart, required this.cartIndex, required this.isAvailable, required this.addOns}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double? startingPrice = CartHelper.calculatePriceWithVariation(item: cart.item);
    double? endingPrice = CartHelper.calculatePriceWithVariation(item: cart.item, isStartingPrice: false);
    String? variationText = CartHelper.setupVariationText(cart: cart);
    String addOnText = CartHelper.setupAddonsText(cart: cart) ?? '';

    double? discount = cart.item!.storeDiscount == 0 ? cart.item!.discount : cart.item!.storeDiscount;
    String? discountType = cart.item!.storeDiscount == 0 ? cart.item!.discountType : 'percent';

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: InkWell(
        onTap: () {
          ResponsiveHelper.isMobile(context) ? showModalBottomSheet
            (
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (con) => ItemBottomSheet(item: cart.item, cartIndex: cartIndex, cart: cart),
          ) : showDialog(context: context, builder: (con) => Dialog(
            child: ItemBottomSheet(item: cart.item, cartIndex: cartIndex, cart: cart),
          ));
        },
        child: Slidable(
          key: UniqueKey(),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.2,
            children: [
              SlidableAction(
                onPressed: (context) {
                  Get.find<CartController>().removeFromCart(cartIndex, item: cart.item);
                },
                backgroundColor: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.horizontal(right: Radius.circular(Get.find<LocalizationController>().isLtr ? Dimensions.radiusDefault : 0), left: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : Dimensions.radiusDefault)),
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: const BorderDirectional(
                end: BorderSide(
                  color: Colors.grey
                ),
                top: BorderSide(
                    color: Colors.grey
                ),
                start: BorderSide(
                    color: Colors.grey
                ),
                bottom: BorderSide(
                    color: Colors.grey
                ),
              )

            ),
            child: Stack(
              alignment: Get.find<LocalizationController>().isLtr ? Alignment.topRight : Alignment.topLeft,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImage(
                              image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}/${cart.item!.image}',
                              height: ResponsiveHelper.isDesktop(context) ? 90 : 90, width: ResponsiveHelper.isDesktop(context) ? 90 : 90, fit: BoxFit.cover,
                            ),
                          ),
                          isAvailable ? const SizedBox() : Positioned(
                            top: 0, left: 0, bottom: 0, right: 0,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.black.withOpacity(0.6)),
                              child: Text('not_available_now_break'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                                color: Colors.white, fontSize: 8,
                              )),
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                cart.item!.name!,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // const SizedBox(width: Dimensions.paddingSizeExtraSmall),


                          ],
                        ),

                        const SizedBox(height:  Dimensions.paddingSizeExtraLarge),
                        GetBuilder<CartController>(
                            builder: (cartController) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        QuantityButton(
                                          onTap: cartController.isLoading ? null : () {
                                            if (cart.quantity! > 1) {
                                              Get.find<CartController>().setQuantity(false, cartIndex, cart.stock, cart.quantityLimit);
                                            }else {
                                              Get.find<CartController>().removeFromCart(cartIndex, item: cart.item);
                                            }
                                          },
                                          isIncrement: false,
                                          showRemoveIcon: cart.quantity! == 1,

                                        ),
                                        const SizedBox(width: 7,),
                                        Text(
                                          cart.quantity.toString(),
                                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                                        ),
                                        const SizedBox(width: 7,),
                                        QuantityButton(
                                          onTap: cartController.isLoading ? null : () {
                                            // Get.find<CartController>().forcefullySetModule(Get.find<CartController>().cartList[0].item!.moduleId!);
                                            Get.find<CartController>().setQuantity(true, cartIndex, cart.stock, cart.quantityLimit);
                                          },
                                          isIncrement: true,
                                          color: cartController.isLoading ? Theme.of(context).disabledColor : null,
                                        ),
                                        // SizedBox(width: 50,),

                                      ]),
                                  SizedBox(width: 15,),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: Text(
                                      PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType),
                                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                    ),
                                  ),

                                ],
                              );
                            }
                        ),

                        Wrap(children: [
                          // SizedBox(width: discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                          discount! > 0 ? Text(
                            '${PriceConverter.convertPrice(startingPrice)}'
                                '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                            textDirection: TextDirection.ltr,
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough,
                              fontSize: Dimensions.fontSizeExtraSmall,
                            ),
                          ) : const SizedBox(),
                        ]),



                      ])


                    ]),

                    !ResponsiveHelper.isDesktop(context) ? (Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! && addOnText.isNotEmpty) ? Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        SizedBox(width: ResponsiveHelper.isDesktop(context) ? 100 : 80),
                        Text('${'addons'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        Flexible(child: Text(
                          addOnText,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        )),
                      ]),
                    ) : const SizedBox() : const SizedBox(),

                    !ResponsiveHelper.isDesktop(context) ? variationText!.isNotEmpty ? Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        SizedBox(width: ResponsiveHelper.isDesktop(context) ? 100 : 80),
                        Text(ResponsiveHelper.isDesktop(context) ? '' : '${'variations'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        Flexible(child: Text(
                          variationText,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        )),
                      ]),
                    ) : const SizedBox() : const SizedBox(),

                  ],
                ),
                Container(
                  child:     InkWell(onTap: (){
                    Get.find<CartController>().removeFromCart(cartIndex, item: cart.item);

                  },
                      child: Image.asset(Images.delete,width: 22,))
                  ,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
