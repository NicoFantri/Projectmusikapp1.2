import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget customCachedImage({
  required String url,
  double? width,
  double? height,
  bool? isRectangle,
  bool? withBorder,
  double? radius,
  bool? isDrive = true,
  bool? isBlack,
}) {
  return kIsWeb
      ? AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeIn,
          width: width ?? 35,
          height: height ?? 35,
          decoration: BoxDecoration(
            shape:
                (isRectangle ?? false) ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: (isRectangle ?? false)
                ? BorderRadius.circular(radius ?? 0)
                : null,
            border: (withBorder ?? false)
                ? Border.all(
                    color: Theme.of(Get.context!).colorScheme.primary,
                    width: 3.5)
                : null,
            image: DecorationImage(
              image: NetworkImage(url, scale: 0.5),
              fit: BoxFit.cover,
            ),
          ),
        )
      : CachedNetworkImage(
          width: width ?? 35,
          height: height ?? 35,
          imageUrl: url,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              shape:
                  (isRectangle ?? false) ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: (isRectangle ?? false)
                  ? BorderRadius.circular(radius ?? 0)
                  : null,
              border: (withBorder ?? false)
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary, width: 3.5)
                  : null,
              image: DecorationImage(
                image: imageProvider,
                colorFilter: (isBlack ?? false)
                    ? const ColorFilter.mode(Colors.black45, BlendMode.multiply)
                    : null,
                fit: BoxFit.cover,
              ),
            ),
          ),
          placeholder: (context, url) {
            return Container(
              width: width ?? 35,
              height: height ?? 35,
              decoration: BoxDecoration(
                shape: (isRectangle ?? false)
                    ? BoxShape.rectangle
                    : BoxShape.circle,
                borderRadius: (isRectangle ?? false)
                    ? BorderRadius.circular(radius ?? 0)
                    : null,
                border: (withBorder ?? false)
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3.5)
                    : null,
                image: DecorationImage(
                  image: NetworkImage(
                      "$url${(isDrive ?? false) ? "=w100-h100-p-k-rw-v1-nu-iv1" : ""}"),
                  fit: BoxFit.cover,
                ),
              ),
              child: const CupertinoActivityIndicator(),
            );
          },
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
}
