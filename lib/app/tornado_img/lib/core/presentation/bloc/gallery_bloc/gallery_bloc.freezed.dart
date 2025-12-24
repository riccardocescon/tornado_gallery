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

 GalleryImage get image; String get password; String? get path;
/// Create a copy of GalleryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GalleryEventCopyWith<GalleryEvent> get copyWith => _$GalleryEventCopyWithImpl<GalleryEvent>(this as GalleryEvent, _$identity);







}

/// @nodoc
abstract mixin class $GalleryEventCopyWith<$Res>  {
  factory $GalleryEventCopyWith(GalleryEvent value, $Res Function(GalleryEvent) _then) = _$GalleryEventCopyWithImpl;
@useResult
$Res call({
 GalleryImage image, String password, String? path
});




}
/// @nodoc
class _$GalleryEventCopyWithImpl<$Res>
    implements $GalleryEventCopyWith<$Res> {
  _$GalleryEventCopyWithImpl(this._self, this._then);

  final GalleryEvent _self;
  final $Res Function(GalleryEvent) _then;

/// Create a copy of GalleryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? image = null,Object? password = null,Object? path = freezed,}) {
  return _then(_self.copyWith(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as GalleryImage,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _EncryptImage value)?  encryptImage,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncryptImage() when encryptImage != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _EncryptImage value)  encryptImage,}){
final _that = this;
switch (_that) {
case _EncryptImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _EncryptImage value)?  encryptImage,}){
final _that = this;
switch (_that) {
case _EncryptImage() when encryptImage != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( GalleryImage image,  String password,  String? path)?  encryptImage,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncryptImage() when encryptImage != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( GalleryImage image,  String password,  String? path)  encryptImage,}) {final _that = this;
switch (_that) {
case _EncryptImage():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( GalleryImage image,  String password,  String? path)?  encryptImage,}) {final _that = this;
switch (_that) {
case _EncryptImage() when encryptImage != null:
return encryptImage(_that.image,_that.password,_that.path);case _:
  return null;

}
}

}

/// @nodoc


class _EncryptImage extends GalleryEvent {
  const _EncryptImage({required this.image, required this.password, required this.path}): super._();
  

@override final  GalleryImage image;
@override final  String password;
@override final  String? path;

/// Create a copy of GalleryEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncryptImageCopyWith<_EncryptImage> get copyWith => __$EncryptImageCopyWithImpl<_EncryptImage>(this, _$identity);







}

/// @nodoc
abstract mixin class _$EncryptImageCopyWith<$Res> implements $GalleryEventCopyWith<$Res> {
  factory _$EncryptImageCopyWith(_EncryptImage value, $Res Function(_EncryptImage) _then) = __$EncryptImageCopyWithImpl;
@override @useResult
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
@override @pragma('vm:prefer-inline') $Res call({Object? image = null,Object? password = null,Object? path = freezed,}) {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Encrypted value)?  encrypted,TResult Function( _Failure value)?  encryptionFailure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Encrypted() when encrypted != null:
return encrypted(_that);case _Failure() when encryptionFailure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Encrypted value)  encrypted,required TResult Function( _Failure value)  encryptionFailure,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Encrypted():
return encrypted(_that);case _Failure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Encrypted value)?  encrypted,TResult? Function( _Failure value)?  encryptionFailure,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Encrypted() when encrypted != null:
return encrypted(_that);case _Failure() when encryptionFailure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  encrypted,TResult Function( EncryptionFailure failure)?  encryptionFailure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Encrypted() when encrypted != null:
return encrypted();case _Failure() when encryptionFailure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  encrypted,required TResult Function( EncryptionFailure failure)  encryptionFailure,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Encrypted():
return encrypted();case _Failure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  encrypted,TResult? Function( EncryptionFailure failure)?  encryptionFailure,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Encrypted() when encrypted != null:
return encrypted();case _Failure() when encryptionFailure != null:
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


class _Encrypted extends GalleryState {
  const _Encrypted(): super._();
  










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
