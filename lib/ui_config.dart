class UIConfig {
  final String dsl;

  UIConfig(this.dsl);

  factory UIConfig.fromString(String dsl) => UIConfig(dsl);
}
