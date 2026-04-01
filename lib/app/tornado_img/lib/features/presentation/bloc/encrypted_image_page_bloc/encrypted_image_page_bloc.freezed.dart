// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encrypted_image_page_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EncryptedImagePageEvent {







@override
String toString() {
  return 'EncryptedImagePageEvent()';
}


}

/// @nodoc
class $EncryptedImagePageEventCopyWith<$Res>  {
$EncryptedImagePageEventCopyWith(EncryptedImagePageEvent _, $Res Function(EncryptedImagePageEvent) __);
}


/// Adds pattern-matching-related methods to [EncryptedImagePageEvent].
extension EncryptedImagePageEventPatterns on EncryptedImagePageEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Setup value)?  setup,TResult Function( _UpdatePassword value)?  updatePassword,TResult Function( _Decrypt value)?  decrypt,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _UpdatePassword() when updatePassword != null:
return updatePassword(_that);case _Decrypt() when decrypt != null:
return decrypt(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Setup value)  setup,required TResult Function( _UpdatePassword value)  updatePassword,required TResult Function( _Decrypt value)  decrypt,}){
final _that = this;
switch (_that) {
case _Setup():
return setup(_that);case _UpdatePassword():
return updatePassword(_that);case _Decrypt():
return decrypt(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Setup value)?  setup,TResult? Function( _UpdatePassword value)?  updatePassword,TResult? Function( _Decrypt value)?  decrypt,}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _UpdatePassword() when updatePassword != null:
return updatePassword(_that);case _Decrypt() when decrypt != null:
return decrypt(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String imagePath)?  setup,TResult Function( String password)?  updatePassword,TResult Function()?  decrypt,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that.imagePath);case _UpdatePassword() when updatePassword != null:
return updatePassword(_that.password);case _Decrypt() when decrypt != null:
return decrypt();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String imagePath)  setup,required TResult Function( String password)  updatePassword,required TResult Function()  decrypt,}) {final _that = this;
switch (_that) {
case _Setup():
return setup(_that.imagePath);case _UpdatePassword():
return updatePassword(_that.password);case _Decrypt():
return decrypt();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String imagePath)?  setup,TResult? Function( String password)?  updatePassword,TResult? Function()?  decrypt,}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that.imagePath);case _UpdatePassword() when updatePassword != null:
return updatePassword(_that.password);case _Decrypt() when decrypt != null:
return decrypt();case _:
  return null;

}
}

}

/// @nodoc


class _Setup extends EncryptedImagePageEvent {
  const _Setup({required this.imagePath}): super._();
  

 final  String imagePath;

/// Create a copy of EncryptedImagePageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupCopyWith<_Setup> get copyWith => __$SetupCopyWithImpl<_Setup>(this, _$identity);





@override
String toString() {
  return 'EncryptedImagePageEvent.setup(imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class _$SetupCopyWith<$Res> implements $EncryptedImagePageEventCopyWith<$Res> {
  factory _$SetupCopyWith(_Setup value, $Res Function(_Setup) _then) = __$SetupCopyWithImpl;
@useResult
$Res call({
 String imagePath
});




}
/// @nodoc
class __$SetupCopyWithImpl<$Res>
    implements _$SetupCopyWith<$Res> {
  __$SetupCopyWithImpl(this._self, this._then);

  final _Setup _self;
  final $Res Function(_Setup) _then;

/// Create a copy of EncryptedImagePageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? imagePath = null,}) {
  return _then(_Setup(
imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _UpdatePassword extends EncryptedImagePageEvent {
  const _UpdatePassword(this.password): super._();
  

 final  String password;

/// Create a copy of EncryptedImagePageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePasswordCopyWith<_UpdatePassword> get copyWith => __$UpdatePasswordCopyWithImpl<_UpdatePassword>(this, _$identity);





@override
String toString() {
  return 'EncryptedImagePageEvent.updatePassword(password: $password)';
}


}

/// @nodoc
abstract mixin class _$UpdatePasswordCopyWith<$Res> implements $EncryptedImagePageEventCopyWith<$Res> {
  factory _$UpdatePasswordCopyWith(_UpdatePassword value, $Res Function(_UpdatePassword) _then) = __$UpdatePasswordCopyWithImpl;
@useResult
$Res call({
 String password
});




}
/// @nodoc
class __$UpdatePasswordCopyWithImpl<$Res>
    implements _$UpdatePasswordCopyWith<$Res> {
  __$UpdatePasswordCopyWithImpl(this._self, this._then);

  final _UpdatePassword _self;
  final $Res Function(_UpdatePassword) _then;

/// Create a copy of EncryptedImagePageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? password = null,}) {
  return _then(_UpdatePassword(
null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Decrypt extends EncryptedImagePageEvent {
  const _Decrypt(): super._();
  








@override
String toString() {
  return 'EncryptedImagePageEvent.decrypt()';
}


}




/// @nodoc
mixin _$EncryptedImagePageState {









}

/// @nodoc
class $EncryptedImagePageStateCopyWith<$Res>  {
$EncryptedImagePageStateCopyWith(EncryptedImagePageState _, $Res Function(EncryptedImagePageState) __);
}


/// Adds pattern-matching-related methods to [EncryptedImagePageState].
extension EncryptedImagePageStatePatterns on EncryptedImagePageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  ui,TResult Function( _Failure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when ui != null:
return ui(_that);case _Failure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  ui,required TResult Function( _Failure value)  failure,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return ui(_that);case _Failure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  ui,TResult? Function( _Failure value)?  failure,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when ui != null:
return ui(_that);case _Failure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( GalleryImage image)?  ui,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when ui != null:
return ui(_that.image);case _Failure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( GalleryImage image)  ui,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return ui(_that.image);case _Failure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( GalleryImage image)?  ui,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when ui != null:
return ui(_that.image);case _Failure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial extends EncryptedImagePageState {
  const _Initial(): super._();
  










}




/// @nodoc


class _Loading extends EncryptedImagePageState {
  const _Loading(): super._();
  










}




/// @nodoc


class _Loaded extends EncryptedImagePageState {
  const _Loaded({required this.image}): super._();
  

 final  GalleryImage image;

/// Create a copy of EncryptedImagePageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);







}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $EncryptedImagePageStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 GalleryImage image
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of EncryptedImagePageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? image = null,}) {
  return _then(_Loaded(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as GalleryImage,
  ));
}


}

/// @nodoc


class _Failure extends EncryptedImagePageState {
  const _Failure({required this.message}): super._();
  

 final  String message;

/// Create a copy of EncryptedImagePageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailureCopyWith<_Failure> get copyWith => __$FailureCopyWithImpl<_Failure>(this, _$identity);







}

/// @nodoc
abstract mixin class _$FailureCopyWith<$Res> implements $EncryptedImagePageStateCopyWith<$Res> {
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

/// Create a copy of EncryptedImagePageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Failure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
