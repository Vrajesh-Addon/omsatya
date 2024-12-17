import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'inherited_model.dart';
import 'shared_value.dart';

class StateManagerWidget extends StatefulWidget {
  final Widget child;
  final StateManagerWidgetState state;
  final Map<SharedValue, double> stateNonceMap;

  const StateManagerWidget(
      this.child,
      this.state,
      this.stateNonceMap,
      {super.key,});

  @override
  StateManagerWidgetState createState() => state;
}

class StateManagerWidgetState extends State<StateManagerWidget> {
  Future<void> rebuild() async {
    if (!mounted) return;

    // if there's a current frame,
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      // wait for the end of that frame.
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SharedValueInheritedModel(
      stateNonceMap: Map.of(widget.stateNonceMap),
      child: widget.child,
    );
  }
}