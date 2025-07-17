// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutorial_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Tutorial _$TutorialFromJson(Map<String, dynamic> json) {
  return _Tutorial.fromJson(json);
}

/// @nodoc
mixin _$Tutorial {
  /// ID do tutorial
  String get id => throw _privateConstructorUsedError;

  /// Título do tutorial
  String get title => throw _privateConstructorUsedError;

  /// Descrição do tutorial
  String? get description => throw _privateConstructorUsedError;

  /// Conteúdo principal do tutorial
  String get content => throw _privateConstructorUsedError;

  /// URL da imagem do tutorial
  String? get imageUrl => throw _privateConstructorUsedError;

  /// URL do vídeo do tutorial
  String? get videoUrl => throw _privateConstructorUsedError;

  /// Categoria do tutorial
  String get category => throw _privateConstructorUsedError;

  /// Índice para ordenação
  int get order => throw _privateConstructorUsedError;

  /// Indica se o tutorial está ativo
  bool get isActive => throw _privateConstructorUsedError;

  /// Indica se o tutorial está em destaque
  bool get isFeatured => throw _privateConstructorUsedError;

  /// ID do usuário que atualizou o tutorial
  String? get updatedBy => throw _privateConstructorUsedError;

  /// Data da última atualização
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Conteúdo relacionado (outros tutoriais, FAQs, etc.)
  Map<String, dynamic> get relatedContent => throw _privateConstructorUsedError;

  /// Serializes this Tutorial to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Tutorial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorialCopyWith<Tutorial> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorialCopyWith<$Res> {
  factory $TutorialCopyWith(Tutorial value, $Res Function(Tutorial) then) =
      _$TutorialCopyWithImpl<$Res, Tutorial>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String content,
      String? imageUrl,
      String? videoUrl,
      String category,
      int order,
      bool isActive,
      bool isFeatured,
      String? updatedBy,
      DateTime? lastUpdated,
      Map<String, dynamic> relatedContent});
}

/// @nodoc
class _$TutorialCopyWithImpl<$Res, $Val extends Tutorial>
    implements $TutorialCopyWith<$Res> {
  _$TutorialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tutorial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? content = null,
    Object? imageUrl = freezed,
    Object? videoUrl = freezed,
    Object? category = null,
    Object? order = null,
    Object? isActive = null,
    Object? isFeatured = null,
    Object? updatedBy = freezed,
    Object? lastUpdated = freezed,
    Object? relatedContent = null,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      relatedContent: null == relatedContent
          ? _value.relatedContent
          : relatedContent // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorialImplCopyWith<$Res>
    implements $TutorialCopyWith<$Res> {
  factory _$$TutorialImplCopyWith(
          _$TutorialImpl value, $Res Function(_$TutorialImpl) then) =
      __$$TutorialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String content,
      String? imageUrl,
      String? videoUrl,
      String category,
      int order,
      bool isActive,
      bool isFeatured,
      String? updatedBy,
      DateTime? lastUpdated,
      Map<String, dynamic> relatedContent});
}

