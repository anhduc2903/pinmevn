class DeviceInfoException implements Exception {
  @override
  String toString() {
    return "Không thể lấy id thiết bị";
  }
}

class InternetConnectionException implements Exception {
  @override
  String toString() {
    return "Không thể kết nối tới máy chủ";
  }
}

class InvalidAccountException implements Exception {}

class DeviceNotMatchException implements Exception {
  @override
  String toString() {
    return "Code không dành cho địa điểm này";
  }
}

class LocationServiceException implements Exception {
  @override
  String toString() {
    return "Chưa bật vị trí thiết bị";
  }
}

class LocationPermissionException implements Exception {
  @override
  String toString() {
    return "Không cấp quyền truy cập vị trí thiết bị";
  }
}

class LocationLandScapeException implements Exception {
  @override
  String toString() {
    return "Chưa bật vị trí cho thiết bị";
  }
}

class TokenException implements Exception {}

class NoAdvertiseException implements Exception {}

class AdvertiseNotApproveException implements Exception {}
