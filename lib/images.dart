library images;
import 'package:puzzle/setup.dart';
import 'package:puzzle/log.dart';
import 'dart:html';


List<String> localImages = ['lake.jpg', 'tux.jpg', 'bear_noel.jpg', 'gengibre.jpg', 'horse.jpg', 'horses.jpg', 'rudolf.jpg', 'snowman.jpg', 'st_claus.jpg'];




class _CachedImages {
  Map<String, ImageElement> cachedImages = new Map<String, ImageElement>();
  List<String> cachedImagesOlderFirst = new List<String>();

  void prepareImage(String url, Config config, var callback_on_loaded) {
    if (cachedImages.containsKey(url) == false) {
      writeLog("requesting image $url to server");
      config.currentImage = new ImageElement(src: url);
      config.currentImage.onLoad.listen((_) => callback_on_loaded(config));
      cachedImages[url] = config.currentImage;
      cachedImagesOlderFirst.add(url);
      writeLog("added image $url to cache");
    } else {
      writeLog("getting image  $url from cache");
      config.currentImage = cachedImages[url];
      callback_on_loaded(config);
    }
    if (cachedImages.length > 15) {
      writeLog("too many images on cache, removing images from cache.");
      for (int i = 0; i < 5; ++i) {
        var name = cachedImagesOlderFirst.first;
        writeLog("deleting from cache $name to server");
        cachedImages.remove(name);
        cachedImagesOlderFirst.remove(name);
      }
    }
  }

  void _clean() {

  }
}

_CachedImages _cachedImages = new _CachedImages();



void prepareImageFromServerFile(String url, Config config, var callback_on_loaded) {
  _cachedImages.prepareImage(url, config, callback_on_loaded);
}
