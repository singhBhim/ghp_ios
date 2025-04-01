import 'dart:convert';

UserProfileModel userProfileModelFromJson(String str) =>
    UserProfileModel.fromJson(json.decode(str));

String userProfileModelToJson(UserProfileModel data) =>
    json.encode(data.toJson());

class UserProfileModel {
  bool? status;
  String? message;
  Data? data;

  UserProfileModel({
    this.status,
    this.message,
    this.data,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  User? user;

  Data({
    this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
      };
}

class User {
  int? id;
  String? uid;
  String? role;
  String? status;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? image;
  String? phone;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? deviceId;
  String? societyName;
  String? unitType;
  String? floorNumber;
  String? blockName;
  String? aprtNo;
  BlockInfo? blockInfo;
  dynamic categoryName;
  dynamic categoryId;
  int? memberId;
  int? societyId;
  dynamic staffId;
  String? imageUrl;
  LastCheckinDetail? lastCheckinDetail;

  User({
    this.id,
    this.uid,
    this.role,
    this.status,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.image,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.deviceId,
    this.societyName,
    this.unitType,
    this.floorNumber,
    this.blockName,
    this.aprtNo,
    this.blockInfo,
    this.categoryName,
    this.categoryId,
    this.memberId,
    this.societyId,
    this.staffId,
    this.imageUrl,
    this.lastCheckinDetail,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        uid: json["uid"],
        role: json["role"],
        status: json["status"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        image: json["image"],
        phone: json["phone"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deviceId: json["device_id"],
        societyName: json["society_name"],
        unitType: json["unit_type"],
        floorNumber: json["floor_number"],
        blockName: json["block_name"],
        aprtNo: json["aprt_no"],
        blockInfo: json["block_info"] == null
            ? null
            : BlockInfo.fromJson(json["block_info"]),
        categoryName: json["category_name"],
        categoryId: json["category_id"],
        memberId: json["member_id"],
        societyId: json["society_id"],
        staffId: json["staff_id"],
        imageUrl: json["image_url"],
        lastCheckinDetail: json["last_checkin_detail"] == null
            ? null
            : LastCheckinDetail.fromJson(json["last_checkin_detail"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uid": uid,
        "role": role,
        "status": status,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "image": image,
        "phone": phone,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "device_id": deviceId,
        "society_name": societyName,
        "unit_type": unitType,
        "floor_number": floorNumber,
        "block_name": blockName,
        "aprt_no": aprtNo,
        "block_info": blockInfo?.toJson(),
        "category_name": categoryName,
        "category_id": categoryId,
        "member_id": memberId,
        "society_id": societyId,
        "staff_id": staffId,
        "image_url": imageUrl,
        "last_checkin_detail": lastCheckinDetail?.toJson(),
      };
}

class BlockInfo {
  int? id;
  String? propertyNumber;
  String? floor;
  String? ownership;
  String? bhk;
  String? totalFloor;
  String? unitType;
  String? unitSize;
  int? unitQty;
  String? name;
  int? totalUnits;
  int? societyId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  BlockInfo({
    this.id,
    this.propertyNumber,
    this.floor,
    this.ownership,
    this.bhk,
    this.totalFloor,
    this.unitType,
    this.unitSize,
    this.unitQty,
    this.name,
    this.totalUnits,
    this.societyId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory BlockInfo.fromJson(Map<String, dynamic> json) => BlockInfo(
        id: json["id"],
        propertyNumber: json["property_number"],
        floor: json["floor"],
        ownership: json["ownership"],
        bhk: json["bhk"],
        totalFloor: json["total_floor"],
        unitType: json["unit_type"],
        unitSize: json["unit_size"],
        unitQty: json["unit_qty"],
        name: json["name"],
        totalUnits: json["total_units"],
        societyId: json["society_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "property_number": propertyNumber,
        "floor": floor,
        "ownership": ownership,
        "bhk": bhk,
        "total_floor": totalFloor,
        "unit_type": unitType,
        "unit_size": unitSize,
        "unit_qty": unitQty,
        "name": name,
        "total_units": totalUnits,
        "society_id": societyId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
      };
}

class LastCheckinDetail {
  int? id;
  dynamic visitorId;
  String? status;
  dynamic requestedAt;
  DateTime? checkinAt;
  dynamic checkoutAt;
  dynamic requestBy;
  int? checkinBy;
  dynamic checkoutBy;
  dynamic visitorOf;
  int? societyId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic parcelId;
  int? byResident;

  LastCheckinDetail({
    this.id,
    this.visitorId,
    this.status,
    this.requestedAt,
    this.checkinAt,
    this.checkoutAt,
    this.requestBy,
    this.checkinBy,
    this.checkoutBy,
    this.visitorOf,
    this.societyId,
    this.createdAt,
    this.updatedAt,
    this.parcelId,
    this.byResident,
  });

  factory LastCheckinDetail.fromJson(Map<String, dynamic> json) =>
      LastCheckinDetail(
        id: json["id"],
        visitorId: json["visitor_id"],
        status: json["status"],
        requestedAt: json["requested_at"],
        checkinAt: json["checkin_at"] == null
            ? null
            : DateTime.parse(json["checkin_at"]),
        checkoutAt: json["checkout_at"],
        requestBy: json["request_by"],
        checkinBy: json["checkin_by"],
        checkoutBy: json["checkout_by"],
        visitorOf: json["visitor_of"],
        societyId: json["society_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        parcelId: json["parcel_id"],
        byResident: json["by_resident"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "visitor_id": visitorId,
        "status": status,
        "requested_at": requestedAt,
        "checkin_at": checkinAt?.toIso8601String(),
        "checkout_at": checkoutAt,
        "request_by": requestBy,
        "checkin_by": checkinBy,
        "checkout_by": checkoutBy,
        "visitor_of": visitorOf,
        "society_id": societyId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "parcel_id": parcelId,
        "by_resident": byResident,
      };
}
