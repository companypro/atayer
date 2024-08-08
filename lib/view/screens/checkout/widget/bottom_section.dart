import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/coupon_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/parcel_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/screens/checkout/widget/condition_check_box.dart';
import 'package:sixam_mart/view/screens/checkout/widget/coupon_section.dart';
import 'package:sixam_mart/view/screens/checkout/widget/note_prescription_section.dart';
import 'package:sixam_mart/view/screens/checkout/widget/partial_pay_view.dart';
import 'package:sixam_mart/view/screens/checkout/widget/payment_button_new.dart';
import 'package:sixam_mart/view/screens/checkout/widget/payment_method_bottom_sheet.dart';

import '../../../../data/model/response/order_model.dart';
import '../../../../util/images.dart';
import '../../../base/custom_snackbar.dart';

class BottomSection extends StatefulWidget {
  final OrderController orderController;
  final double total;
  final Module module;
  final double subTotal;
  final double discount;
  final CouponController couponController;
  final bool taxIncluded;
  final double tax;
  final double deliveryCharge;
  final StoreController storeController;
  final LocationController locationController;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? maxCodOrderAmount;
  final int? storeId;
  final double? taxPercent;
  final  double price;
  final double addOns;
  final Widget? checkoutButton;
  final UserController userController;
  const BottomSection({Key? key, required this.orderController, required this.total, required this.module, required this.subTotal, required this.discount, required this.couponController, required this.taxIncluded, required this.tax, required this.deliveryCharge, required this.storeController, required this.locationController, required this.todayClosed, required this.tomorrowClosed, required this.orderAmount, this.maxCodOrderAmount, this.storeId, this.taxPercent, required this.price, required this.addOns, this.checkoutButton, required this.userController}) : super(key: key);

  @override
  State<BottomSection> createState() => _BottomSectionState();
}

class _BottomSectionState extends State<BottomSection> {
  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    bool takeAway = widget.orderController.orderType == 'take_away';
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool notHideCod = true;
    bool canSelectWallet = true;
    bool notHideWallet = true;
    bool notHideDigital = true;
    OrderModel? order = widget.orderController.trackModel;

    bool status = false;

    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Column(children: [

        isDesktop ? pricingView(context: context, takeAway: takeAway) : const SizedBox(),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        /// Coupon
        CouponSection(
          storeId: widget.storeId, orderController: widget.orderController, total: widget.total, price: widget.price,
          discount: widget.discount, addOns: widget.addOns, deliveryCharge: widget.deliveryCharge,
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          ///Additional Note & prescription..
          NoteAndPrescriptionSection(orderController: widget.orderController, storeId: widget.storeId),
          const Divider(thickness: 3, height: 5),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            child: Column(children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text('payment_method'.tr,style: robotoRegular,),
                    SizedBox(height: Dimensions.paddingSizeSmall,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('${'Use_a_wallet'.tr}${PriceConverter.convertPrice(widget.userController.userInfoModel!.walletBalance)}',style: robotoRegular.copyWith(fontSize: 13,color: Theme.of(context).disabledColor),),
                    ),
                      //userController
                  ],),
                  const Spacer(),

                  // status != null ? Transform.scale(
                  //   scale: 0.7,
                  //   child: CupertinoSwitch(
                  //     value: status,
                  //     activeColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  //     onChanged: (bool? value) => setState(() {
                  //       status == value!;
                  //       print(value);
                  //     }),
                  //     // trackColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  //   ),
                  // ) : const SizedBox()

                ],),
               const SizedBox(height:  Dimensions.paddingSizeSmall,),

               notHideCod ? PaymentButtonNew(
                 icon: Images.codIcon,
                 title: 'cash_on_delivery'.tr,
                 isSelected: widget.orderController.paymentMethodIndex == 0,
                 onTap: () {
                   widget.orderController.setPaymentMethod(0);
                 },
               ) : const SizedBox(),
              SizedBox(height: widget.storeId == null &&  notHideWallet && isLoggedIn ? Dimensions.paddingSizeSmall : 0),

