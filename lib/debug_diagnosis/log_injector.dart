import 'flow_trace.dart';

mixin LogInjector {
  void trace(String tag, String message, [dynamic data]) {
    FlowTrace.log(tag, message, data);
  }
}