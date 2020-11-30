import 'package:router/annotation.dart';
import 'package:flutter/widgets.dart';

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
