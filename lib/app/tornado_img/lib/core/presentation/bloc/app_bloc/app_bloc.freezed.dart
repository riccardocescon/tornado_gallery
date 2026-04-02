// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppEvent {









}

/// @nodoc
class $AppEventCopyWith<$Res>  {
$AppEventCopyWith(AppEvent _, $Res Function(AppEvent) __);
}


/// Adds pattern-matching-related methods to [AppEvent].
extension AppEventPatterns on AppEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _AddEncryptedImage value)?  addEncryptedImage,TResult Function( _RemoveEncryptedImage value)?  removeEncryptedImage,TResult Function( _SetDecryptedInfo value)?  setDecryptedInfo,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddEncryptedImage() when addEncryptedImage != null:
return addEncryptedImage(_that);case _RemoveEncryptedImage() when removeEncryptedImage != null:
return removeEncryptedImage(_that);case _SetDecryptedInfo() when setDecryptedInfo != null:
return setDecryptedInfo(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _AddEncryptedImage value)  addEncryptedImage,required TResult Function( _RemoveEncryptedImage value)  removeEncryptedImage,required TResult Function( _SetDecryptedInfo value)  setDecryptedInfo,}){
final _that = this;
switch (_that) {
case _AddEncryptedImage():
return addEncryptedImage(_that);case _RemoveEncryptedImage():
return removeEncryptedImage(_that);case _SetDecryptedInfo():
return setDecryptedInfo(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _AddEncryptedImage value)?  addEncryptedImage,TResult? Function( _RemoveEncryptedImage value)?  removeEncryptedImage,TResult? Function( _SetDecryptedInfo value)?  setDecryptedInfo,}){
final _that = this;
switch (_that) {
case _AddEncryptedImage() when addEncryptedImage != null:
return addEncryptedImage(_that);case _RemoveEncryptedImage() when removeEncryptedImage != null:
return removeEncryptedImage(_that);case _SetDecryptedInfo() when setDecryptedInfo != null:
return setDecryptedInfo(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( EncryptedImage image)?  addEncryptedImage,TResult Function( String path)?  removeEncryptedImage,TResult Function( String path,  BytesInfo decryptedInfo)?  setDecryptedInfo,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddEncryptedImage() when addEncryptedImage != null:
return addEncryptedImage(_that.image);case _RemoveEncryptedImage() when removeEncryptedImage != null:
return removeEncryptedImage(_that.path);case _SetDecryptedInfo() when setDecryptedInfo != null:
return setDecryptedInfo(_that.path,_that.decryptedInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( EncryptedImage image)  addEncryptedImage,required TResult Function( String path)  removeEncryptedImage,required TResult Function( String path,  BytesInfo decryptedInfo)  setDecryptedInfo,}) {final _that = this;
switch (_that) {
case _AddEncryptedImage():
return addEncryptedImage(_that.image);case _RemoveEncryptedImage():
return removeEncryptedImage(_that.path);case _SetDecryptedInfo():
return setDecryptedInfo(_that.path,_that.decryptedInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( EncryptedImage image)?  addEncryptedImage,TResult? Function( String path)?  removeEncryptedImage,TResult? Function( String path,  BytesInfo decryptedInfo)?  setDecryptedInfo,}) {final _that = this;
switch (_that) {
case _AddEncryptedImage() when addEncryptedImage != null:
return addEncryptedImage(_that.image);case _RemoveEncryptedImage() when removeEncryptedImage != null:
return removeEncryptedImage(_that.path);case _SetDecryptedInfo() when setDecryptedInfo != null:
return setDecryptedInfo(_that.path,_that.decryptedInfo);case _:
  return null;

}
}

}

/// @nodoc


class _AddEncryptedImage extends AppEvent {
  const _AddEncryptedImage({required this.image}): super._();
  

 final  EncryptedImage image;

/// Create a copy of AppEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddEncryptedImageCopyWith<_AddEncryptedImage> get copyWith => __$AddEncryptedImageCopyWithImpl<_AddEncryptedImage>(this, _$identity);







}

/// @nodoc
abstract mixin class _$AddEncryptedImageCopyWith<$Res> implements $AppEventCopyWith<$Res> {
  factory _$AddEncryptedImageCopyWith(_AddEncryptedImage value, $Res Function(_AddEncryptedImage) _then) = __$AddEncryptedImageCopyWithImpl;
@useResult
$Res call({
 EncryptedImage image
});




}
/// @nodoc
class __$AddEncryptedImageCopyWithImpl<$Res>
    implements _$AddEncryptedImageCopyWith<$Res> {
  __$AddEncryptedImageCopyWithImpl(this._self, this._then);

  final _AddEncryptedImage _self;
  final $Res Function(_AddEncryptedImage) _then;

/// Create a copy of AppEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? image = null,}) {
  return _then(_AddEncryptedImage(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as EncryptedImage,
  ));
}


}

/// @nodoc


class _RemoveEncryptedImage extends AppEvent {
  const _RemoveEncryptedImage({required this.path}): super._();
  

 final  String path;

/// Create a copy of AppEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoveEncryptedImageCopyWith<_RemoveEncryptedImage> get copyWith => __$RemoveEncryptedImageCopyWithImpl<_RemoveEncryptedImage>(this, _$identity);







}

/// @nodoc
abstract mixin class _$RemoveEncryptedImageCopyWith<$Res> implements $AppEventCopyWith<$Res> {
  factory _$RemoveEncryptedImageCopyWith(_RemoveEncryptedImage value, $Res Function(_RemoveEncryptedImage) _then) = __$RemoveEncryptedImageCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class __$RemoveEncryptedImageCopyWithImpl<$Res>
    implements _$RemoveEncryptedImageCopyWith<$Res> {
  __$RemoveEncryptedImageCopyWithImpl(this._self, this._then);

  final _RemoveEncryptedImage _self;
  final $Res Function(_RemoveEncryptedImage) _then;

/// Create a copy of AppEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(_RemoveEncryptedImage(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _SetDecryptedInfo extends AppEvent {
  const _SetDecryptedInfo({required this.path, required this.decryptedInfo}): super._();
  

 final  String path;
 final  BytesInfo decryptedInfo;

/// Create a copy of AppEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetDecryptedInfoCopyWith<_SetDecryptedInfo> get copyWith => __$SetDecryptedInfoCopyWithImpl<_SetDecryptedInfo>(this, _$identity);







}

/// @nodoc
abstract mixin class _$SetDecryptedInfoCopyWith<$Res> implements $AppEventCopyWith<$Res> {
  factory _$SetDecryptedInfoCopyWith(_SetDecryptedInfo value, $Res Function(_SetDecryptedInfo) _then) = __$SetDecryptedInfoCopyWithImpl;
@useResult
$Res call({
 String path, BytesInfo decryptedInfo
});




}
/// @nodoc
class __$SetDecryptedInfoCopyWithImpl<$Res>
    implements _$SetDecryptedInfoCopyWith<$Res> {
  __$SetDecryptedInfoCopyWithImpl(this._self, this._then);

  final _SetDecryptedInfo _self;
  final $Res Function(_SetDecryptedInfo) _then;

/// Create a copy of AppEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,Object? decryptedInfo = null,}) {
  return _then(_SetDecryptedInfo(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,decryptedInfo: null == decryptedInfo ? _self.decryptedInfo : decryptedInfo // ignore: cast_nullable_to_non_nullable
as BytesInfo,
  ));
}


}

/// @nodoc
mixin _$AppState {









}

/// @nodoc
class $AppStateCopyWith<$Res>  {
$AppStateCopyWith(AppState _, $Res Function(AppState) __);
}


/// Adds pattern-matching-related methods to [AppState].
extension AppStatePatterns on AppState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Added value)?  addedGalleryImage,TResult Function( _Updated value)?  updatedGalleryImage,TResult Function( _Removed value)?  removedGalleryImage,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Added() when addedGalleryImage != null:
return addedGalleryImage(_that);case _Updated() when updatedGalleryImage != null:
return updatedGalleryImage(_that);case _Removed() when removedGalleryImage != null:
return removedGalleryImage(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Added value)  addedGalleryImage,required TResult Function( _Updated value)  updatedGalleryImage,required TResult Function( _Removed value)  removedGalleryImage,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Added():
return addedGalleryImage(_that);case _Updated():
return updatedGalleryImage(_that);case _Removed():
return removedGalleryImage(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Added value)?  addedGalleryImage,TResult? Function( _Updated value)?  updatedGalleryImage,TResult? Function( _Removed value)?  removedGalleryImage,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Added() when addedGalleryImage != null:
return addedGalleryImage(_that);case _Updated() when updatedGalleryImage != null:
return updatedGalleryImage(_that);case _Removed() when removedGalleryImage != null:
return removedGalleryImage(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( EncryptedImage image)?  addedGalleryImage,TResult Function( EncryptedImage image)?  updatedGalleryImage,TResult Function( String path)?  removedGalleryImage,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Added() when addedGalleryImage != null:
return addedGalleryImage(_that.image);case _Updated() when updatedGalleryImage != null:
return updatedGalleryImage(_that.image);case _Removed() when removedGalleryImage != null:
return removedGalleryImage(_that.path);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( EncryptedImage image)  addedGalleryImage,required TResult Function( EncryptedImage image)  updatedGalleryImage,required TResult Function( String path)  removedGalleryImage,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Added():
return addedGalleryImage(_that.image);case _Updated():
return updatedGalleryImage(_that.image);case _Removed():
return removedGalleryImage(_that.path);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( EncryptedImage image)?  addedGalleryImage,TResult? Function( EncryptedImage image)?  updatedGalleryImage,TResult? Function( String path)?  removedGalleryImage,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Added() when addedGalleryImage != null:
return addedGalleryImage(_that.image);case _Updated() when updatedGalleryImage != null:
return updatedGalleryImage(_that.image);case _Removed() when removedGalleryImage != null:
return removedGalleryImage(_that.path);case _:
  return null;

}
}

}

