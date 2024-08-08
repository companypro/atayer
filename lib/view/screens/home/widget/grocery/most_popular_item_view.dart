import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/view/base/title_widget.dart';
import 'package:sixam_mart/view/base/card_design/item_card.dart';
import 'package:sixam_mart/view/screens/home/widget/grocery/special_offer_view.dart';

import '../../../../../data/model/response/config_model.dart';
import '../../../../../data/model/response/item_model.dart';

class MostPopularItemView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  final List<Item> product;
  const MostPopularItemView({Key? key, required this.isFood, required this.isShop, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.grocery;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: GetBuilder<ItemController>(builder: (itemController) {
        // List<Item>? itemList = itemController.popularItemList;

          return (product != null) ? product.isNotEmpty ? Container(
            // color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(children: [


              SizedBox(
                height:320, width: Get.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                  itemCount: product.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeExtraSmall),
                      child: ItemCard(
                        isPopularItem: isShop ? false : true,
                        isPopularItemCart: true,
                        item: product[index],
                        isShop: isShop,
                        isFood: isFood, index: index,
                      ),
                    );
                  },
                ),
              ),

            ]),
          ) : const SizedBox() : const ItemShimmerView(isPopularItem: true);
        }
      ),
    );
  }
}
