import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/vaildData/valid_data.dart';

class Picture extends StatelessWidget {
  const Picture(
      this.src, {
        super.key,
        this.fallbackSrc, // ✅ صورة احتياطية
        this.placeholder,
        this.height,
        this.width,
        this.color,
        this.fit,
        this.paddingEdgeInsets,
        this.loadingBuilder,
        this.imageBuilder,
      }) : memory = null;

  const Picture.memory(
      Uint8List this.memory, {
        super.key,
        this.fallbackSrc,
        this.placeholder,
        this.height,
        this.width,
        this.color,
        this.fit,
        this.paddingEdgeInsets,
      })  : src = '',
        loadingBuilder = null,
        imageBuilder = null;

  final String src;
  final String? fallbackSrc; // ✅ لينك صورة بديلة
  final Widget Function(double progress)? loadingBuilder;
  final Widget Function(ImageProvider provider)? imageBuilder;
  final Widget? placeholder;
  final Uint8List? memory;
  final Color? color;
  final EdgeInsets? paddingEdgeInsets;
  final double? height;
  final double? width;
  final BoxFit? fit;

  static const String _defaultErrorAsset = "assets/images/placeholder.jpg";

  @override
  Widget build(BuildContext context) {
    final isSvg = src.endsWith('svg');

    if (placeholder != null && !validString(src)) {
      return placeholder!;
    }

    final isMemory = memory != null;
    if (isMemory) {
      return isSvg ? _memSvg() : _memImage();
    }

    final isAsset = src.startsWith('assets');
    if (isAsset) {
      return isSvg ? _assetSvg() : _assetImage();
    }

    final isNetwork = src.startsWith('http');
    if (isNetwork) {
      return isSvg ? _networkSvg(src) : _networkImage(src);
    }

    final file = File(src);
    final isFile = file.existsSync();
    if (isFile) {
      return isSvg ? _fileSvg(file) : _fileImage(file);
    }

    return _errorImage();
  }

  /// fallback image widget
  Widget _errorImage() => Image.asset(
    _defaultErrorAsset,
    height: height,
    width: width,
    fit: fit ?? BoxFit.contain,
  );

  Widget _assetImage() => _safeWrap(
    child: Image.asset(
      src,
      height: height,
      color: color,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => _handleFallback(),
    ),
  );

  Widget _networkImage(String url) => CachedNetworkImage(
    imageUrl: url,
    height: height,
    width: width,
    color: color,
    fit: fit,
    placeholder: placeholder == null ? null : (context, url) => placeholder!,
    errorWidget: (_, __, ___) => _handleFallback(),
    imageBuilder: imageBuilder == null
        ? null
        : (context, imageProvider) => imageBuilder!.call(imageProvider),
    progressIndicatorBuilder: loadingBuilder == null
        ? null
        : (context, url, progress) => loadingBuilder!
        .call(progress.downloaded / (progress.totalSize ?? 1)),
  );

  Widget _fileImage(File file) => Image.file(
    file,
    color: color,
    height: height,
    width: width,
    fit: fit,
    errorBuilder: (_, __, ___) => _handleFallback(),
  );

  Widget _memImage() => Image.memory(
    memory!,
    color: color,
    height: height,
    width: width,
    fit: fit,
    errorBuilder: (_, __, ___) => _handleFallback(),
  );

  Widget _assetSvg() => _safeWrap(
    child: SvgPicture.asset(
      src,
      height: height,
      color: color,
      width: width,
      fit: fit ?? BoxFit.contain,
      placeholderBuilder: placeholder == null
          ? (context) => _handleFallback()
          : (context) => placeholder!,
    ),
  );

  Widget _networkSvg(String url) => SvgPicture.network(
    url,
    color: color,
    height: height,
    width: width,
    fit: fit ?? BoxFit.contain,
    placeholderBuilder: placeholder == null
        ? (context) => _handleFallback()
        : (context) => placeholder!,
  );

  Widget _fileSvg(File file) => SvgPicture.file(
    file,
    color: color,
    height: height,
    width: width,
    fit: fit ?? BoxFit.contain,
    placeholderBuilder: placeholder == null
        ? (context) => _handleFallback()
        : (context) => placeholder!,
  );

  Widget _memSvg() => SvgPicture.memory(
    memory!,
    color: color,
    height: height,
    width: width,
    fit: fit ?? BoxFit.contain,
    placeholderBuilder: placeholder == null
        ? (context) => _handleFallback()
        : (context) => placeholder!,
  );

  /// ✅ لو في fallbackSrc يرجع NetworkImage تاني، غير كده يرجع error image
  Widget _handleFallback() {
    if (fallbackSrc != null && fallbackSrc!.startsWith('http')) {
      return _networkImage(fallbackSrc!);
    }
    return _errorImage();
  }

  Widget _safeWrap({required Widget child}) =>
      paddingEdgeInsets == null ? child : Padding(padding: paddingEdgeInsets!, child: child);
}
