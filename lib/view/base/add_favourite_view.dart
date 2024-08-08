import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';

class AddFavouriteView extends StatelessWidget {
  final Item item;
  final double? top, right;
  final double? left;
  const AddFavouriteView({Key? key, required this.item, this.top = 15, this.right = 15, this.left}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, right: right, left: left,
      child: GetBuilder<WishListController>(builder: (wishController) {
        bool isWished = wishController.wishItemIdList.contains(item.id);
        return InkWell(
          onTap: () {
            if(Get.find<AuthController>().isLoggedIn()) {
              isWished ? wishController.removeFromWishList(item.id, false)
                  : wishController.addToWishList(item, null, false);
            }else {
              showCustomSnackBar('you_are_not_logged_in'.tr);
            }
          },
          child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1, color:  Theme.of(context).disabledColor.withOpacity(.5)
                ),
                color:  Theme.of(context).cardColor,
              ),

              child: Icon(isWished ? Icons.favorite : Icons.favorite_border, color: Theme.of(context).primaryColor, size: 20)),
        );
      }),
    );
  }
}
class AddFavouriteViewHome extends StatelessWidget {
  final ItemsHome item;
  final double? top, right;
  final double? left;
  const AddFavouriteViewHome({Key? key, required this.item, this.top = 15, this.right = 15, this.left}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, right: right, left: left,
      child: GetBuilder<WishListController>(builder: (wishController) {
        bool isWished = wishController.wishItemIdList.contains(item.id);
        return InkWell(
          onTap: () {
            if(Get.find<AuthController>().isLoggedIn()) {
              isWished ? wishController.removeFromWishList(item.id, false)
                  : wishController.addToWishListHome(item, null, false);
            }else {
              showCustomSnackBar('you_are_not_logged_in'.tr);
            }
          },
          child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1, color:  Theme.of(context).disabledColor.withOpacity(.5)
                ),
                color:  Theme.of(context).cardColor,
              ),

              child: Icon(isWished ? Icons.favorite : Icons.favorite_border, color: Theme.of(context).primaryColor, size: 20)),
        );
      }),
    );
  }
}
