// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'featured_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FeaturedContent _$FeaturedContentFromJson(Map<String, dynamic> json) {
  return _FeaturedContent.fromJson(json);
}

/// @nodoc
mixin _$FeaturedContent {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  ContentCategory get category => throw _privateConstructorUsedError;
  @IconDataConverter()
  IconData get icon => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get actionUrl => throw _privateConstructorUsedError;
  DateTime? get publishedAt => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;

  /// Serializes this FeaturedContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeaturedContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeaturedContentCopyWith<FeaturedContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeaturedContentCopyWith<$Res> {
  factory $FeaturedContentCopyWith(
          FeaturedContent value, $Res Function(FeaturedContent) then) =
      _$FeaturedContentCopyWithImpl<$Res, FeaturedContent>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      ContentCategory category,
      @IconDataConverter() IconData icon,
      String? imageUrl,
      String? actionUrl,
      DateTime? publishedAt,
      bool isFeatured});

  $ContentCategoryCopyWith<$Res> get category;
}

/// @nodoc
class _$FeaturedContentCopyWithImpl<$Res, $Val extends FeaturedContent>
    implements $FeaturedContentCopyWith<$Res> {
  _$FeaturedContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeaturedContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? icon = null,
    Object? imageUrl = freezed,
    Object? actionUrl = freezed,
    Object? publishedAt = freezed,
    Object? isFeatured = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ContentCategory,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as IconData,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      actionUrl: freezed == actionUrl
          ? _value.actionUrl
          : actionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of FeaturedContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContentCategoryCopyWith<$Res> get category {
    return $ContentCategoryCopyWith<$Res>(_value.category, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FeaturedContentImplCopyWith<$Res>
    implements $FeaturedContentCopyWith<$Res> {
  factory _$$FeaturedContentImplCopyWith(_$FeaturedContentImpl value,
          $Res Function(_$FeaturedContentImpl) then) =
      __$$FeaturedContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      ContentCategory category,
      @IconDataConverter() IconData icon,
      String? imageUrl,
      String? actionUrl,
      DateTime? publishedAt,
      bool isFeatured});

  @override
  $ContentCategoryCopyWith<$Res> get category;
}

/// @nodoc
class __$$FeaturedContentImplCopyWithImpl<$Res>
    extends _$FeaturedContentCopyWithImpl<$Res, _$FeaturedContentImpl>
    implements _$$FeaturedContentImplCopyWith<$Res> {
  __$$FeaturedContentImplCopyWithImpl(
      _$FeaturedContentImpl _value, $Res Function(_$FeaturedContentImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeaturedContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? icon = null,
    Object? imageUrl = freezed,
    Object? actionUrl = freezed,
    Object? publishedAt = freezed,
    Object? isFeatured = null,
  }) {
    return _then(_$FeaturedContentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ContentCategory,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as IconData,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      actionUrl: freezed == actionUrl
          ? _value.actionUrl
          : actionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeaturedContentImpl implements _FeaturedContent {
  const _$FeaturedContentImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.category,
      @IconDataConverter() required this.icon,
      this.imageUrl,
      this.actionUrl,
      this.publishedAt,
      this.isFeatured = false});

  factory _$FeaturedContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeaturedContentImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final ContentCategory category;
  @override
  @IconDataConverter()
  final IconData icon;
  @override
  final String? imageUrl;
  @override
  final String? actionUrl;
  @override
  final DateTime? publishedAt;
  @override
  @JsonKey()
  final bool isFeatured;

  @override
  String toString() {
    return 'FeaturedContent(id: $id, title: $title, description: $description, category: $category, icon: $icon, imageUrl: $imageUrl, actionUrl: $actionUrl, publishedAt: $publishedAt, isFeatured: $isFeatured)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeaturedContentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.actionUrl, actionUrl) ||
                other.actionUrl == actionUrl) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, category,
      icon, imageUrl, actionUrl, publishedAt, isFeatured);

  /// Create a copy of FeaturedContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeaturedContentImplCopyWith<_$FeaturedContentImpl> get copyWith =>
      __$$FeaturedContentImplCopyWithImpl<_$FeaturedContentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeaturedContentImplToJson(
      this,
    );
  }
}

