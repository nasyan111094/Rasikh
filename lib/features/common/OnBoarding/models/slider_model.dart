import 'package:rasikh/config/localization/loc_keys.dart';

class SliderModel {
  String? imageAssetPath;
  String? title;
  String? desc;

  SliderModel({this.imageAssetPath, this.desc});

  void setImageAssetPath(String getImageAssetPath) {
    imageAssetPath = getImageAssetPath;
  }

  void setDesc(String getDesc) {
    desc = getDesc;
  }

  String getImageAssetPath() {
    return imageAssetPath!;
  }

  String getDesc() {
    return desc!;
  }
}

List<SliderModel> getSlides() {
  List<SliderModel> slides = <SliderModel>[];
  SliderModel sliderModel = SliderModel();

  sliderModel.setDesc(
      Loc.sliderOffersDescription());
  sliderModel.setImageAssetPath("assets/images/introdcution1.png");
  slides.add(sliderModel);

  sliderModel = SliderModel();

  sliderModel.setDesc(
      Loc.sliderOffersDescription());
  sliderModel.setImageAssetPath("assets/images/introdcution2.png");
  slides.add(sliderModel);

  sliderModel = SliderModel();

  sliderModel.setDesc(
      Loc.sliderOffersDescription());
  sliderModel.setImageAssetPath("assets/images/introdcution2.png");
  slides.add(sliderModel);

  sliderModel = SliderModel();

  return slides;
}
