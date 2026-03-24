// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'homepage_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomepageEvent {









}

/// @nodoc
class $HomepageEventCopyWith<$Res>  {
$HomepageEventCopyWith(HomepageEvent _, $Res Function(HomepageEvent) __);
}


/// Adds pattern-matching-related methods to [HomepageEvent].
extension HomepageEventPatterns on HomepageEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Setup value)?  setup,TResult Function( _GalleryAssetsSelected value)?  galleryAssetsSelected,TResult Function( _Refresh value)?  refresh,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _GalleryAssetsSelected() when galleryAssetsSelected != null:
return galleryAssetsSelected(_that);case _Refresh() when refresh != null:
return refresh(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Setup value)  setup,required TResult Function( _GalleryAssetsSelected value)  galleryAssetsSelected,required TResult Function( _Refresh value)  refresh,}){
final _that = this;
switch (_that) {
case _Setup():
return setup(_that);case _GalleryAssetsSelected():
return galleryAssetsSelected(_that);case _Refresh():
return refresh(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Setup value)?  setup,TResult? Function( _GalleryAssetsSelected value)?  galleryAssetsSelected,TResult? Function( _Refresh value)?  refresh,}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _GalleryAssetsSelected() when galleryAssetsSelected != null:
return galleryAssetsSelected(_that);case _Refresh() when refresh != null:
return refresh(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  setup,TResult Function( List<AssetEntity> imagesSelected)?  galleryAssetsSelected,TResult Function()?  refresh,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup();case _GalleryAssetsSelected() when galleryAssetsSelected != null:
return galleryAssetsSelected(_that.imagesSelected);case _Refresh() when refresh != null:
return refresh();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  setup,required TResult Function( List<AssetEntity> imagesSelected)  galleryAssetsSelected,required TResult Function()  refresh,}) {final _that = this;
switch (_that) {
case _Setup():
return setup();case _GalleryAssetsSelected():
return galleryAssetsSelected(_that.imagesSelected);case _Refresh():
return refresh();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  setup,TResult? Function( List<AssetEntity> imagesSelected)?  galleryAssetsSelected,TResult? Function()?  refresh,}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup();case _GalleryAssetsSelected() when galleryAssetsSelected != null:
return galleryAssetsSelected(_that.imagesSelected);case _Refresh() when refresh != null:
return refresh();case _:
  return null;

}
}

}

/// @nodoc


class _Setup extends HomepageEvent {
  const _Setup(): super._();
  










}




/// @nodoc


class _GalleryAssetsSelected extends HomepageEvent {
  const _GalleryAssetsSelected({required final  List<AssetEntity> imagesSelected}): _imagesSelected = imagesSelected,super._();
  

 final  List<AssetEntity> _imagesSelected;
 List<AssetEntity> get imagesSelected {
  if (_imagesSelected is EqualUnmodifiableListView) return _imagesSelected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagesSelected);
}


/// Create a copy of HomepageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryAssetsSelectedCopyWith<_GalleryAssetsSelected> get copyWith => __$GalleryAssetsSelectedCopyWithImpl<_GalleryAssetsSelected>(this, _$identity);







}

/// @nodoc
abstract mixin class _$GalleryAssetsSelectedCopyWith<$Res> implements $HomepageEventCopyWith<$Res> {
  factory _$GalleryAssetsSelectedCopyWith(_GalleryAssetsSelected value, $Res Function(_GalleryAssetsSelected) _then) = __$GalleryAssetsSelectedCopyWithImpl;
@useResult
$Res call({
 List<AssetEntity> imagesSelected
});




}
/// @nodoc
class __$GalleryAssetsSelectedCopyWithImpl<$Res>
    implements _$GalleryAssetsSelectedCopyWith<$Res> {
  __$GalleryAssetsSelectedCopyWithImpl(this._self, this._then);

  final _GalleryAssetsSelected _self;
  final $Res Function(_GalleryAssetsSelected) _then;

/// Create a copy of HomepageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? imagesSelected = null,}) {
  return _then(_GalleryAssetsSelected(
imagesSelected: null == imagesSelected ? _self._imagesSelected : imagesSelected // ignore: cast_nullable_to_non_nullable
as List<AssetEntity>,
  ));
}


}

/// @nodoc


class _Refresh extends HomepageEvent {
  const _Refresh(): super._();
  










}




/// @nodoc
mixin _$HomepageState {









}

/// @nodoc
class $HomepageStateCopyWith<$Res>  {
$HomepageStateCopyWith(HomepageState _, $Res Function(HomepageState) __);
}


