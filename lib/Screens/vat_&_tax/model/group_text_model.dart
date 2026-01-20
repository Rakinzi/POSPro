import 'package:mobile_pos/Screens/vat_&_tax/model/vat_model.dart';

class GroupTaxModel {
  late String name;
  late num taxRate;
  late String id;
  List<VatModel>? subTaxes;

  GroupTaxModel({
    required this.name,
    required this.taxRate,
    required this.id,
    required this.subTaxes,
  });

  GroupTaxModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    taxRate = json['rate'];
    id = json['id'];
    if (json['subTax'] != null) {
      subTaxes = <VatModel>[];
      json['subTax'].forEach((v) {
        subTaxes!.add(VatModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'rate': taxRate,
        'id': id,
        'subTax': subTaxes?.map((e) => e.toJson()).toList(),
      };
}
