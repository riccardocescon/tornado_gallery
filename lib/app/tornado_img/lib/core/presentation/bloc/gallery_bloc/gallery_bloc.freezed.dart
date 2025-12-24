// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GalleryEvent {









}

/// @nodoc
class $GalleryEventCopyWith<$Res>  {
$GalleryEventCopyWith(GalleryEvent _, $Res Function(GalleryEvent) __);
}


/// Adds pattern-matching-related methods to [GalleryEvent].
extension GalleryEventPatterns on GalleryEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Setup value)?  setup,TResult Function( _LoadNextPage value)?  loadNextPage,TResult Function( _PickFiles value)?  pickFiles,TResult Function( _DeleteImage value)?  deleteImage,TResult Function( _EncryptImage value)?  encryptImage,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _LoadNextPage() when loadNextPage != null:
return loadNextPage(_that);case _PickFiles() when pickFiles != null:
return pickFiles(_that);case _DeleteImage() when deleteImage != null:
return deleteImage(_that);case _EncryptImage() when encryptImage != null:
return encryptImage(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Setup value)  setup,required TResult Function( _LoadNextPage value)  loadNextPage,required TResult Function( _PickFiles value)  pickFiles,required TResult Function( _DeleteImage value)  deleteImage,required TResult Function( _EncryptImage value)  encryptImage,}){
final _that = this;
switch (_that) {
case _Setup():
return setup(_that);case _LoadNextPage():
return loadNextPage(_that);case _PickFiles():
return pickFiles(_that);case _DeleteImage():
return deleteImage(_that);case _EncryptImage():
return encryptImage(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Setup value)?  setup,TResult? Function( _LoadNextPage value)?  loadNextPage,TResult? Function( _PickFiles value)?  pickFiles,TResult? Function( _DeleteImage value)?  deleteImage,TResult? Function( _EncryptImage value)?  encryptImage,}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _LoadNextPage() when loadNextPage != null:
return loadNextPage(_that);case _PickFiles() when pickFiles != null:
return pickFiles(_that);case _DeleteImage() when deleteImage != null:
return deleteImage(_that);case _EncryptImage() when encryptImage != null:
return encryptImage(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  setup,TResult Function()?  loadNextPage,TResult Function()?  pickFiles,TResult Function( GalleryImage image)?  deleteImage,TResult Function( GalleryImage image,  String password,  String? path)?  encryptImage,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup();case _LoadNextPage() when loadNextPage != null:
return loadNextPage();case _PickFiles() when pickFiles != null:
return pickFiles();case _DeleteImage() when deleteImage != null:
return deleteImage(_that.image);case _EncryptImage() when encryptImage != null:
return encryptImage(_that.image,_that.password,_that.path);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  setup,required TResult Function()  loadNextPage,required TResult Function()  pickFiles,required TResult Function( GalleryImage image)  deleteImage,required TResult Function( GalleryImage image,  String password,  String? path)  encryptImage,}) {final _that = this;
switch (_that) {
case _Setup():
return setup();case _LoadNextPage():
return loadNextPage();case _PickFiles():
return pickFiles();case _DeleteImage():
return deleteImage(_that.image);case _EncryptImage():
return encryptImage(_that.image,_that.password,_that.path);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  setup,TResult? Function()?  loadNextPage,TResult? Function()?  pickFiles,TResult? Function( GalleryImage image)?  deleteImage,TResult? Function( GalleryImage image,  String password,  String? path)?  encryptImage,}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup();case _LoadNextPage() when loadNextPage != null:
return loadNextPage();case _PickFiles() when pickFiles != null:
return pickFiles();case _DeleteImage() when deleteImage != null:
return deleteImage(_that.image);case _EncryptImage() when encryptImage != null:
return encryptImage(_that.image,_that.password,_that.path);case _:
  return null;

}
}

}

/// @nodoc


class _Setup extends GalleryEvent {
  const _Setup(): super._();
  










}




/// @nodoc


class _LoadNextPage extends GalleryEvent {
  const _LoadNextPage(): super._();
  










}




/// @nodoc


class _PickFiles extends GalleryEvent {
  const _PickFiles(): super._();
  










}




/// @nodoc


class _DeleteImage extends GalleryEvent {
  const _DeleteImage({required this.image}): super._();
  

 final  GalleryImage image;

/// Create a copy of GalleryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteImageCopyWith<_DeleteImage> get copyWith => __$DeleteImageCopyWithImpl<_DeleteImage>(this, _$identity);







}

/// @nodoc
abstract mixin class _$DeleteImageCopyWith<$Res> implements $GalleryEventCopyWith<$Res> {
  factory _$DeleteImageCopyWith(_DeleteImage value, $Res Function(_DeleteImage) _then) = __$DeleteImageCopyWithImpl;
@useResult
$Res call({
 GalleryImage image
});




}
/// @nodoc
class __$DeleteImageCopyWithImpl<$Res>
    implements _$DeleteImageCopyWith<$Res> {
  __$DeleteImageCopyWithImpl(this._self, this._then);

  final _DeleteImage _self;
  final $Res Function(_DeleteImage) _then;

/// Create a copy of GalleryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? image = null,}) {
  return _then(_DeleteImage(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as GalleryImage,
  ));
}


}

/// @nodoc


class _EncryptImage extends GalleryEvent {
  const _EncryptImage({required this.image, required this.password, required this.path}): super._();
  