              widget.storeId == null &&  notHideWallet && isLoggedIn ? PaymentButtonNew(
                icon: Images.partialWallet,
                title: 'pay_via_wallet'.tr,
                isSelected: widget.orderController.paymentMethodIndex == 1,
                onTap: () {
                  if(canSelectWallet) {
                    widget.orderController.setPaymentMethod(1);
                  } else if(widget.orderController.isPartialPay){
                    showCustomSnackBar('you_can_not_user_wallet_in_partial_payment'.tr);
                    Get.back();
                  } else{
                    showCustomSnackBar('your_wallet_have_not_sufficient_balance'.tr);
                    Get.back();
                  }
                },
              ) : const SizedBox(),

            ]),
          ),


          isDesktop && !isGuestLoggedIn ? PartialPayView(totalPrice: widget.total, isPrescription: widget.storeId != null) : const SizedBox(),
          const Divider(thickness: 3, height: 5),

          !isDesktop ? pricingView(context: context, takeAway: takeAway) : const SizedBox(),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // CheckoutCondition(orderController: widget.orderController, parcelController: Get.find<ParcelController>()),

          const SizedBox(height: Dimensions.paddingSizeLarge),
          ResponsiveHelper.isDesktop(context) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text( 'total_amount'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),

                    widget.storeId == null ? const SizedBox()
                        : Text(
                        'Once_your_order_is_confirmed_you_will_receive'.tr,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeOverSmall, color: Theme.of(context).disabledColor,
                        ),
                    ),
                  ],
                ),
                const SizedBox(height:  Dimensions.paddingSizeSmall,),

                widget.storeId == null ? const SizedBox()
                    : Text(
                  'a_notification_with_your_bill_total'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeOverSmall, color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
            PriceConverter.convertAnimationPrice(
              widget.orderController.viewTotalPrice,
              textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: widget.orderController.isPartialPay ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
            ),
            // Text(
            //   PriceConverter.convertPrice(orderController.viewTotalPrice), textDirection: TextDirection.ltr,
            //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
            // ),
          ]) : const SizedBox(),
        ]),

        ResponsiveHelper.isDesktop(context) ? Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
          child: widget.checkoutButton,
        ) : const SizedBox(),

      ]),
    );
  }

  Widget pricingView({required BuildContext context, required bool takeAway}) {
    return Column(children: [

      ResponsiveHelper.isDesktop(context) ? Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: Text('order_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        ),
      ) : const SizedBox(),

      Column(
        children: [




          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            child: Column(
              children: [
                widget.storeId == null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text( 'total_shipment'.tr , style: robotoBold.copyWith(fontSize: 16)),
                  Text('', style: robotoMedium, textDirection: TextDirection.ltr),
                ]) : const SizedBox(),
                SizedBox(height:  Dimensions.paddingSizeDefault,),

                widget.storeId == null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text( 'subtotal'.tr , style: robotoMedium),
                  Text(PriceConverter.convertPrice(widget.subTotal), style: robotoMedium, textDirection: TextDirection.ltr),
                ]) : const SizedBox(),
                // SizedBox(height: widget.storeId == null ? Dimensions.paddingSizeSmall : 0),

                // widget.storeId == null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                //   Text('discount'.tr, style: robotoRegular),
                //   Text('(-) ${PriceConverter.convertPrice(widget.discount)}', style: robotoRegular, textDirection: TextDirection.ltr),
                // ]) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                (widget.couponController.discount! > 0 || widget.couponController.freeDelivery) ? Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('coupon_discount'.tr, style: robotoRegular),
                    (widget.couponController.coupon != null && widget.couponController.coupon!.couponType == 'free_delivery') ? Text(
                      'free_delivery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                    ) : Text(
                      '(-) ${PriceConverter.convertPrice(widget.couponController.discount)}',
                      style: robotoRegular, textDirection: TextDirection.ltr,
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ]) : const SizedBox(),
                SizedBox(height: 7,),
                widget.storeId == null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${'delivery_fee'.tr} ', style: robotoRegular),
                  Text(  PriceConverter.convertPrice(widget.deliveryCharge), style: robotoRegular, textDirection: TextDirection.ltr),
                ]) : const SizedBox(),

                // SizedBox(height: widget.storeId == null ? Dimensions.paddingSizeSmall : 0),

                (!takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('delivery_man_tips'.tr, style: robotoRegular),
                    Text(' ${PriceConverter.convertPrice(widget.orderController.tips)}', style: robotoRegular, textDirection: TextDirection.ltr),
                  ],
                ) : const SizedBox.shrink(),

                SizedBox(height: !takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),
              ],
            ),
          ),

          const Divider(thickness: 1, height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    'total_amount'.tr,
                    style: robotoMedium,
                  ),
                  PriceConverter.convertAnimationPrice(
                    widget.subTotal + widget.deliveryCharge,
                    textStyle: robotoMedium,
                  ),
                  // Text(
                  //   PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
                  //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                  // ),
                ]),
                // (Get.find<AuthController>().isGuestLoggedIn() && widget.orderController.guestAddress == null)
                // ? const SizedBox() : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                //   Text('delivery_fee'.tr, style: robotoRegular),
                //   widget.orderController.distance == -1 ? Text(
                //     'calculating'.tr, style: robotoRegular.copyWith(color: Colors.red),
                //   ) : (widget.deliveryCharge == 0 || (widget.couponController.coupon != null && widget.couponController.coupon!.couponType == 'free_delivery')) ? Text(
                //     'free'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                //   ) : Text(
                //     '(+) ${PriceConverter.convertPrice(widget.deliveryCharge)}', style: robotoRegular, textDirection: TextDirection.ltr,
                //   ),
                // ]),

                SizedBox(height: Get.find<SplashController>().configModel!.additionalChargeStatus! && !(Get.find<AuthController>().isGuestLoggedIn() && widget.orderController.guestAddress == null) ? Dimensions.paddingSizeSmall : 0),

                Get.find<SplashController>().configModel!.additionalChargeStatus! ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(Get.find<SplashController>().configModel!.additionalChargeName!, style: robotoRegular),
                  Text(
                    '(+) ${PriceConverter.convertPrice(Get.find<SplashController>().configModel!.additionCharge)}',
                    style: robotoRegular, textDirection: TextDirection.ltr,
                  ),
                ]) : const SizedBox(),
                SizedBox(height: widget.orderController.isPartialPay ? Dimensions.paddingSizeSmall : 0),

                widget.orderController.isPartialPay ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('paid_by_wallet'.tr, style: robotoRegular),
                  Text('(-) ${PriceConverter.convertPrice(Get.find<UserController>().userInfoModel!.walletBalance!)}', style: robotoRegular, textDirection: TextDirection.ltr),
                ]) : const SizedBox(),
                SizedBox(height: widget.orderController.isPartialPay ? Dimensions.paddingSizeSmall : 0),

                widget.orderController.isPartialPay ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    'due_payment'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
                  ),
                  PriceConverter.convertAnimationPrice(
                    widget.orderController.viewTotalPrice,
                    textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
                  )
                ]) : const SizedBox(),

              ],
            ),
          ),
          Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5))
        ],
      ),

    ]);
  }
}
