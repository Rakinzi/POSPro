import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

Future<img.Image?> getNetworkImage(
  String? url, {
  int width = 250,
  int height = 250,
}) async {
  if (url == null) return null;

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return null;

    final _image = img.decodeImage(response.bodyBytes);
    if (_image == null) return null;
    return img.copyResize(
      _image,
      width: width,
      height: height,
      interpolation: img.Interpolation.average,
    );
  } catch (e) {
    return null;
  }
}
