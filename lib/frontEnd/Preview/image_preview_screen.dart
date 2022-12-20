import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../Global_Uses/enum.dart';

class ImageViewScreen extends StatefulWidget {
  final ImageProviderCategory imageProviderCategory;
  final String imagePath;

  ImageViewScreen(
      {Key? key, required this.imageProviderCategory, required this.imagePath})
      : super(key: key);

  @override
  _ImageViewScreenState createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: PhotoView(
            imageProvider: _getParticularImage(),
            enableRotation: true,
            initialScale: null,
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(),
            ),
            errorBuilder: (context, obj, stackTrace) => Center(
                child: Text(
                  'Image not Found',
                  style: TextStyle(
                    fontSize: 23.0,
                    color: Colors.red,
                    fontFamily: 'Lora',
                    letterSpacing: 1.0,
                  ),
                )),
          ),
        ),
      ),
    );
  }
//bu sayfaya gelen parametre eger foto ise fotograf calistiran widgeti kullancz veya file ise dosyayi acan bi widget kullanacz veya internetten gelen fotolari acan widgeti kullancz
  _getParticularImage() {
    switch (widget.imageProviderCategory) {
      case ImageProviderCategory.FileImage:
        return FileImage(File(widget.imagePath));

      case ImageProviderCategory.ExactAssetImage:
        return ExactAssetImage(widget.imagePath);

      case ImageProviderCategory.NetworkImage:
        return NetworkImage(widget.imagePath);
    }
  }
}