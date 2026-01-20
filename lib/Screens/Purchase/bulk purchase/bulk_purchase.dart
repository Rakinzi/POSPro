import 'dart:io';
import 'package:excel/excel.dart' as e;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/Products/add_product.dart';
import 'package:mobile_pos/constant.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/add_to_cart_purchase.dart';
import '../Repo/purchase_repo.dart';

class BulkPurchaseUploader extends ConsumerStatefulWidget {
  const BulkPurchaseUploader({super.key});

  @override
  ConsumerState<BulkPurchaseUploader> createState() => _BulkPurchaseUploaderState();
}

class _BulkPurchaseUploaderState extends ConsumerState<BulkPurchaseUploader> {
  String? filePat;
  File? file;

  String getFileExtension(String fileName) {
    return fileName.split('/').last;
  }

  Future<void> createExcelFile() async {
    if (!await Permission.storage.request().isDenied) {
      EasyLoading.showError('Storage permission is required to create Excel file!');
      return;
    }
    EasyLoading.show();
    final List<e.CellValue> excelData = [
      e.TextCellValue('SL'),
      e.TextCellValue('Product Code*'),
      e.TextCellValue('Purchase Quantity*'),
      e.TextCellValue('Purchase Price'),
      e.TextCellValue('Profit Percent %'),
      e.TextCellValue('Sale Price'),
      e.TextCellValue('Wholesale Price'),
      e.TextCellValue('Dealer Price'),
      e.TextCellValue('Batch No'),
      e.TextCellValue('Mfg Date'),
      e.TextCellValue('Expire Date'),
    ];
    e.CellStyle cellStyle = e.CellStyle(
      bold: true,
      textWrapping: e.TextWrapping.WrapText,
      rotation: 0,
    );
    var excel = e.Excel.createExcel();
    var sheet = excel['Sheet1'];

    sheet.appendRow(excelData);

    for (int i = 0; i < excelData.length; i++) {
      var cell = sheet.cell(e.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = cellStyle;
    }
    const downloadsFolderPath = '/storage/emulated/0/Download/';
    Directory dir = Directory(downloadsFolderPath);
    final file = File('${dir.path}/${appsName}_bulk_purchase_upload.xlsx');
    if (await file.exists()) {
      EasyLoading.showSuccess('The Excel file has already been downloaded');
    } else {
      await file.writeAsBytes(excel.encode()!);

      EasyLoading.showSuccess('Downloaded successfully in download folder');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: const Text('Excel Uploader'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: file != null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Card(
                        child: ListTile(
                            leading: Container(
                                height: 40,
                                width: 40,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                                child: const Image(image: AssetImage('images/excel.png'))),
                            title: Text(
                              getFileExtension(file?.path ?? ''),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    file = null;
                                  });
                                },
                                child: const Text('Remove')))),
                  ),
                ),
                Visibility(
                  visible: file == null,
                  child: const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Image(
                        height: 100,
                        width: 100,
                        image: AssetImage('images/file-upload.png'),
                      )),
                ),
                ElevatedButton(
                  style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(kMainColor)),
                  onPressed: () async {
                    if (file == null) {
                      await pickAndUploadFile(ref: ref);
                    } else {
                      EasyLoading.show(status: 'Uploading...');
                      await uploadProducts(ref: ref, file: file!, context: context);
                      EasyLoading.dismiss();
                    }
                  },
                  child: Text(file == null ? 'Pick and Upload File' : 'Upload', style: const TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () async {
                    await createExcelFile();
                  },
                  child: const Text('Download Excel Format'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///

  Future<void> pickAndUploadFile({required WidgetRef ref}) async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Excel Files',
      extensions: ['xlsx'],
    );
    final XFile? fileResult = await openFile(acceptedTypeGroups: [typeGroup]);

    if (fileResult != null) {
      final File files = File(fileResult.path);
      setState(() {
        file = files;
      });
    } else {
      debugPrint("No file selected");
    }
  }

  Future<void> uploadProducts({
    required File file,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    try {
      final purchaseCart = ref.watch(cartNotifierPurchaseNew);
      e.Excel excel = e.Excel.decodeBytes(file.readAsBytesSync());
      var sheet = excel.sheets.keys.first;
      var table = excel.tables[sheet]!;
      for (var row in table.rows) {
        CartProductModelPurchase? data = await createProductModelFromExcelData(row: row, ref: ref);

        if (data != null) purchaseCart.addToCartRiverPod(cartItem: data, isVariation: data.productType == ProductType.variant.name);
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (!context.mounted) return;
        EasyLoading.showSuccess('Upload Done');
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 1;
        });
      });
    } catch (e) {
      EasyLoading.showError(e.toString());
      return;
    }
  }

  Future<CartProductModelPurchase?> createProductModelFromExcelData({required List<e.Data?> row, required WidgetRef ref}) async {
    Future<CartProductModelPurchase?> getProductFromDatabase({required WidgetRef ref, required String givenProductCode}) async {
      final products = ref.watch(productProvider);
      CartProductModelPurchase? cartProductModel;

      // Wait for the category data to load
      await products.when(
        data: (product) async {
          for (var element in product) {
            if (element.productCode?.toLowerCase().trim() == givenProductCode.toLowerCase().trim()) {
              cartProductModel = CartProductModelPurchase(
                productId: element.id ?? 0,
                vatRate: element.vat?.rate ?? 0,
                productName: element.productName ?? '',
                vatAmount: element.vatAmount ?? 0,
                vatType: element.vatType ?? '',
                productWholeSalePrice: 0,
                productDealerPrice: 0,
                productPurchasePrice: 0,
                productSalePrice: 0,
                productType: element.productType ?? 'single',
                quantities: 0,
                stock: 0,
                brandName: '',
                profitPercent: 0,
                mfgDate: '',
                expireDate: '',
                batchNumber: '',
              );
              return cartProductModel;
            }
          }
        },
        error: (error, stackTrace) {},
        loading: () {},
      );

      return cartProductModel;
    }

    CartProductModelPurchase? productModel;

    // Loop through the row data
    for (var element in row) {
      if (element?.rowIndex == 0) {
        // Skip header row
        return null;
      }

      switch (element?.columnIndex) {
        case 1: // Product code
          if (element?.value == null) return null;

          productModel = await getProductFromDatabase(ref: ref, givenProductCode: element?.value.toString() ?? '');
          break;
        case 2: // Product quantity
          if (element?.value == null) return null;
          productModel?.quantities = num.tryParse(element?.value.toString() ?? '0');
          break;
        case 3: // purchase price

          productModel?.productPurchasePrice = num.tryParse(element?.value.toString() ?? '') ?? 0;
          break;
        case 4: // profit percent

          productModel?.profitPercent = num.tryParse(element?.value.toString() ?? '') ?? 0;
          break;
        case 5: // sales price

          productModel?.productSalePrice = num.tryParse(element?.value.toString() ?? '') ?? 0;
          break;
        case 6: // wholesale price

          productModel?.productWholeSalePrice = num.tryParse(element?.value.toString() ?? '') ?? 0;
          break;
        case 7: //dealer price
          if (element?.value != null) {
            productModel?.productDealerPrice = num.tryParse(element?.value.toString() ?? '') ?? 0;
          }
          break;
        case 8: // Batch (optional)
          if (element?.value != null) {
            productModel?.batchNumber = element?.value.toString() ?? '';
          }
          break;
        case 9: // mgf date (optional)
          if (element?.value != null) {
            productModel?.mfgDate = element?.value.toString() ?? '';
          }
          break;
        case 10: // expire date (optional)
          if (element?.value != null) {
            productModel?.expireDate = element?.value.toString() ?? '';
          }
          break;
      }
    }

    // Return null if any of the required fields are missing
    if (productModel?.productName == null || productModel?.quantities == null) {
      return null;
    }

    return productModel;
  }
}
