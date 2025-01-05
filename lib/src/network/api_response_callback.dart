
import '../model/widget_response/widget.dart';

abstract class ApiResponseCallbacks {
  void onWidgetSuccess(WidgetResponse ? widget, bool isSurveyInitialize);

  void onSessionUpdateSuccess(List<String> idList);

  void onContactCreationSuccess(bool isContactCreated);
}
