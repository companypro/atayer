import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/base/footer_view.dart';

class NoDataScreen extends StatelessWidget {
  final bool isCart;
  final bool showFooter;
  final String? text;
  final bool fromAddress;
  const NoDataScreen({Key? key, required this.text, this.isCart = false, this.showFooter = false, this.fromAddress = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FooterView(
        visibility: showFooter,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [

            Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(50),
                color: Colors.grey.withOpacity(.2),
                shape: BoxShape.circle
              ),
              width: MediaQuery.of(context).size.height *0.17,
              height: MediaQuery.of(context).size.height*0.17,
              child: Center(
                child: SvgPicture.asset(
                  Images.cardEmpty,

                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.03),

            Text(
              isCart ? 'cart_is_empty'.tr : text!,
              style: robotoBold.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15,),
            Text(
              isCart ? 'not_added_any_items'.tr : text!,
              style: robotoMedium.copyWith(fontSize: MediaQuery.of(context).size.height*0.0175, color: fromAddress ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).disabledColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.03),

            fromAddress ? Text(
              'please_add_your_address_for_your_better_experience'.tr,
              style: robotoMedium.copyWith(fontSize: MediaQuery.of(context).size.height*0.0175, color: Theme.of(context).disabledColor),
              textAlign: TextAlign.center,
            ) : const SizedBox(),
            SizedBox(height: MediaQuery.of(context).size.height*0.05),

            fromAddress ? InkWell(
              onTap: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, false, 0)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).primaryColor,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline_sharp, size: 18.0, color: Theme.of(context).cardColor),
                    Text('add_address'.tr, style: robotoMedium.copyWith(color: Theme.of(context).cardColor)),
                  ],
                ),
              ),
            ) : const SizedBox(),

          ]),
        ),
      ),
    );
  }
}
