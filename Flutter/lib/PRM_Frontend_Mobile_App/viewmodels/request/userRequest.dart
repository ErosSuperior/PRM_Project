class UpdateUserProfileRequest {
  String? name;
  String? phone;
  String? address;

  UpdateUserProfileRequest({this.name, this.phone, this.address});

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
    };
  }
}

class UpdateWorkerProfileRequest {
  UpdateUserProfileRequest? baseProfile;
  int? experienceYears;
  String? bio;
  bool? isAvailable;

  UpdateWorkerProfileRequest({
    this.baseProfile,
    this.experienceYears,
    this.bio,
    this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    return {
      if (baseProfile != null) 'baseProfile': baseProfile!.toJson(),
      if (experienceYears != null) 'experienceYears': experienceYears,
      if (bio != null) 'bio': bio,
      if (isAvailable != null) 'isAvailable': isAvailable,
    };
  }
}