/// Adds pattern-matching-related methods to [HomepageState].
extension HomepageStatePatterns on HomepageState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _GalleryLoading value)?  galleryLoading,TResult Function( _GalleryImages value)?  galleryImages,TResult Function( _GalleryStatus value)?  galleryStatus,TResult Function( _Loaded value)?  loaded,TResult Function( _Failure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _GalleryLoading() when galleryLoading != null:
return galleryLoading(_that);case _GalleryImages() when galleryImages != null:
return galleryImages(_that);case _GalleryStatus() when galleryStatus != null:
return galleryStatus(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Failure() when failure != null:
return failure(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _GalleryLoading value)  galleryLoading,required TResult Function( _GalleryImages value)  galleryImages,required TResult Function( _GalleryStatus value)  galleryStatus,required TResult Function( _Loaded value)  loaded,required TResult Function( _Failure value)  failure,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _GalleryLoading():
return galleryLoading(_that);case _GalleryImages():
return galleryImages(_that);case _GalleryStatus():
return galleryStatus(_that);case _Loaded():
return loaded(_that);case _Failure():
return failure(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _GalleryLoading value)?  galleryLoading,TResult? Function( _GalleryImages value)?  galleryImages,TResult? Function( _GalleryStatus value)?  galleryStatus,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Failure value)?  failure,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _GalleryLoading() when galleryLoading != null:
return galleryLoading(_that);case _GalleryImages() when galleryImages != null:
return galleryImages(_that);case _GalleryStatus() when galleryStatus != null:
return galleryStatus(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Failure() when failure != null:
return failure(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  galleryLoading,TResult Function( List<GalleryImage> imagesLoaded)?  galleryImages,TResult Function( int imagesLoaded,  int folderLoaded,  int bytesLoaded,  DateTime? lastLoaded)?  galleryStatus,TResult Function( List<GalleryImage>? images,  List<EncryptedEntity>? encryptedImages)?  loaded,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _GalleryLoading() when galleryLoading != null:
return galleryLoading();case _GalleryImages() when galleryImages != null:
return galleryImages(_that.imagesLoaded);case _GalleryStatus() when galleryStatus != null:
return galleryStatus(_that.imagesLoaded,_that.folderLoaded,_that.bytesLoaded,_that.lastLoaded);case _Loaded() when loaded != null:
return loaded(_that.images,_that.encryptedImages);case _Failure() when failure != null:
return failure(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  galleryLoading,required TResult Function( List<GalleryImage> imagesLoaded)  galleryImages,required TResult Function( int imagesLoaded,  int folderLoaded,  int bytesLoaded,  DateTime? lastLoaded)  galleryStatus,required TResult Function( List<GalleryImage>? images,  List<EncryptedEntity>? encryptedImages)  loaded,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _GalleryLoading():
return galleryLoading();case _GalleryImages():
return galleryImages(_that.imagesLoaded);case _GalleryStatus():
return galleryStatus(_that.imagesLoaded,_that.folderLoaded,_that.bytesLoaded,_that.lastLoaded);case _Loaded():
return loaded(_that.images,_that.encryptedImages);case _Failure():
return failure(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  galleryLoading,TResult? Function( List<GalleryImage> imagesLoaded)?  galleryImages,TResult? Function( int imagesLoaded,  int folderLoaded,  int bytesLoaded,  DateTime? lastLoaded)?  galleryStatus,TResult? Function( List<GalleryImage>? images,  List<EncryptedEntity>? encryptedImages)?  loaded,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _GalleryLoading() when galleryLoading != null:
return galleryLoading();case _GalleryImages() when galleryImages != null:
return galleryImages(_that.imagesLoaded);case _GalleryStatus() when galleryStatus != null:
return galleryStatus(_that.imagesLoaded,_that.folderLoaded,_that.bytesLoaded,_that.lastLoaded);case _Loaded() when loaded != null:
return loaded(_that.images,_that.encryptedImages);case _Failure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial extends HomepageState {
  const _Initial(): super._();
  










}




/// @nodoc


class _Loading extends HomepageState {
  const _Loading(): super._();
  










}




/// @nodoc


class _GalleryLoading extends HomepageState {
  const _GalleryLoading(): super._();
  










}




/// @nodoc


class _GalleryImages extends HomepageState {
  const _GalleryImages({required final  List<GalleryImage> imagesLoaded}): _imagesLoaded = imagesLoaded,super._();
  

 final  List<GalleryImage> _imagesLoaded;
 List<GalleryImage> get imagesLoaded {
  if (_imagesLoaded is EqualUnmodifiableListView) return _imagesLoaded;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagesLoaded);
}


/// Create a copy of HomepageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryImagesCopyWith<_GalleryImages> get copyWith => __$GalleryImagesCopyWithImpl<_GalleryImages>(this, _$identity);







}

/// @nodoc
abstract mixin class _$GalleryImagesCopyWith<$Res> implements $HomepageStateCopyWith<$Res> {
  factory _$GalleryImagesCopyWith(_GalleryImages value, $Res Function(_GalleryImages) _then) = __$GalleryImagesCopyWithImpl;
@useResult
$Res call({
 List<GalleryImage> imagesLoaded
});




}
/// @nodoc
class __$GalleryImagesCopyWithImpl<$Res>
    implements _$GalleryImagesCopyWith<$Res> {
  __$GalleryImagesCopyWithImpl(this._self, this._then);

  final _GalleryImages _self;
  final $Res Function(_GalleryImages) _then;

/// Create a copy of HomepageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? imagesLoaded = null,}) {
  return _then(_GalleryImages(
imagesLoaded: null == imagesLoaded ? _self._imagesLoaded : imagesLoaded // ignore: cast_nullable_to_non_nullable
as List<GalleryImage>,
  ));
}


}

/// @nodoc


class _GalleryStatus extends HomepageState {
  const _GalleryStatus({required this.imagesLoaded, required this.folderLoaded, required this.bytesLoaded, required this.lastLoaded}): super._();
  

 final  int imagesLoaded;
 final  int folderLoaded;
 final  int bytesLoaded;
 final  DateTime? lastLoaded;

/// Create a copy of HomepageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryStatusCopyWith<_GalleryStatus> get copyWith => __$GalleryStatusCopyWithImpl<_GalleryStatus>(this, _$identity);







}

/// @nodoc
abstract mixin class _$GalleryStatusCopyWith<$Res> implements $HomepageStateCopyWith<$Res> {
  factory _$GalleryStatusCopyWith(_GalleryStatus value, $Res Function(_GalleryStatus) _then) = __$GalleryStatusCopyWithImpl;
@useResult
$Res call({
 int imagesLoaded, int folderLoaded, int bytesLoaded, DateTime? lastLoaded
});




}
/// @nodoc
class __$GalleryStatusCopyWithImpl<$Res>
    implements _$GalleryStatusCopyWith<$Res> {
  __$GalleryStatusCopyWithImpl(this._self, this._then);

  final _GalleryStatus _self;
  final $Res Function(_GalleryStatus) _then;

/// Create a copy of HomepageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? imagesLoaded = null,Object? folderLoaded = null,Object? bytesLoaded = null,Object? lastLoaded = freezed,}) {
  return _then(_GalleryStatus(
imagesLoaded: null == imagesLoaded ? _self.imagesLoaded : imagesLoaded // ignore: cast_nullable_to_non_nullable
as int,folderLoaded: null == folderLoaded ? _self.folderLoaded : folderLoaded // ignore: cast_nullable_to_non_nullable
as int,bytesLoaded: null == bytesLoaded ? _self.bytesLoaded : bytesLoaded // ignore: cast_nullable_to_non_nullable
as int,lastLoaded: freezed == lastLoaded ? _self.lastLoaded : lastLoaded // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class _Loaded extends HomepageState {
  const _Loaded({required final  List<GalleryImage>? images, required final  List<EncryptedEntity>? encryptedImages}): _images = images,_encryptedImages = encryptedImages,super._();
  

 final  List<GalleryImage>? _images;
 List<GalleryImage>? get images {
  final value = _images;
  if (value == null) return null;
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<EncryptedEntity>? _encryptedImages;
 List<EncryptedEntity>? get encryptedImages {
  final value = _encryptedImages;
  if (value == null) return null;
  if (_encryptedImages is EqualUnmodifiableListView) return _encryptedImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of HomepageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);







}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $HomepageStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<GalleryImage>? images, List<EncryptedEntity>? encryptedImages
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of HomepageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? images = freezed,Object? encryptedImages = freezed,}) {
  return _then(_Loaded(
images: freezed == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<GalleryImage>?,encryptedImages: freezed == encryptedImages ? _self._encryptedImages : encryptedImages // ignore: cast_nullable_to_non_nullable
as List<EncryptedEntity>?,
  ));
}


}

/// @nodoc


class _Failure extends HomepageState {
  const _Failure({required this.message}): super._();
  

 final  String message;

/// Create a copy of HomepageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailureCopyWith<_Failure> get copyWith => __$FailureCopyWithImpl<_Failure>(this, _$identity);







}

/// @nodoc
abstract mixin class _$FailureCopyWith<$Res> implements $HomepageStateCopyWith<$Res> {
  factory _$FailureCopyWith(_Failure value, $Res Function(_Failure) _then) = __$FailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$FailureCopyWithImpl<$Res>
    implements _$FailureCopyWith<$Res> {
  __$FailureCopyWithImpl(this._self, this._then);

  final _Failure _self;
  final $Res Function(_Failure) _then;

/// Create a copy of HomepageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Failure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
