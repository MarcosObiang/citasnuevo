import 'package:citasnuevo/reordableLists/sliver_grid_with_reorderable_pos_delegate.dart';
import 'package:flutter/widgets.dart';

import '../reordableList.dart';
import 'reorderable_wrapper_widget.dart';


// Can I be a stateful widget, because we need update the state. Ok, let's try this.
class ReorderableSliverGridView extends StatelessWidget {
  // can I hold the children? let's try.
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  final ReorderCallback onReorder;
  final DragWidgetBuilder? dragWidgetBuilder;
  final ScrollSpeedController? scrollSpeedController;

  const ReorderableSliverGridView({
    Key? key,
    this.children = const <Widget>[],
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.childAspectRatio,

    required this.onReorder,
    this.dragWidgetBuilder,
    this.scrollSpeedController,
  }): super(key: key);

  // can we do the logic?

  const ReorderableSliverGridView.count({
    Key? key,
    required int crossAxisCount,
    required ReorderCallback onReorder,

    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    children = const <Widget>[],
  }): this(
      key: key,
      onReorder: onReorder,
      children: children,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
  );

  // build the new child??
  @override
  Widget build(BuildContext context) {
    // we can't wrapper this?
    // why I need you?
    // fuck that inner has the ReorderableChildPosDelegate, but outter still have?
    // can child has two something?
    var child = SliverGridWithReorderablePosDelegate.count(key: key,
        children: ReorderableItemView.wrapMeList(children, []),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio);

    return ReorderableWrapperWidget(
      child: child,
      onReorder: onReorder,
      dragWidgetBuilder: dragWidgetBuilder,
      scrollSpeedController: scrollSpeedController,
    );

  }

}