import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/add_favourite_view.dart';
import 'package:sixam_mart/view/base/cart_count_view.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/discount_tag.dart';
import 'package:sixam_mart/view/base/hover/on_hover.dart';
import 'package:sixam_mart/view/base/organic_tag.dart';

class ReviewItemCard extends StatelessWidget {
  final bool isFeatured;
  final Item? item;
  const ReviewItemCard({Key? key, this.isFeatured = false, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.grocery;
    bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.grocery;

    return OnHover(
      isItem: true,
      child: isShop ? Container(
        width: 180,height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          border: Border(
            bottom: BorderSide(color: Colors.black.withOpacity(.2)),
            top: BorderSide(color: Colors.black.withOpacity(.2)),
            right: BorderSide(color: Colors.black.withOpacity(.2)),
            left: BorderSide(color: Colors.black.withOpacity(.2)),
          ),

          // boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
        ),
        child: InkWell(
          hoverColor: Colors.transparent,
          onTap: () => Get.find<ItemController>().navigateToItemPage(item, context),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Expanded(
              flex: 5,
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                    child: CustomImage(
                      placeholder: Images.placeholder,
                      image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                          '/${item!.image}',
                      fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                    ),
                  ),
                ),

                // AddFavouriteView(
                //   item: item!,
                // ),

                DiscountTag(
                  isFloating: true,
                  discount: Get.find<ItemController>().getDiscount(item!),
                  discountType: Get.find<ItemController>().getDiscountType(item!),
                ),
              ],
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: isFeatured ? CrossAxisAlignment.start : CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    item!.storeName!, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                  ),

                  Text(item!.name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold),
                  // const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(mainAxisAlignment: isFeatured ? MainAxisAlignment.start : MainAxisAlignment.center, children: [
                    // Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
                    // const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    // Text(item!.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    // const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    // Text("(${item!.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                  ]),

                  item!.discount != null && item!.discount! > 0  ? Text(
                    PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item!)),
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ) : const SizedBox(),
                  // SizedBox(height: item!.discount != null && item!.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                  Text(
                    PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item!), discount: item!.discount,
                        discountType: item!.discountType),
                    style: robotoMedium, textDirection: TextDirection.ltr,
                  ),
                ],
                ),
              ),
            ),
          ]),
        ),
      ) : Container(
        width: 210,height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          border: Border(
            bottom: BorderSide(color: Colors.black.withOpacity(.2)),
            top: BorderSide(color: Colors.black.withOpacity(.2)),
            right: BorderSide(color: Colors.black.withOpacity(.2)),
            left: BorderSide(color: Colors.black.withOpacity(.2)),
          ),

          // boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Stack(children: [

            Padding(
              padding: EdgeInsets.only( top:  Dimensions.paddingSizeSmall ,left:  Dimensions.paddingSizeExtremeLarge , right: Dimensions.paddingSizeExtremeLarge,bottom: 70),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(1)),
                child: CustomImage(
                  placeholder: Images.placeholder,
                  image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                      '/${item!.image}',
                  fit: BoxFit.cover, width: double.infinity,
                ),
              ),
            ),
            DiscountTag(
              isFloating: true,
              discount: Get.find<ItemController>().getDiscount(item!),
              discountType: Get.find<ItemController>().getDiscountType(item!),
            ),

            // AddFavouriteView(
            //   top: 10, right: 10,
            //   item: item!,
            // ),


            // OrganicTag(item: item!, placeInImage: false),

            Positioned(
              bottom: 8, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [

                    isFood ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text(
                        item!.storeName!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text(item!.name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold),

                      // Row(mainAxisAlignment: isFeatured ? MainAxisAlignment.start : MainAxisAlignment.center, children: [
                      //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
                      //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      //   Text(item!.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                      //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      //   Text("(${item!.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                      // ]),

                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        item!.discount! > 0  ? Text(
                          PriceConverter.convertPrice(
                            Get.find<ItemController>().getStartingPrice(item!),
                          ),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough,
                          ),
                        ) : const SizedBox(),
                        SizedBox(width: item!.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                        Text(
                          PriceConverter.convertPrice(
                            Get.find<ItemController>().getStartingPrice(item!),
                            discount: item!.discount,
                            discountType: item!.discountType,
                          ),
                          style: robotoMedium, textDirection: TextDirection.ltr,
                        ),
                      ]),
                    ],
                    ) : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      // const SizedBox(height: Dimensions.paddingSizeExtremeLarge,),

                      Text(item!.name!, style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      // Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      //   Icon(Icons.star, size: 15, color: Theme.of(context).primaryColor),
                      //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      //   Text(item!.avgRating!.toStringAsFixed(1), style: robotoRegular),
                      //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      //   Text("(${item!.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                      // ],
                      // ),

                      (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item!.unitType != null) ? Text(
                        '(${item!.unitType ?? ''})',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                      ) : const SizedBox(),

                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        item!.discount! > 0  ? Text(
                          PriceConverter.convertPrice(
                            Get.find<ItemController>().getStartingPrice(item!),
                          ),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough,
                          ),
                        ) : const SizedBox(),
                        // SizedBox(height: item!.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                        Text(
                          PriceConverter.convertPrice(
                            Get.find<ItemController>().getStartingPrice(item!),
                            discount: item!.discount,
                            discountType: item!.discountType,
                          ),
                          style: robotoMedium, textDirection: TextDirection.ltr,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      ]),
                    ],
                    ),


                    Positioned(
                      top: 65, left: 0, right: 0,
                      child: CartCountView(
                        item: item!,
                        child: Center(
                          child: Container(
                            alignment: Alignment.center,
                            width: 65, height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(112),
                              color: Theme.of(context).cardColor,
                              boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
                            ),
                            child: Text("add".tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeExtremeLarge,),

          ]),
          SizedBox(height: Dimensions.paddingSizeExtremeLarge,),

        ]),
      )  ,
    );
  }
}