/// @nodoc


class _Initial extends AppState {
  const _Initial(): super._();
  










}




/// @nodoc


class _Added extends AppState {
  const _Added({required this.image}): super._();
  

 final  EncryptedImage image;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddedCopyWith<_Added> get copyWith => __$AddedCopyWithImpl<_Added>(this, _$identity);







}

/// @nodoc
abstract mixin class _$AddedCopyWith<$Res> implements $AppStateCopyWith<$Res> {
  factory _$AddedCopyWith(_Added value, $Res Function(_Added) _then) = __$AddedCopyWithImpl;
@useResult
$Res call({
 EncryptedImage image
});




}
/// @nodoc
class __$AddedCopyWithImpl<$Res>
    implements _$AddedCopyWith<$Res> {
  __$AddedCopyWithImpl(this._self, this._then);

  final _Added _self;
  final $Res Function(_Added) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? image = null,}) {
  return _then(_Added(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as EncryptedImage,
  ));
}


}

/// @nodoc


class _Updated extends AppState {
  const _Updated({required this.image}): super._();
  

 final  EncryptedImage image;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatedCopyWith<_Updated> get copyWith => __$UpdatedCopyWithImpl<_Updated>(this, _$identity);







}

/// @nodoc
abstract mixin class _$UpdatedCopyWith<$Res> implements $AppStateCopyWith<$Res> {
  factory _$UpdatedCopyWith(_Updated value, $Res Function(_Updated) _then) = __$UpdatedCopyWithImpl;
@useResult
$Res call({
 EncryptedImage image
});




}
/// @nodoc
class __$UpdatedCopyWithImpl<$Res>
    implements _$UpdatedCopyWith<$Res> {
  __$UpdatedCopyWithImpl(this._self, this._then);

  final _Updated _self;
  final $Res Function(_Updated) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? image = null,}) {
  return _then(_Updated(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as EncryptedImage,
  ));
}


}

/// @nodoc


class _Removed extends AppState {
  const _Removed({required this.path}): super._();
  

 final  String path;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemovedCopyWith<_Removed> get copyWith => __$RemovedCopyWithImpl<_Removed>(this, _$identity);







}

/// @nodoc
abstract mixin class _$RemovedCopyWith<$Res> implements $AppStateCopyWith<$Res> {
  factory _$RemovedCopyWith(_Removed value, $Res Function(_Removed) _then) = __$RemovedCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class __$RemovedCopyWithImpl<$Res>
    implements _$RemovedCopyWith<$Res> {
  __$RemovedCopyWithImpl(this._self, this._then);

  final _Removed _self;
  final $Res Function(_Removed) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(_Removed(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
