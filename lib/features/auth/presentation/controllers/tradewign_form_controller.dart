import 'package:get/get.dart';

class TradeWingFormController extends GetxController {
  static final TradeWingFormController controller =
      Get.find<TradeWingFormController>();

  bool selectTradeWingValue = true;
  bool selectSubTradeWingValue = false;
  bool isSubTradeWing = false;

  onChange() {
    selectTradeWingValue = !selectTradeWingValue;
    selectSubTradeWingValue = !selectSubTradeWingValue;
    update();
  }
}
