import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_text_field.dart';
import 'package:sixam_mart/view/base/image_picker_widget.dart';
class NoteAndPrescriptionSection extends StatelessWidget {
  final OrderController orderController;
  final int? storeId;
  const NoteAndPrescriptionSection({Key? key, required this.orderController, this.storeId, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('additional_note'.tr, style: robotoBold),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        CustomTextField(
          controller: orderController.noteController,
          titleText: 'please_provide_extra_napkin'.tr,
          maxLines: 3,
          showBorder: false,
          contentPadding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault,horizontal: Dimensions.paddingSizeDefault),
          colorFill: Colors.grey.withOpacity(.2),
          inputType: TextInputType.multiline,
          inputAction: TextInputAction.done,
          capitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        storeId == null && Get.find<SplashController>().configModel!.moduleConfig!.module!.orderAttachment! ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('prescription'.tr, style: robotoMedium),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                '(${'max_size_2_mb'.tr})',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            ImagePickerWidget(
              image: '', rawFile: orderController.rawAttachment,
              onTap: () => orderController.pickImage(),
            ),
          ],
        ) : const SizedBox(),
      ]),
    );
  }
}
