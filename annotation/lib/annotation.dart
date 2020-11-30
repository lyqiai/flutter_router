library annotation;

class RouterConfig {
  final String path;

  const RouterConfig(this.path);
}

class Autowired {
  final bool isRequired;

  const Autowired({this.isRequired = false});
}