 final  GalleryImage image;
 final  String password;
 final  String? path;

/// Create a copy of GalleryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncryptImageCopyWith<_EncryptImage> get copyWith => __$EncryptImageCopyWithImpl<_EncryptImage>(this, _$identity);







}

/// @nodoc
abstract mixin class _$EncryptImageCopyWith<$Res> implements $GalleryEventCopyWith<$Res> {
  factory _$EncryptImageCopyWith(_EncryptImage value, $Res Function(_EncryptImage) _then) = __$EncryptImageCopyWithImpl;
@useResult
$Res call({
 GalleryImage image, String password, String? path
});




}
/// @nodoc
class __$EncryptImageCopyWithImpl<$Res>
    implements _$EncryptImageCopyWith<$Res> {
  __$EncryptImageCopyWithImpl(this._self, this._then);

  final _EncryptImage _self;
  final $Res Function(_EncryptImage) _then;

/// Create a copy of GalleryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? image = null,Object? password = null,Object? path = freezed,}) {
  return _then(_EncryptImage(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as GalleryImage,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$GalleryState {









}

/// @nodoc
class $GalleryStateCopyWith<$Res>  {
$GalleryStateCopyWith(GalleryState _, $Res Function(GalleryState) __);
}


/// Adds pattern-matching-related methods to [GalleryState].
extension GalleryStatePatterns on GalleryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Encrypted value)?  encrypted,TResult Function( _PermissionDenied value)?  permissionDenied,TResult Function( _Failure value)?  encryptionFailure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Encrypted() when encrypted != null:
return encrypted(_that);case _PermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case _Failure() when encryptionFailure != null:
return encryptionFailure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Encrypted value)  encrypted,required TResult Function( _PermissionDenied value)  permissionDenied,required TResult Function( _Failure value)  encryptionFailure,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Encrypted():
return encrypted(_that);case _PermissionDenied():
return permissionDenied(_that);case _Failure():
return encryptionFailure(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Encrypted value)?  encrypted,TResult? Function( _PermissionDenied value)?  permissionDenied,TResult? Function( _Failure value)?  encryptionFailure,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Encrypted() when encrypted != null:
return encrypted(_that);case _PermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case _Failure() when encryptionFailure != null:
return encryptionFailure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<GalleryImage> images,  bool isLoading,  bool hasMore)?  loaded,TResult Function()?  encrypted,TResult Function()?  permissionDenied,TResult Function( EncryptionFailure failure)?  encryptionFailure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.images,_that.isLoading,_that.hasMore);case _Encrypted() when encrypted != null:
return encrypted();case _PermissionDenied() when permissionDenied != null:
return permissionDenied();case _Failure() when encryptionFailure != null:
return encryptionFailure(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<GalleryImage> images,  bool isLoading,  bool hasMore)  loaded,required TResult Function()  encrypted,required TResult Function()  permissionDenied,required TResult Function( EncryptionFailure failure)  encryptionFailure,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.images,_that.isLoading,_that.hasMore);case _Encrypted():
return encrypted();case _PermissionDenied():
return permissionDenied();case _Failure():
return encryptionFailure(_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<GalleryImage> images,  bool isLoading,  bool hasMore)?  loaded,TResult? Function()?  encrypted,TResult? Function()?  permissionDenied,TResult? Function( EncryptionFailure failure)?  encryptionFailure,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.images,_that.isLoading,_that.hasMore);case _Encrypted() when encrypted != null:
return encrypted();case _PermissionDenied() when permissionDenied != null:
return permissionDenied();case _Failure() when encryptionFailure != null:
return encryptionFailure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _Initial extends GalleryState {
  const _Initial(): super._();
  










}




/// @nodoc


class _Loading extends GalleryState {
  const _Loading(): super._();
  










}




/// @nodoc


class _Loaded extends GalleryState {
  const _Loaded({required final  List<GalleryImage> images, required this.isLoading, required this.hasMore}): _images = images,super._();
  

 final  List<GalleryImage> _images;
 List<GalleryImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

 final  bool isLoading;
 final  bool hasMore;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);







}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $GalleryStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<GalleryImage> images, bool isLoading, bool hasMore
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? images = null,Object? isLoading = null,Object? hasMore = null,}) {
  return _then(_Loaded(
images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<GalleryImage>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _Encrypted extends GalleryState {
  const _Encrypted(): super._();
  










}




/// @nodoc


class _PermissionDenied extends GalleryState {
  const _PermissionDenied(): super._();
  










}




/// @nodoc


class _Failure extends GalleryState {
  const _Failure({required this.failure}): super._();
  

 final  EncryptionFailure failure;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailureCopyWith<_Failure> get copyWith => __$FailureCopyWithImpl<_Failure>(this, _$identity);







}

/// @nodoc
abstract mixin class _$FailureCopyWith<$Res> implements $GalleryStateCopyWith<$Res> {
  factory _$FailureCopyWith(_Failure value, $Res Function(_Failure) _then) = __$FailureCopyWithImpl;
@useResult
$Res call({
 EncryptionFailure failure
});




}
/// @nodoc
class __$FailureCopyWithImpl<$Res>
    implements _$FailureCopyWith<$Res> {
  __$FailureCopyWithImpl(this._self, this._then);

  final _Failure _self;
  final $Res Function(_Failure) _then;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(_Failure(
failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as EncryptionFailure,
  ));
}


}

// dart format on
