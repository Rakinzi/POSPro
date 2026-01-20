class AmountRoundingDropdownModel {
  late String value;
  late String option;

  AmountRoundingDropdownModel({required this.value, required this.option});
}

final List<AmountRoundingDropdownModel> roundingMethods = [
  AmountRoundingDropdownModel(value: 'none', option: 'None'),
  AmountRoundingDropdownModel(value: 'round_up', option: 'Round to whole number'),
  AmountRoundingDropdownModel(value: 'nearest_whole_number', option: 'Round to nearest whole number'),
  AmountRoundingDropdownModel(value: 'nearest_0.05', option: 'Round to nearest decimal (0.05)'),
  AmountRoundingDropdownModel(value: 'nearest_0.1', option: 'Round to nearest decimal (0.1)'),
  AmountRoundingDropdownModel(value: 'nearest_0.5', option: 'Round to nearest decimal (0.5)'),
];

num roundNumber({required num value, required String roundingType}) {
  switch (roundingType) {
    case "none":
      return value;

    case "round_up":
      return value.ceilToDouble();

    case "nearest_whole_number":
      return value.roundToDouble();

    case "nearest_0.05":
      return (value / 0.05).round() * 0.05;

    case "nearest_0.1":
      return (value / 0.1).round() * 0.1;

    case "nearest_0.5":
      return (value / 0.5).round() * 0.5;

    default:
      return value;
  }
}
