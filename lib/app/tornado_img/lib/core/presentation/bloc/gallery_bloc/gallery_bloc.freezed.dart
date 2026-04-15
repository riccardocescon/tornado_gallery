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

 String get password;
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
 String password
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
@pragma('vm:prefer-inline') @override $Res call({Object? password = null,}) {
  return _then(_self.copyWith(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _EncryptImage value)?  encryptImage,TResult Function( _EncryptImages value)?  encryptImages,TResult Function( _DecryptImage value)?  decryptImage,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncryptImage() when encryptImage != null:
return encryptImage(_that);case _EncryptImages() when encryptImages != null:
return encryptImages(_that);case _DecryptImage() when decryptImage != null:
return decryptImage(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _EncryptImage value)  encryptImage,required TResult Function( _EncryptImages value)  encryptImages,required TResult Function( _DecryptImage value)  decryptImage,}){
final _that = this;
switch (_that) {
case _EncryptImage():
return encryptImage(_that);case _EncryptImages():
return encryptImages(_that);case _DecryptImage():
return decryptImage(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _EncryptImage value)?  encryptImage,TResult? Function( _EncryptImages value)?  encryptImages,TResult? Function( _DecryptImage value)?  decryptImage,}){
final _that = this;
switch (_that) {
case _EncryptImage() when encryptImage != null:
return encryptImage(_that);case _EncryptImages() when encryptImages != null:
return encryptImages(_that);case _DecryptImage() when decryptImage != null:
return decryptImage(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( GalleryImage image,  String password,  EncryptionSettings settings)?  encryptImage,TResult Function( List<GalleryImage> images,  String password,  EncryptionSettings settings)?  encryptImages,TResult Function( EncryptedImage image,  String password)?  decryptImage,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncryptImage() when encryptImage != null:
return encryptImage(_that.image,_that.password,_that.settings);case _EncryptImages() when encryptImages != null:
return encryptImages(_that.images,_that.password,_that.settings);case _DecryptImage() when decryptImage != null:
return decryptImage(_that.image,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( GalleryImage image,  String password,  EncryptionSettings settings)  encryptImage,required TResult Function( List<GalleryImage> images,  String password,  EncryptionSettings settings)  encryptImages,required TResult Function( EncryptedImage image,  String password)  decryptImage,}) {final _that = this;
switch (_that) {
case _EncryptImage():
return encryptImage(_that.image,_that.password,_that.settings);case _EncryptImages():
return encryptImages(_that.images,_that.password,_that.settings);case _DecryptImage():
return decryptImage(_that.image,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( GalleryImage image,  String password,  EncryptionSettings settings)?  encryptImage,TResult? Function( List<GalleryImage> images,  String password,  EncryptionSettings settings)?  encryptImages,TResult? Function( EncryptedImage image,  String password)?  decryptImage,}) {final _that = this;
switch (_that) {
case _EncryptImage() when encryptImage != null:
return encryptImage(_that.image,_that.password,_that.settings);case _EncryptImages() when encryptImages != null:
return encryptImages(_that.images,_that.password,_that.settings);case _DecryptImage() when decryptImage != null:
return decryptImage(_that.image,_that.password);case _:
  return null;

}
}

}

/// @nodoc


class _EncryptImage extends GalleryEvent {
  const _EncryptImage({required this.image, required this.password, required this.settings}): super._();
  

 final  GalleryImage image;
@override final  String password;
 final  EncryptionSettings settings;

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
 GalleryImage image, String password, EncryptionSettings settings
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
@override @pragma('vm:prefer-inline') $Res call({Object? image = null,Object? password = null,Object? settings = null,}) {
  return _then(_EncryptImage(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as GalleryImage,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as EncryptionSettings,
  ));
}


}

/// @nodoc


class _EncryptImages extends GalleryEvent {
  const _EncryptImages({required final  List<GalleryImage> images, required this.password, required this.settings}): _images = images,super._();
  

 final  List<GalleryImage> _images;
 List<GalleryImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  String password;
 final  EncryptionSettings settings;

/// Create a copy of GalleryEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncryptImagesCopyWith<_EncryptImages> get copyWith => __$EncryptImagesCopyWithImpl<_EncryptImages>(this, _$identity);







}

/// @nodoc
abstract mixin class _$EncryptImagesCopyWith<$Res> implements $GalleryEventCopyWith<$Res> {
  factory _$EncryptImagesCopyWith(_EncryptImages value, $Res Function(_EncryptImages) _then) = __$EncryptImagesCopyWithImpl;
@override @useResult
$Res call({
 List<GalleryImage> images, String password, EncryptionSettings settings
});




}
/// @nodoc
class __$EncryptImagesCopyWithImpl<$Res>
    implements _$EncryptImagesCopyWith<$Res> {
  __$EncryptImagesCopyWithImpl(this._self, this._then);

  final _EncryptImages _self;
  final $Res Function(_EncryptImages) _then;

/// Create a copy of GalleryEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? images = null,Object? password = null,Object? settings = null,}) {
  return _then(_EncryptImages(
images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<GalleryImage>,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as EncryptionSettings,
  ));
}


}

/// @nodoc


class _DecryptImage extends GalleryEvent {
  const _DecryptImage({required this.image, required this.password}): super._();
  

 final  EncryptedImage image;
@override final  String password;

/// Create a copy of GalleryEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecryptImageCopyWith<_DecryptImage> get copyWith => __$DecryptImageCopyWithImpl<_DecryptImage>(this, _$identity);







}

/// @nodoc
abstract mixin class _$DecryptImageCopyWith<$Res> implements $GalleryEventCopyWith<$Res> {
  factory _$DecryptImageCopyWith(_DecryptImage value, $Res Function(_DecryptImage) _then) = __$DecryptImageCopyWithImpl;
@override @useResult
$Res call({
 EncryptedImage image, String password
});




}
/// @nodoc
class __$DecryptImageCopyWithImpl<$Res>
    implements _$DecryptImageCopyWith<$Res> {
  __$DecryptImageCopyWithImpl(this._self, this._then);

  final _DecryptImage _self;
  final $Res Function(_DecryptImage) _then;

/// Create a copy of GalleryEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? image = null,Object? password = null,}) {
  return _then(_DecryptImage(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as EncryptedImage,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _LoadingEncryption value)?  loadingEncryption,TResult Function( _LoadingDecryption value)?  loadingDecryption,TResult Function( _Encrypted value)?  encrypted,TResult Function( _Decrypted value)?  decrypted,TResult Function( _DecryptionFailure value)?  decryptionFailure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _LoadingEncryption() when loadingEncryption != null:
return loadingEncryption(_that);case _LoadingDecryption() when loadingDecryption != null:
return loadingDecryption(_that);case _Encrypted() when encrypted != null:
return encrypted(_that);case _Decrypted() when decrypted != null:
return decrypted(_that);case _DecryptionFailure() when decryptionFailure != null:
return decryptionFailure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _LoadingEncryption value)  loadingEncryption,required TResult Function( _LoadingDecryption value)  loadingDecryption,required TResult Function( _Encrypted value)  encrypted,required TResult Function( _Decrypted value)  decrypted,required TResult Function( _DecryptionFailure value)  decryptionFailure,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _LoadingEncryption():
return loadingEncryption(_that);case _LoadingDecryption():
return loadingDecryption(_that);case _Encrypted():
return encrypted(_that);case _Decrypted():
return decrypted(_that);case _DecryptionFailure():
return decryptionFailure(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _LoadingEncryption value)?  loadingEncryption,TResult? Function( _LoadingDecryption value)?  loadingDecryption,TResult? Function( _Encrypted value)?  encrypted,TResult? Function( _Decrypted value)?  decrypted,TResult? Function( _DecryptionFailure value)?  decryptionFailure,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _LoadingEncryption() when loadingEncryption != null:
return loadingEncryption(_that);case _LoadingDecryption() when loadingDecryption != null:
return loadingDecryption(_that);case _Encrypted() when encrypted != null:
return encrypted(_that);case _Decrypted() when decrypted != null:
return decrypted(_that);case _DecryptionFailure() when decryptionFailure != null:
return decryptionFailure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( int total)?  loadingEncryption,TResult Function( int total)?  loadingDecryption,TResult Function( ArchivingState archivingState)?  encrypted,TResult Function( DearchivingState archivingState)?  decrypted,TResult Function( EncryptionFailure failure)?  decryptionFailure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _LoadingEncryption() when loadingEncryption != null:
return loadingEncryption(_that.total);case _LoadingDecryption() when loadingDecryption != null:
return loadingDecryption(_that.total);case _Encrypted() when encrypted != null:
return encrypted(_that.archivingState);case _Decrypted() when decrypted != null:
return decrypted(_that.archivingState);case _DecryptionFailure() when decryptionFailure != null:
return decryptionFailure(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( int total)  loadingEncryption,required TResult Function( int total)  loadingDecryption,required TResult Function( ArchivingState archivingState)  encrypted,required TResult Function( DearchivingState archivingState)  decrypted,required TResult Function( EncryptionFailure failure)  decryptionFailure,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _LoadingEncryption():
return loadingEncryption(_that.total);case _LoadingDecryption():
return loadingDecryption(_that.total);case _Encrypted():
return encrypted(_that.archivingState);case _Decrypted():
return decrypted(_that.archivingState);case _DecryptionFailure():
return decryptionFailure(_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( int total)?  loadingEncryption,TResult? Function( int total)?  loadingDecryption,TResult? Function( ArchivingState archivingState)?  encrypted,TResult? Function( DearchivingState archivingState)?  decrypted,TResult? Function( EncryptionFailure failure)?  decryptionFailure,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _LoadingEncryption() when loadingEncryption != null:
return loadingEncryption(_that.total);case _LoadingDecryption() when loadingDecryption != null:
return loadingDecryption(_that.total);case _Encrypted() when encrypted != null:
return encrypted(_that.archivingState);case _Decrypted() when decrypted != null:
return decrypted(_that.archivingState);case _DecryptionFailure() when decryptionFailure != null:
return decryptionFailure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _Initial extends GalleryState {
  const _Initial(): super._();
  










}




/// @nodoc


class _LoadingEncryption extends GalleryState {
  const _LoadingEncryption({required this.total}): super._();
  

 final  int total;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadingEncryptionCopyWith<_LoadingEncryption> get copyWith => __$LoadingEncryptionCopyWithImpl<_LoadingEncryption>(this, _$identity);







}

/// @nodoc
abstract mixin class _$LoadingEncryptionCopyWith<$Res> implements $GalleryStateCopyWith<$Res> {
  factory _$LoadingEncryptionCopyWith(_LoadingEncryption value, $Res Function(_LoadingEncryption) _then) = __$LoadingEncryptionCopyWithImpl;
@useResult
$Res call({
 int total
});




}
/// @nodoc
class __$LoadingEncryptionCopyWithImpl<$Res>
    implements _$LoadingEncryptionCopyWith<$Res> {
  __$LoadingEncryptionCopyWithImpl(this._self, this._then);

  final _LoadingEncryption _self;
  final $Res Function(_LoadingEncryption) _then;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? total = null,}) {
  return _then(_LoadingEncryption(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _LoadingDecryption extends GalleryState {
  const _LoadingDecryption({required this.total}): super._();
  

 final  int total;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadingDecryptionCopyWith<_LoadingDecryption> get copyWith => __$LoadingDecryptionCopyWithImpl<_LoadingDecryption>(this, _$identity);







}

/// @nodoc
abstract mixin class _$LoadingDecryptionCopyWith<$Res> implements $GalleryStateCopyWith<$Res> {
  factory _$LoadingDecryptionCopyWith(_LoadingDecryption value, $Res Function(_LoadingDecryption) _then) = __$LoadingDecryptionCopyWithImpl;
@useResult
$Res call({
 int total
});




}
/// @nodoc
class __$LoadingDecryptionCopyWithImpl<$Res>
    implements _$LoadingDecryptionCopyWith<$Res> {
  __$LoadingDecryptionCopyWithImpl(this._self, this._then);

  final _LoadingDecryption _self;
  final $Res Function(_LoadingDecryption) _then;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? total = null,}) {
  return _then(_LoadingDecryption(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Encrypted extends GalleryState {
  const _Encrypted({required this.archivingState}): super._();
  

 final  ArchivingState archivingState;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncryptedCopyWith<_Encrypted> get copyWith => __$EncryptedCopyWithImpl<_Encrypted>(this, _$identity);







}

/// @nodoc
abstract mixin class _$EncryptedCopyWith<$Res> implements $GalleryStateCopyWith<$Res> {
  factory _$EncryptedCopyWith(_Encrypted value, $Res Function(_Encrypted) _then) = __$EncryptedCopyWithImpl;
@useResult
$Res call({
 ArchivingState archivingState
});




}
/// @nodoc
class __$EncryptedCopyWithImpl<$Res>
    implements _$EncryptedCopyWith<$Res> {
  __$EncryptedCopyWithImpl(this._self, this._then);

  final _Encrypted _self;
  final $Res Function(_Encrypted) _then;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? archivingState = null,}) {
  return _then(_Encrypted(
archivingState: null == archivingState ? _self.archivingState : archivingState // ignore: cast_nullable_to_non_nullable
as ArchivingState,
  ));
}


}

/// @nodoc


class _Decrypted extends GalleryState {
  const _Decrypted({required this.archivingState}): super._();
  

 final  DearchivingState archivingState;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecryptedCopyWith<_Decrypted> get copyWith => __$DecryptedCopyWithImpl<_Decrypted>(this, _$identity);







}

/// @nodoc
abstract mixin class _$DecryptedCopyWith<$Res> implements $GalleryStateCopyWith<$Res> {
  factory _$DecryptedCopyWith(_Decrypted value, $Res Function(_Decrypted) _then) = __$DecryptedCopyWithImpl;
@useResult
$Res call({
 DearchivingState archivingState
});




}
/// @nodoc
class __$DecryptedCopyWithImpl<$Res>
    implements _$DecryptedCopyWith<$Res> {
  __$DecryptedCopyWithImpl(this._self, this._then);

  final _Decrypted _self;
  final $Res Function(_Decrypted) _then;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? archivingState = null,}) {
  return _then(_Decrypted(
archivingState: null == archivingState ? _self.archivingState : archivingState // ignore: cast_nullable_to_non_nullable
as DearchivingState,
  ));
}


}

/// @nodoc


class _DecryptionFailure extends GalleryState {
  const _DecryptionFailure({required this.failure}): super._();
  

 final  EncryptionFailure failure;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecryptionFailureCopyWith<_DecryptionFailure> get copyWith => __$DecryptionFailureCopyWithImpl<_DecryptionFailure>(this, _$identity);







}

/// @nodoc
abstract mixin class _$DecryptionFailureCopyWith<$Res> implements $GalleryStateCopyWith<$Res> {
  factory _$DecryptionFailureCopyWith(_DecryptionFailure value, $Res Function(_DecryptionFailure) _then) = __$DecryptionFailureCopyWithImpl;
@useResult
$Res call({
 EncryptionFailure failure
});




}
/// @nodoc
class __$DecryptionFailureCopyWithImpl<$Res>
    implements _$DecryptionFailureCopyWith<$Res> {
  __$DecryptionFailureCopyWithImpl(this._self, this._then);

  final _DecryptionFailure _self;
  final $Res Function(_DecryptionFailure) _then;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(_DecryptionFailure(
failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as EncryptionFailure,
  ));
}


}

// dart format on