abstract class _FeaturedContent implements FeaturedContent {
  const factory _FeaturedContent(
      {required final String id,
      required final String title,
      required final String description,
      required final ContentCategory category,
      @IconDataConverter() required final IconData icon,
      final String? imageUrl,
      final String? actionUrl,
      final DateTime? publishedAt,
      final bool isFeatured}) = _$FeaturedContentImpl;

  factory _FeaturedContent.fromJson(Map<String, dynamic> json) =
      _$FeaturedContentImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  ContentCategory get category;
  @override
  @IconDataConverter()
  IconData get icon;
  @override
  String? get imageUrl;
  @override
  String? get actionUrl;
  @override
  DateTime? get publishedAt;
  @override
  bool get isFeatured;

  /// Create a copy of FeaturedContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeaturedContentImplCopyWith<_$FeaturedContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ContentCategory _$ContentCategoryFromJson(Map<String, dynamic> json) {
  return _ContentCategory.fromJson(json);
}

/// @nodoc
mixin _$ContentCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  Color? get color => throw _privateConstructorUsedError;
  String? get colorHex => throw _privateConstructorUsedError;

  /// Serializes this ContentCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContentCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContentCategoryCopyWith<ContentCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContentCategoryCopyWith<$Res> {
  factory $ContentCategoryCopyWith(
          ContentCategory value, $Res Function(ContentCategory) then) =
      _$ContentCategoryCopyWithImpl<$Res, ContentCategory>;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(ignore: true) Color? color,
      String? colorHex});
}

/// @nodoc
class _$ContentCategoryCopyWithImpl<$Res, $Val extends ContentCategory>
    implements $ContentCategoryCopyWith<$Res> {
  _$ContentCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContentCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? color = freezed,
    Object? colorHex = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color?,
      colorHex: freezed == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContentCategoryImplCopyWith<$Res>
    implements $ContentCategoryCopyWith<$Res> {
  factory _$$ContentCategoryImplCopyWith(_$ContentCategoryImpl value,
          $Res Function(_$ContentCategoryImpl) then) =
      __$$ContentCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(ignore: true) Color? color,
      String? colorHex});
}

/// @nodoc
class __$$ContentCategoryImplCopyWithImpl<$Res>
    extends _$ContentCategoryCopyWithImpl<$Res, _$ContentCategoryImpl>
    implements _$$ContentCategoryImplCopyWith<$Res> {
  __$$ContentCategoryImplCopyWithImpl(
      _$ContentCategoryImpl _value, $Res Function(_$ContentCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContentCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? color = freezed,
    Object? colorHex = freezed,
  }) {
    return _then(_$ContentCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color?,
      colorHex: freezed == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContentCategoryImpl implements _ContentCategory {
  const _$ContentCategoryImpl(
      {this.id = '',
      required this.name,
      @JsonKey(ignore: true) this.color,
      this.colorHex});

  factory _$ContentCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContentCategoryImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  final String name;
  @override
  @JsonKey(ignore: true)
  final Color? color;
  @override
  final String? colorHex;

  @override
  String toString() {
    return 'ContentCategory(id: $id, name: $name, color: $color, colorHex: $colorHex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContentCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, color, colorHex);

  /// Create a copy of ContentCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContentCategoryImplCopyWith<_$ContentCategoryImpl> get copyWith =>
      __$$ContentCategoryImplCopyWithImpl<_$ContentCategoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContentCategoryImplToJson(
      this,
    );
  }
}

abstract class _ContentCategory implements ContentCategory {
  const factory _ContentCategory(
      {final String id,
      required final String name,
      @JsonKey(ignore: true) final Color? color,
      final String? colorHex}) = _$ContentCategoryImpl;

  factory _ContentCategory.fromJson(Map<String, dynamic> json) =
      _$ContentCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  Color? get color;
  @override
  String? get colorHex;

  /// Create a copy of ContentCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContentCategoryImplCopyWith<_$ContentCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
