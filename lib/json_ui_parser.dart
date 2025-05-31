import 'package:dynamic_ui/ui_config.dart';
import 'package:flutter/material.dart';
import 'package:rfw/rfw.dart'; 
import '../widget_factory.dart';

class JsonUiParser {
  static Widget parse(UIConfig config) {
    final runtime = WidgetFactory.buildRuntime(config.dsl);
    final data = DynamicContent();

    return RemoteWidget(
      runtime: runtime,
      data: data,
      widget: const FullyQualifiedWidgetName(
        LibraryName(<String>['remote']),
        'root',
      ),
      onEvent: (name, args) {
        debugPrint('Event: $name | Args: $args');
      },
    );
  }
}
