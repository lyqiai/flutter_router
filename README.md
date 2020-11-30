# flutter_router
A flutter package for gen navigator router config file

1.在页面的类上添加@RouterConfig(path)注解
2.需要传入参数的字段添加@Autowired(isRequired: bool)注解


@RouterConfig('/detail')
class DetailPage extends StatefulWidget{
  @Autowired(isRequired: true)
  int id;

  DetailPage(this.id);

  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }
}

输出
import 'package:example/page/home_page.dart';
import 'package:example/detail_page.dart';

Map<String, Widget Function(BuildContext context)> router = {
'/detail': (ctx) {
    final args =
        ModalRoute.of(ctx).settings.arguments as Map<String, dynamic> ?? {};
    assert(args['id'] != null);
    return DetailPage(args['id']);
  },
};

输出文件位于项目根目录下lib/router.dart
