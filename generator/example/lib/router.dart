import 'package:example/page/home_page.dart';
import 'package:flutter/widgets.dart';
import 'package:example/list_page.dart';
import 'package:example/detail_page.dart';

Map<String, Widget Function(BuildContext context)> router = {
'/home': (ctx) {
    final args =
        ModalRoute.of(ctx).settings.arguments as Map<String, dynamic> ?? {};
    return HomePage();
  },
'/list': (ctx) {
    final args =
        ModalRoute.of(ctx).settings.arguments as Map<String, dynamic> ?? {};
    return ListPage();
  },
'/detail': (ctx) {
    final args =
        ModalRoute.of(ctx).settings.arguments as Map<String, dynamic> ?? {};
    assert(args['id'] != null);
    return DetailPage(args['id']);
  },
};