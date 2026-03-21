// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encrypted_gallery_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EncryptedGalleryEvent {







@override
String toString() {
  return 'EncryptedGalleryEvent()';
}


}

/// @nodoc
class $EncryptedGalleryEventCopyWith<$Res>  {
$EncryptedGalleryEventCopyWith(EncryptedGalleryEvent _, $Res Function(EncryptedGalleryEvent) __);
}


/// Adds pattern-matching-related methods to [EncryptedGalleryEvent].
extension EncryptedGalleryEventPatterns on EncryptedGalleryEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _DecryptImage value)?  decryptImage,TResult Function( _DecryptFolder value)?  decryptFolder,TResult Function( _DeleteFolderGlobal value)?  deleteFolderGlobal,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DecryptImage() when decryptImage != null:
return decryptImage(_that);case _DecryptFolder() when decryptFolder != null:
return decryptFolder(_that);case _DeleteFolderGlobal() when deleteFolderGlobal != null:
return deleteFolderGlobal(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _DecryptImage value)  decryptImage,required TResult Function( _DecryptFolder value)  decryptFolder,required TResult Function( _DeleteFolderGlobal value)  deleteFolderGlobal,}){
final _that = this;
switch (_that) {
case _DecryptImage():
return decryptImage(_that);case _DecryptFolder():
return decryptFolder(_that);case _DeleteFolderGlobal():
return deleteFolderGlobal(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _DecryptImage value)?  decryptImage,TResult? Function( _DecryptFolder value)?  decryptFolder,TResult? Function( _DeleteFolderGlobal value)?  deleteFolderGlobal,}){
final _that = this;
switch (_that) {
case _DecryptImage() when decryptImage != null:
return decryptImage(_that);case _DecryptFolder() when decryptFolder != null:
return decryptFolder(_that);case _DeleteFolderGlobal() when deleteFolderGlobal != null:
return deleteFolderGlobal(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( EncryptedImage image,  String password)?  decryptImage,TResult Function( List<EncryptedImage> images,  String password)?  decryptFolder,TResult Function( String folderName)?  deleteFolderGlobal,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DecryptImage() when decryptImage != null:
return decryptImage(_that.image,_that.password);case _DecryptFolder() when decryptFolder != null:
return decryptFolder(_that.images,_that.password);case _DeleteFolderGlobal() when deleteFolderGlobal != null:
return deleteFolderGlobal(_that.folderName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( EncryptedImage image,  String password)  decryptImage,required TResult Function( List<EncryptedImage> images,  String password)  decryptFolder,required TResult Function( String folderName)  deleteFolderGlobal,}) {final _that = this;
switch (_that) {
case _DecryptImage():
return decryptImage(_that.image,_that.password);case _DecryptFolder():
return decryptFolder(_that.images,_that.password);case _DeleteFolderGlobal():
return deleteFolderGlobal(_that.folderName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( EncryptedImage image,  String password)?  decryptImage,TResult? Function( List<EncryptedImage> images,  String password)?  decryptFolder,TResult? Function( String folderName)?  deleteFolderGlobal,}) {final _that = this;
switch (_that) {
case _DecryptImage() when decryptImage != null:
return decryptImage(_that.image,_that.password);case _DecryptFolder() when decryptFolder != null:
return decryptFolder(_that.images,_that.password);case _DeleteFolderGlobal() when deleteFolderGlobal != null:
return deleteFolderGlobal(_that.folderName);case _:
  return null;

}
}

}

/// @nodoc


class _DecryptImage extends EncryptedGalleryEvent {
  const _DecryptImage({required this.image, required this.password}): super._();
  

 final  EncryptedImage image;
 final  String password;

/// Create a copy of EncryptedGalleryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecryptImageCopyWith<_DecryptImage> get copyWith => __$DecryptImageCopyWithImpl<_DecryptImage>(this, _$identity);





@override
String toString() {
  return 'EncryptedGalleryEvent.decryptImage(image: $image, password: $password)';
}


}

/// @nodoc
abstract mixin class _$DecryptImageCopyWith<$Res> implements $EncryptedGalleryEventCopyWith<$Res> {
  factory _$DecryptImageCopyWith(_DecryptImage value, $Res Function(_DecryptImage) _then) = __$DecryptImageCopyWithImpl;
@useResult
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

/// Create a copy of EncryptedGalleryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? image = null,Object? password = null,}) {
  return _then(_DecryptImage(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as EncryptedImage,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _DecryptFolder extends EncryptedGalleryEvent {
  const _DecryptFolder({required final  List<EncryptedImage> images, required this.password}): _images = images,super._();
  

 final  List<EncryptedImage> _images;
 List<EncryptedImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

 final  String password;

/// Create a copy of EncryptedGalleryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecryptFolderCopyWith<_DecryptFolder> get copyWith => __$DecryptFolderCopyWithImpl<_DecryptFolder>(this, _$identity);





@override
String toString() {
  return 'EncryptedGalleryEvent.decryptFolder(images: $images, password: $password)';
}


}

/// @nodoc
abstract mixin class _$DecryptFolderCopyWith<$Res> implements $EncryptedGalleryEventCopyWith<$Res> {
  factory _$DecryptFolderCopyWith(_DecryptFolder value, $Res Function(_DecryptFolder) _then) = __$DecryptFolderCopyWithImpl;
@useResult
$Res call({
 List<EncryptedImage> images, String password
});




}
/// @nodoc
class __$DecryptFolderCopyWithImpl<$Res>
    implements _$DecryptFolderCopyWith<$Res> {
  __$DecryptFolderCopyWithImpl(this._self, this._then);

  final _DecryptFolder _self;
  final $Res Function(_DecryptFolder) _then;

/// Create a copy of EncryptedGalleryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? images = null,Object? password = null,}) {
  return _then(_DecryptFolder(
images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<EncryptedImage>,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _DeleteFolderGlobal extends EncryptedGalleryEvent {
  const _DeleteFolderGlobal({required this.folderName}): super._();
  

 final  String folderName;

/// Create a copy of EncryptedGalleryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteFolderGlobalCopyWith<_DeleteFolderGlobal> get copyWith => __$DeleteFolderGlobalCopyWithImpl<_DeleteFolderGlobal>(this, _$identity);





@override
String toString() {
  return 'EncryptedGalleryEvent.deleteFolderGlobal(folderName: $folderName)';
}


}

/// @nodoc
abstract mixin class _$DeleteFolderGlobalCopyWith<$Res> implements $EncryptedGalleryEventCopyWith<$Res> {
  factory _$DeleteFolderGlobalCopyWith(_DeleteFolderGlobal value, $Res Function(_DeleteFolderGlobal) _then) = __$DeleteFolderGlobalCopyWithImpl;
@useResult
$Res call({
 String folderName
});




}
/// @nodoc
class __$DeleteFolderGlobalCopyWithImpl<$Res>
    implements _$DeleteFolderGlobalCopyWith<$Res> {
  __$DeleteFolderGlobalCopyWithImpl(this._self, this._then);

  final _DeleteFolderGlobal _self;
  final $Res Function(_DeleteFolderGlobal) _then;

/// Create a copy of EncryptedGalleryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? folderName = null,}) {
  return _then(_DeleteFolderGlobal(
folderName: null == folderName ? _self.folderName : folderName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$EncryptedGalleryState {







@override
String toString() {
  return 'EncryptedGalleryState()';
}


}

/// @nodoc
class $EncryptedGalleryStateCopyWith<$Res>  {
$EncryptedGalleryStateCopyWith(EncryptedGalleryState _, $Res Function(EncryptedGalleryState) __);
}


/// Adds pattern-matching-related methods to [EncryptedGalleryState].
extension EncryptedGalleryStatePatterns on EncryptedGalleryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Decrypted value)?  decrypted,TResult Function( _DecryptedFolderCompleted value)?  decryptedFolderCompleted,TResult Function( _FolderDeleted value)?  folderDeleted,TResult Function( _EncryptionFailure value)?  encryptionFailure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Decrypted() when decrypted != null:
return decrypted(_that);case _DecryptedFolderCompleted() when decryptedFolderCompleted != null:
return decryptedFolderCompleted(_that);case _FolderDeleted() when folderDeleted != null:
return folderDeleted(_that);case _EncryptionFailure() when encryptionFailure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Decrypted value)  decrypted,required TResult Function( _DecryptedFolderCompleted value)  decryptedFolderCompleted,required TResult Function( _FolderDeleted value)  folderDeleted,required TResult Function( _EncryptionFailure value)  encryptionFailure,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Decrypted():
return decrypted(_that);case _DecryptedFolderCompleted():
return decryptedFolderCompleted(_that);case _FolderDeleted():
return folderDeleted(_that);case _EncryptionFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Decrypted value)?  decrypted,TResult? Function( _DecryptedFolderCompleted value)?  decryptedFolderCompleted,TResult? Function( _FolderDeleted value)?  folderDeleted,TResult? Function( _EncryptionFailure value)?  encryptionFailure,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Decrypted() when decrypted != null:
return decrypted(_that);case _DecryptedFolderCompleted() when decryptedFolderCompleted != null:
return decryptedFolderCompleted(_that);case _FolderDeleted() when folderDeleted != null:
return folderDeleted(_that);case _EncryptionFailure() when encryptionFailure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( EncryptedImage data)?  decrypted,TResult Function()?  decryptedFolderCompleted,TResult Function( String folderPath)?  folderDeleted,TResult Function( EncryptionFailure failure)?  encryptionFailure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Decrypted() when decrypted != null:
return decrypted(_that.data);case _DecryptedFolderCompleted() when decryptedFolderCompleted != null:
return decryptedFolderCompleted();case _FolderDeleted() when folderDeleted != null:
return folderDeleted(_that.folderPath);case _EncryptionFailure() when encryptionFailure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( EncryptedImage data)  decrypted,required TResult Function()  decryptedFolderCompleted,required TResult Function( String folderPath)  folderDeleted,required TResult Function( EncryptionFailure failure)  encryptionFailure,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Decrypted():
return decrypted(_that.data);case _DecryptedFolderCompleted():
return decryptedFolderCompleted();case _FolderDeleted():
return folderDeleted(_that.folderPath);case _EncryptionFailure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( EncryptedImage data)?  decrypted,TResult? Function()?  decryptedFolderCompleted,TResult? Function( String folderPath)?  folderDeleted,TResult? Function( EncryptionFailure failure)?  encryptionFailure,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Decrypted() when decrypted != null:
return decrypted(_that.data);case _DecryptedFolderCompleted() when decryptedFolderCompleted != null:
return decryptedFolderCompleted();case _FolderDeleted() when folderDeleted != null:
return folderDeleted(_that.folderPath);case _EncryptionFailure() when encryptionFailure != null:
return encryptionFailure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _Initial extends EncryptedGalleryState {
  const _Initial(): super._();
  








@override
String toString() {
  return 'EncryptedGalleryState.initial()';
}


}




/// @nodoc


class _Loading extends EncryptedGalleryState {
  const _Loading(): super._();
  








@override
String toString() {
  return 'EncryptedGalleryState.loading()';
}


}




/// @nodoc


class _Decrypted extends EncryptedGalleryState {
  const _Decrypted({required this.data}): super._();
  

 final  EncryptedImage data;

/// Create a copy of EncryptedGalleryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecryptedCopyWith<_Decrypted> get copyWith => __$DecryptedCopyWithImpl<_Decrypted>(this, _$identity);





@override
String toString() {
  return 'EncryptedGalleryState.decrypted(data: $data)';
}


}

/// @nodoc
abstract mixin class _$DecryptedCopyWith<$Res> implements $EncryptedGalleryStateCopyWith<$Res> {
  factory _$DecryptedCopyWith(_Decrypted value, $Res Function(_Decrypted) _then) = __$DecryptedCopyWithImpl;
@useResult
$Res call({
 EncryptedImage data
});




}
/// @nodoc
class __$DecryptedCopyWithImpl<$Res>
    implements _$DecryptedCopyWith<$Res> {
  __$DecryptedCopyWithImpl(this._self, this._then);

  final _Decrypted _self;
  final $Res Function(_Decrypted) _then;

/// Create a copy of EncryptedGalleryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_Decrypted(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as EncryptedImage,
  ));
}


}

/// @nodoc


class _DecryptedFolderCompleted extends EncryptedGalleryState {
  const _DecryptedFolderCompleted(): super._();
  








@override
String toString() {
  return 'EncryptedGalleryState.decryptedFolderCompleted()';
}


}




/// @nodoc


class _FolderDeleted extends EncryptedGalleryState {
  const _FolderDeleted({required this.folderPath}): super._();
  

 final  String folderPath;

/// Create a copy of EncryptedGalleryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FolderDeletedCopyWith<_FolderDeleted> get copyWith => __$FolderDeletedCopyWithImpl<_FolderDeleted>(this, _$identity);





@override
String toString() {
  return 'EncryptedGalleryState.folderDeleted(folderPath: $folderPath)';
}


}

/// @nodoc
abstract mixin class _$FolderDeletedCopyWith<$Res> implements $EncryptedGalleryStateCopyWith<$Res> {
  factory _$FolderDeletedCopyWith(_FolderDeleted value, $Res Function(_FolderDeleted) _then) = __$FolderDeletedCopyWithImpl;
@useResult
$Res call({
 String folderPath
});




}
/// @nodoc
class __$FolderDeletedCopyWithImpl<$Res>
    implements _$FolderDeletedCopyWith<$Res> {
  __$FolderDeletedCopyWithImpl(this._self, this._then);

  final _FolderDeleted _self;
  final $Res Function(_FolderDeleted) _then;

/// Create a copy of EncryptedGalleryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? folderPath = null,}) {
  return _then(_FolderDeleted(
folderPath: null == folderPath ? _self.folderPath : folderPath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _EncryptionFailure extends EncryptedGalleryState {
  const _EncryptionFailure({required this.failure}): super._();
  

 final  EncryptionFailure failure;

/// Create a copy of EncryptedGalleryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncryptionFailureCopyWith<_EncryptionFailure> get copyWith => __$EncryptionFailureCopyWithImpl<_EncryptionFailure>(this, _$identity);





@override
String toString() {
  return 'EncryptedGalleryState.encryptionFailure(failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$EncryptionFailureCopyWith<$Res> implements $EncryptedGalleryStateCopyWith<$Res> {
  factory _$EncryptionFailureCopyWith(_EncryptionFailure value, $Res Function(_EncryptionFailure) _then) = __$EncryptionFailureCopyWithImpl;
@useResult
$Res call({
 EncryptionFailure failure
});




}
/// @nodoc
class __$EncryptionFailureCopyWithImpl<$Res>
    implements _$EncryptionFailureCopyWith<$Res> {
  __$EncryptionFailureCopyWithImpl(this._self, this._then);

  final _EncryptionFailure _self;
  final $Res Function(_EncryptionFailure) _then;

/// Create a copy of EncryptedGalleryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(_EncryptionFailure(
failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as EncryptionFailure,
  ));
}


}

// dart format on
