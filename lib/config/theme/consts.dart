import 'package:country_picker/country_picker.dart';
import 'package:size_config/size_config.dart';

final hPadding = 30.w; // page default horizontal padding
final vPadding = 30.h; // page default Vertical padding in  screens
final hPadding2 = 20.w; // page default horizontal padding in  screens
final iconsWidth = 18.w; // icon default width
final iconsHeight = 18.w; // icon default height
getInitialCountry(String? code) => CountryParser.parseCountryCode(code ?? 'SA');
const String splashScreen = "assets/anims/splash.json";

double get buttonHeight => 56.h;

double get highAppBarHeight => 110.h;
double get lowAppBarHeight => 80.h;
