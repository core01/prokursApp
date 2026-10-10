// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_profile_input.g.dart';

@JsonSerializable()
class UpdateProfileInput {
  const UpdateProfileInput({
    required this.firstName,
    this.lastName,
  });
  
  factory UpdateProfileInput.fromJson(Map<String, Object?> json) => _$UpdateProfileInputFromJson(json);
  
  /// First name
  final String firstName;

  /// Last name; left out, it stays as it is, and an empty one clears it
  @JsonKey(includeIfNull: false)
  final String? lastName;

  Map<String, Object?> toJson() => _$UpdateProfileInputToJson(this);
}
