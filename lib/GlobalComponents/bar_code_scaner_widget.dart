import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onBarcodeFound;

  const BarcodeScannerWidget({super.key, required this.onBarcodeFound});

  @override
  BarcodeScannerWidgetState createState() => BarcodeScannerWidgetState();
}

class BarcodeScannerWidgetState extends State<BarcodeScannerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    returnImage: false,
  );

  @override
  void initState() {
    super.initState();

    // Red Line Animation (Moves Up and Down)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 50, end: 250).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Scan Barcode",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Scanner Box
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Camera Scanner
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: MobileScanner(
                      fit: BoxFit.cover,
                      controller: controller,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;

                        if (barcodes.isNotEmpty) {
                          final Barcode barcode = barcodes.first;
                          debugPrint('Barcode found: ${barcode.rawValue}');

                          // Call the callback function with the barcode value
                          widget.onBarcodeFound(barcode.rawValue!);

                          // Close the scanner
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),

                  // Animated Red Line
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: _animation.value,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 2,
                          width: 280,
                          color: Colors.red,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarCodeButton extends StatelessWidget {
  const BarCodeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      width: 100.0,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xffD8D8D8)),
      ),
      child: const Image(
        image: AssetImage('images/barcode.png'),
      ),
    );
  }
}