/// @nodoc
class __$$TutorialImplCopyWithImpl<$Res>
    extends _$TutorialCopyWithImpl<$Res, _$TutorialImpl>
    implements _$$TutorialImplCopyWith<$Res> {
  __$$TutorialImplCopyWithImpl(
      _$TutorialImpl _value, $Res Function(_$TutorialImpl) _then)
      : super(_value, _then);

  /// Create a copy of Tutorial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? content = null,
    Object? imageUrl = freezed,
    Object? videoUrl = freezed,
    Object? category = null,
    Object? order = null,
    Object? isActive = null,
    Object? isFeatured = null,
    Object? updatedBy = freezed,
    Object? lastUpdated = freezed,
    Object? relatedContent = null,
  }) {
    return _then(_$TutorialImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      relatedContent: null == relatedContent
          ? _value._relatedContent
          : relatedContent // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorialImpl implements _Tutorial {
  const _$TutorialImpl(
      {required this.id,
      required this.title,
      this.description,
      required this.content,
      this.imageUrl,
      this.videoUrl,
      this.category = '',
      this.order = 0,
      this.isActive = true,
      this.isFeatured = false,
      this.updatedBy,
      this.lastUpdated,
      final Map<String, dynamic> relatedContent = const {}})
      : _relatedContent = relatedContent;

  factory _$TutorialImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorialImplFromJson(json);

  /// ID do tutorial
  @override
  final String id;

  /// Título do tutorial
  @override
  final String title;

  /// Descrição do tutorial
  @override
  final String? description;

  /// Conteúdo principal do tutorial
  @override
  final String content;

  /// URL da imagem do tutorial
  @override
  final String? imageUrl;

  /// URL do vídeo do tutorial
  @override
  final String? videoUrl;

  /// Categoria do tutorial
  @override
  @JsonKey()
  final String category;

  /// Índice para ordenação
  @override
  @JsonKey()
  final int order;

  /// Indica se o tutorial está ativo
  @override
  @JsonKey()
  final bool isActive;

  /// Indica se o tutorial está em destaque
  @override
  @JsonKey()
  final bool isFeatured;

  /// ID do usuário que atualizou o tutorial
  @override
  final String? updatedBy;

  /// Data da última atualização
  @override
  final DateTime? lastUpdated;

  /// Conteúdo relacionado (outros tutoriais, FAQs, etc.)
  final Map<String, dynamic> _relatedContent;

  /// Conteúdo relacionado (outros tutoriais, FAQs, etc.)
  @override
  @JsonKey()
  Map<String, dynamic> get relatedContent {
    if (_relatedContent is EqualUnmodifiableMapView) return _relatedContent;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_relatedContent);
  }

  @override
  String toString() {
    return 'Tutorial(id: $id, title: $title, description: $description, content: $content, imageUrl: $imageUrl, videoUrl: $videoUrl, category: $category, order: $order, isActive: $isActive, isFeatured: $isFeatured, updatedBy: $updatedBy, lastUpdated: $lastUpdated, relatedContent: $relatedContent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorialImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            const DeepCollectionEquality()
                .equals(other._relatedContent, _relatedContent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      content,
      imageUrl,
      videoUrl,
      category,
      order,
      isActive,
      isFeatured,
      updatedBy,
      lastUpdated,
      const DeepCollectionEquality().hash(_relatedContent));

  /// Create a copy of Tutorial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorialImplCopyWith<_$TutorialImpl> get copyWith =>
      __$$TutorialImplCopyWithImpl<_$TutorialImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorialImplToJson(
      this,
    );
  }
}

abstract class _Tutorial implements Tutorial {
  const factory _Tutorial(
      {required final String id,
      required final String title,
      final String? description,
      required final String content,
      final String? imageUrl,
      final String? videoUrl,
      final String category,
      final int order,
      final bool isActive,
      final bool isFeatured,
      final String? updatedBy,
      final DateTime? lastUpdated,
      final Map<String, dynamic> relatedContent}) = _$TutorialImpl;

  factory _Tutorial.fromJson(Map<String, dynamic> json) =
      _$TutorialImpl.fromJson;

  /// ID do tutorial
  @override
  String get id;

  /// Título do tutorial
  @override
  String get title;

  /// Descrição do tutorial
  @override
  String? get description;

  /// Conteúdo principal do tutorial
  @override
  String get content;

  /// URL da imagem do tutorial
  @override
  String? get imageUrl;

  /// URL do vídeo do tutorial
  @override
  String? get videoUrl;

  /// Categoria do tutorial
  @override
  String get category;

  /// Índice para ordenação
  @override
  int get order;

  /// Indica se o tutorial está ativo
  @override
  bool get isActive;

  /// Indica se o tutorial está em destaque
  @override
  bool get isFeatured;

  /// ID do usuário que atualizou o tutorial
  @override
  String? get updatedBy;

  /// Data da última atualização
  @override
  DateTime? get lastUpdated;

  /// Conteúdo relacionado (outros tutoriais, FAQs, etc.)
  @override
  Map<String, dynamic> get relatedContent;

  /// Create a copy of Tutorial
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorialImplCopyWith<_$TutorialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
