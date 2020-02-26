import 'package:photo_manager/photo_manager.dart';

class ConvertUtils {
  static List<AssetPathEntity> convertPath(
    Map data, {
    int type = 0,
    DateTime dt,
    FilterOptionGroup optionGroup,
  }) {
    List<AssetPathEntity> result = [];

    List list = data["data"];

    for (final Map item in list) {
      final entity = AssetPathEntity(filterOption: optionGroup)
        ..id = item["id"]
        ..name = item["name"]
        ..typeInt = type
        ..isAll = item["isAll"]
        ..fetchDatetime = dt
        ..assetCount = item["length"];

      result.add(entity);
    }

    return result;
  }

  static List<AssetEntity> convertToAssetList(Map data) {
    List<AssetEntity> result = [];

    List list = data["data"];
    for (final Map item in list) {
      final entity = AssetEntity()
        ..id = item["id"]
        ..path = item["path"]
        ..createDtSecond = item["createDt"]
        ..width = item["width"]
        ..height = item["height"]
        ..duration = item["duration"]
        ..modifiedDateSecond = item["modifiedDt"]
        ..typeInt = item["type"]
        ..longitude = item["lng"]
        ..latitude = item["lat"]
        ..title = item["title"]
        ..fileSize = item["fileSize"];

      result.add(entity);
    }

    return result;
  }

  static AssetEntity convertToAsset(Map map) {
    if (map == null) {
      return null;
    }

    Map data = map["data"];

    final entity = AssetEntity()
      ..id = data["id"]
      ..path = data["path"]
      ..createDtSecond = data["createDt"]
      ..width = data["width"]
      ..height = data["height"]
      ..duration = data["duration"]
      ..modifiedDateSecond = data["modifiedDt"]
      ..typeInt = data["type"]
      ..longitude = data["lng"]
      ..latitude = data["lat"]
      ..title = data["title"]
      ..fileSize = data["fileSize"];

    return entity;
  }
}
