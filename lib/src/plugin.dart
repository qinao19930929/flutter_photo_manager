import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager/src/utils/convert_utils.dart';

class Plugin {
  static const MethodChannel _channel =
      const MethodChannel('top.kikt/photo_manager');

  static DateTime _createDefaultFetchDatetime() {
    return DateTime.now();
  }

  static Plugin _plugin;

  factory Plugin() {
    _plugin ??= Plugin._();
    return _plugin;
  }

  Plugin._();

  /// [type] 0 : all , 1: image ,2 video
  Future<List<AssetPathEntity>> getAllGalleryList({
    int type = 0,
    DateTime dt,
    bool hasAll = true,
    FilterOption fliterOption,
  }) async {
    dt ??= _createDefaultFetchDatetime();

    final result = await _channel.invokeMethod("getGalleryList", {
      "type": type,
      "timestamp": dt.millisecondsSinceEpoch,
      "hasAll": hasAll,
      "option": fliterOption.toMap(),
    });
    if (result == null) {
      return [];
    }
    return ConvertUtils.convertPath(
      result,
      type: type,
      dt: dt,
      fliterOption: fliterOption,
    );
  }

  Future<bool> requestPermission() async {
    return (await _channel.invokeMethod("requestPermission")) == 1;
  }

  Future<List<AssetEntity>> getAssetWithGalleryIdPaged(
    String id, {
    int page = 0,
    int pageCount = 15,
    int type = 0,
    DateTime pagedDt,
    FilterOption filterOption,
  }) async {
    pagedDt ??= _createDefaultFetchDatetime();

    final result = await _channel.invokeMethod("getAssetWithGalleryId", {
      "id": id,
      "page": page,
      "pageCount": pageCount,
      "type": type,
      "timestamp": pagedDt.millisecondsSinceEpoch,
      "option": filterOption.toMap(),
    });

    return ConvertUtils.convertToAssetList(result);
  }

  Future<List<AssetEntity>> getAssetWithRange(
    String id, {
    int typeInt,
    int start,
    int end,
    DateTime fetchDt,
    FilterOption filterOption,
  }) async {
    final Map map = await _channel.invokeMethod("getAssetListWithRange", {
      "galleryId": id,
      "type": typeInt,
      "start": start,
      "end": end,
      "timestamp": fetchDt.millisecondsSinceEpoch,
      "option": filterOption.toMap(),
    });

    return ConvertUtils.convertToAssetList(map);
  }

  Future<Uint8List> getThumb({
    @required String id,
    int width = 100,
    int height = 100,
    ThumbFormat format,
  }) {
    return _channel.invokeMethod("getThumb", {
      "width": width,
      "height": height,
      "id": id,
      "format": format!=null?format.index:null,
    });
  }

  Future<Uint8List> getOriginBytes(String id) async {
    return _channel.invokeMethod("getOriginBytes", {"id": id});
  }

  Future<void> releaseCache() async {
    await _channel.invokeMethod("releaseMemCache");
  }

  Future<String> getFullFile(String id, {bool isOrigin}) async {
    return _channel.invokeMethod("getFullFile", {
      "id": id,
      "isOrigin": isOrigin,
    });
  }

  Future<void> setLog(bool isLog) async {
    return _channel.invokeMethod("log", isLog);
  }

  void openSetting() {
    _channel.invokeMethod("openSetting");
  }

  Future<Map> fetchPathProperties(
      String id, int type, DateTime datetime, FilterOption filterOption) async {
    datetime ??= _createDefaultFetchDatetime();
    return _channel.invokeMethod(
      "fetchPathProperties",
      {
        "id": id,
        "timestamp": datetime.millisecondsSinceEpoch,
        "type": type,
        "option": filterOption.toMap(),
      },
    );
  }

  void notifyChange({bool start}) {
    _channel.invokeMethod("notify", {
      "notify": start,
    });
  }

  bool androidQExperimental = false;

  Future<void> setAndroidQExperimental(bool open) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod("androidQExperimental", {
        "open": open,
      });
      androidQExperimental = open;
    }
  }

  Future<void> forceOldApi() async {
    await _channel.invokeMethod("forceOldApi");
  }

  Future<bool> deleteWithId(String id) async {
    final ids = await deleteWithIds([id]);
    return ids.contains(id);
  }

  Future<List<String>> deleteWithIds(List<String> ids) async {
    final List<dynamic> deleted =
        (await _channel.invokeMethod("deleteWithIds", {"ids": ids}));
    return deleted.cast<String>();
  }

  Future<AssetEntity> saveImage(Uint8List uint8list,
      {String title, String desc = ""}) async {
    title ??= "image_${DateTime.now().millisecondsSinceEpoch / 1000}";

    final result = await _channel.invokeMethod(
      "saveImage",
      {
        "image": uint8list,
        "title": title,
        "desc": desc,
      },
    );

    return ConvertUtils.convertToAsset(result);
  }

  Future<AssetEntity> saveVideo(File file,
      {String title, String desc = ""}) async {
    if (!file.existsSync()) {
      return null;
    }
    final result = await _channel.invokeMethod(
      "saveVideo",
      {
        "path": file.absolute.path,
        "title": title,
        "desc": desc,
      },
    );
    return ConvertUtils.convertToAsset(result);
  }

  Future<bool> assetExistsWithId(String id) {
    return _channel.invokeMethod("assetExists", {"id": id});
  }

  Future<String> getSystemVersion() async {
    return _channel.invokeMethod("systemVersion");
  }

  Future<LatLng> getLatLngAsync(AssetEntity assetEntity) async {
    if (Platform.isAndroid) {
      final version = int.parse(await getSystemVersion());
      if (version >= 29) {
        final map = await _channel
            .invokeMethod("getLatLngAndroidQ", {"id": assetEntity.id});
        if (map is Map) {
          /// 将返回的数据传入map
          return LatLng()
            ..latitude = map["lat"]
            ..longitude = map["lng"];
        }
      }
    }
    return LatLng()
      ..latitude = assetEntity.latitude
      ..longitude = assetEntity.longitude;
  }

  Future<bool> cacheOriginBytes(bool cache) {
    return _channel.invokeMethod("cacheOriginBytes");
  }

  Future<String> getTitleAsync(AssetEntity assetEntity) async {
    assert(Platform.isAndroid || Platform.isIOS);
    if (Platform.isAndroid) {
      return assetEntity.title;
    }

    if (Platform.isIOS) {
      return _channel.invokeMethod("getTitleAsync", {"id": assetEntity.id});
    }

    return "";
  }
}
