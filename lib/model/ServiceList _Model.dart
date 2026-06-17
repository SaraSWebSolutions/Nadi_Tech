import 'dart:convert';

ServiceListModel serviceListFromJson(String str) =>
    ServiceListModel.fromJson(json.decode(str));

String serviceListToJson(ServiceListModel data) => json.encode(data.toJson());

/// ===============================
/// SERVICE LIST MODEL
/// ===============================
class ServiceListModel {
  final int count;
  final List<Datum> data;

  ServiceListModel({required this.count, required this.data});

  factory ServiceListModel.fromJson(Map<String, dynamic> json) {
    return ServiceListModel(
      count: json["count"] ?? 0,

      data: json["data"] is List
          ? (json["data"] as List).map((x) => Datum.fromJson(x)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "count": count,
    "data": data.map((x) => x.toJson()).toList(),
  };
}

/// ===============================
/// DATUM (SERVICE REQUEST)
/// ===============================
class Datum {
  final StatusTimestamps statusTimestamps;
  final String id;
  final UserId userId;
  final ServiceId serviceId;
  final IssuesId issuesId;

  final String? otherIssue;
  final String? feedback;

  final DateTime scheduleService;
  final bool immediateAssistance;
  final String serviceStatus;
  final String? voice;
  final String? reason;
  final bool technicianAccepted;
  final int payment;
  final String? scheduleServiceTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String serviceRequestId;
  final Address address;
  final List<String> media;
  final String assignmentStatus;
  final String? assignmentReason;

  final TechnicianUserService? technicianUserService;

  Datum({
    required this.statusTimestamps,
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.issuesId,
    this.otherIssue,
    this.feedback,
    required this.scheduleService,
    required this.immediateAssistance,
    required this.serviceStatus,
    this.reason,
    required this.technicianAccepted,
    required this.payment,
    required this.createdAt,
    required this.updatedAt,
    required this.media,
    required this.serviceRequestId,
    required this.address,
    required this.assignmentStatus,
    required this.scheduleServiceTime,
    this.assignmentReason,
    this.technicianUserService,
    this.voice,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      statusTimestamps: StatusTimestamps.fromJson(
        json["statusTimestamps"] ?? {},
      ),
      id: json["_id"] ?? "",
      userId: UserId.fromJson(json["userId"] ?? {}),
      serviceId: ServiceId.fromJson(json["serviceId"] ?? {}),
      issuesId: IssuesId.fromJson(json["issuesId"] ?? {}),

      otherIssue: json["otherIssue"],
      feedback: json["feedback"],
      voice: json["voice"],
      scheduleService:
          DateTime.tryParse(json["scheduleService"] ?? "") ?? DateTime.now(),
      immediateAssistance: json["immediateAssistance"] ?? false,
      serviceStatus: json["serviceStatus"] ?? "",
      scheduleServiceTime: json['scheduleServiceTime'],
      reason: json["reason"],
      technicianAccepted: json["technicianAccepted"] ?? false,
      payment: json["payment"] ?? 0,

      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? "") ?? DateTime.now(),

      serviceRequestId: json["serviceRequestID"] ?? "",
      address: Address.fromJson(json["address"] ?? {}),
      media: json["media"] is List ? List<String>.from(json["media"]) : [],
      assignmentStatus: json["assignmentStatus"] ?? "",
      assignmentReason: json["assignmentReason"],
      technicianUserService: json["technicianUserService"] != null
          ? TechnicianUserService.fromJson(json["technicianUserService"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "serviceRequestID": serviceRequestId,
    "feedback": feedback,
    "serviceStatus": serviceStatus,
    "payment": payment,
    "scheduleServiceTime": scheduleServiceTime,
    "technicianUserService": technicianUserService?.toJson(),
  };
}

class TechnicianUserService {
  final String id;
  final String userServiceId;
  final bool adminNotified;
  final List<Assignment> assignments;

  TechnicianUserService({
    required this.id,
    required this.userServiceId,
    required this.adminNotified,
    required this.assignments,
  });

  factory TechnicianUserService.fromJson(Map<String, dynamic> json) {
    return TechnicianUserService(
      id: json["_id"] ?? "",
      userServiceId: json["userServiceId"] ?? "",
      adminNotified: json["adminNotified"] ?? false,
      assignments: json["assignments"] is List
          ? (json["assignments"] as List)
                .map((x) => Assignment.fromJson(x))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userServiceId": userServiceId,
    "adminNotified": adminNotified,
    "assignments": assignments.map((x) => x.toJson()).toList(),
  };
}

/// ===============================
/// ASSIGNMENTS
/// ===============================
class Assignment {
  final String technicianId;
  final String status;
  final String? notes;
  final List<String> media;
  final int workDuration;
  final List<UsedPart> usedParts;
  final bool paymentRaised;
  final DateTime? workStartedAt;
  final DateTime? statusChangedAt;
  final DateTime? updatedAt;
  final bool userApproval; // 👈 ADD THIS

  Assignment({
    required this.technicianId,
    required this.status,
    this.notes,
    required this.media,
    required this.workDuration,
    required this.usedParts,
    required this.paymentRaised,
    this.workStartedAt,
    this.updatedAt,
    this.statusChangedAt,
    required this.userApproval, // 👈 ADD THIS
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      technicianId: json["technicianId"] ?? "",
      status: json["status"] ?? "",
      notes: json["notes"],
      media: json["media"] != null ? List<String>.from(json["media"]) : [],
      statusChangedAt: DateTime.tryParse(json["statusChangedAt"] ?? ""),
      userApproval: json["userApproval"] ?? false, // 👈 ADD THIS

      workDuration: json["workDuration"] ?? 0,
      usedParts: json["usedParts"] is List
          ? (json["usedParts"] as List)
                .map((x) => UsedPart.fromJson(x))
                .toList()
          : [],
      paymentRaised: json["paymentRaised"] ?? false,
      workStartedAt: DateTime.tryParse(json["workStartedAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "technicianId": technicianId,
    "status": status,
    "notes": notes,
    "media": media,
    "workDuration": workDuration,
    "userApproval": userApproval, // 👈 ADD THIS
    "usedParts": usedParts.map((x) => x.toJson()).toList(),
    "paymentRaised": paymentRaised,
    "workStartedAt": workStartedAt?.toIso8601String(),
    "statusChangedAt": statusChangedAt?.toIso8601String(),
  };
}

/// ===============================
/// USED PARTS
/// ===============================
class UsedPart {
  final String productId;
  final String productName;
  final int count;
  final int price;
  final int total;

  UsedPart({
    required this.productId,
    required this.productName,
    required this.count,
    required this.price,
    required this.total,
  });

  factory UsedPart.fromJson(Map<String, dynamic> json) {
    return UsedPart(
      productId: json["productId"] ?? "",
      productName: json["productName"] ?? "",
      count: json["count"] ?? 0,
      price: json["price"] ?? 0,
      total: json["total"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "productName": productName,
    "count": count,
    "price": price,
    "total": total,
  };
}

/// ===============================
/// ADDRESS
/// ===============================
class Address {
  final String id;
  final String userId;
  final String addressType;
  final String city;
  final String building;
  final String floor;
  final int? aptNo;

  final String? roadId;
  final String? roadName;

  final String? blockId;
  final String? blockName;

  final double? latitude;
  final double? longitude;
  final bool isGeoAddress;
  final String? geoAddress;

  Address({
    required this.id,
    required this.userId,
    required this.addressType,
    required this.city,
    required this.building,
    required this.floor,
    this.aptNo,
    this.roadId,
    this.roadName,
    this.blockId,
    this.blockName,
    this.latitude,
    this.longitude,
    required this.isGeoAddress,
    this.geoAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json["_id"] ?? "",
      userId: json["userId"] ?? "",
      addressType: json["addressType"] ?? "",
      city: json["city"] ?? "",
      building: json["building"] ?? "",
      floor: json["floor"] ?? "",
      aptNo: json["aptNo"],

      roadId: json["roadId"],
      roadName: json["roadName"],

      blockId: json["blockId"],
      blockName: json["blockName"],

      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),

      isGeoAddress: json["isGeoAddress"] ?? false,
      geoAddress: json["geoAddress"],
    );
  }
}

/// ===============================
/// ISSUES
/// ===============================
class IssuesId {
  final String id;
  final String serviceId;
  final String issue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? issueAr;
  final String? issueEn;

  IssuesId({
    required this.id,
    required this.serviceId,
    required this.issue,
    required this.createdAt,
    required this.updatedAt,
    required this.issueEn,
    required this.issueAr,
  });

  factory IssuesId.fromJson(Map<String, dynamic> json) {
    return IssuesId(
      id: json["_id"] ?? "",
      serviceId: json["serviceId"] ?? "",
      issue: json["issue"] ?? "",

      issueAr: json["issue_ar"],
      issueEn: json["issue_en"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? "") ?? DateTime.now(),
    );
  }
}

/// ===============================
/// SERVICE INFO
/// ===============================
class ServiceId {
  final String id;
  final String name;
  final String? nameEn;
  final String serviceImage;
  final String serviceLogo;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceId({
    required this.id,
    required this.name,
    this.nameEn,
    required this.serviceImage,
    required this.serviceLogo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceId.fromJson(Map<String, dynamic> json) {
    return ServiceId(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      nameEn: json["name_en"], // 👈 ADD THIS
      serviceImage: json["serviceImage"] ?? "",
      serviceLogo: json["serviceLogo"] ?? "",
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? "") ?? DateTime.now(),
    );
  }
}

/// ===============================
/// STATUS TIMESTAMPS
/// ===============================
class StatusTimestamps {
  final DateTime submitted;
  final DateTime? technicianAssigned;
  final DateTime? inProgress;
  final DateTime? paymentInProgress;
  final DateTime? completed;
  final DateTime? accepted;

  StatusTimestamps({
    required this.submitted,
    this.technicianAssigned,
    this.inProgress,
    this.paymentInProgress,
    this.completed,
    this.accepted,
  });

  factory StatusTimestamps.fromJson(Map<String, dynamic> json) {
    return StatusTimestamps(
      submitted: DateTime.tryParse(json["submitted"] ?? "") ?? DateTime.now(),
      technicianAssigned: DateTime.tryParse(json["technicianAssigned"] ?? ""),
      inProgress: DateTime.tryParse(json["inProgress"] ?? ""),
      paymentInProgress: DateTime.tryParse(json["paymentInProgress"] ?? ""),
      completed: DateTime.tryParse(json["completed"] ?? ""),
      accepted: DateTime.tryParse(json["accepted"] ?? ""),
    );
  }
}

/// ===============================
/// USER
/// ===============================
class UserId {
  final BasicInfo basicInfo;
  final String id;

  UserId({required this.basicInfo, required this.id});

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      basicInfo: BasicInfo.fromJson(json["basicInfo"] ?? {}),
      id: json["_id"] ?? "",
    );
  }
}

/// ===============================
/// BASIC INFO
/// ===============================
class BasicInfo {
  final String fullName;
  final int mobileNumber;
  final String email;
  final String gender;

  BasicInfo({
    required this.fullName,
    required this.mobileNumber,
    required this.email,
    required this.gender,
  });

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return BasicInfo(
      fullName: json["fullName"] ?? "",
      mobileNumber: json["mobileNumber"] ?? 0,
      email: json["email"] ?? "",
      gender: json["gender"] ?? "",
    );
  }
}
