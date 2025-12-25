// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encrypted_gallery_page_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EncrpytedGalleryPageEvent {









}

/// @nodoc
class $EncrpytedGalleryPageEventCopyWith<$Res>  {
$EncrpytedGalleryPageEventCopyWith(EncrpytedGalleryPageEvent _, $Res Function(EncrpytedGalleryPageEvent) __);
}


/// Adds pattern-matching-related methods to [EncrpytedGalleryPageEvent].
extension EncrpytedGalleryPageEventPatterns on EncrpytedGalleryPageEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Setup value)?  setup,TResult Function( _PickFiles value)?  pickFiles,TResult Function( _DecryptImage value)?  decryptImage,TResult Function( _DecryptFolder value)?  decryptFolder,TResult Function( _DeleteFolder value)?  deleteFolder,TResult Function( _CreateFolder value)?  createFolder,TResult Function( _LoadNextPage value)?  loadNextPage,TResult Function( _DeleteImage value)?  deleteImage,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _PickFiles() when pickFiles != null:
return pickFiles(_that);case _DecryptImage() when decryptImage != null:
return decryptImage(_that);case _DecryptFolder() when decryptFolder != null:
return decryptFolder(_that);case _DeleteFolder() when deleteFolder != null:
return deleteFolder(_that);case _CreateFolder() when createFolder != null:
return createFolder(_that);case _LoadNextPage() when loadNextPage != null:
return loadNextPage(_that);case _DeleteImage() when deleteImage != null:
return deleteImage(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Setup value)  setup,required TResult Function( _PickFiles value)  pickFiles,required TResult Function( _DecryptImage value)  decryptImage,required TResult Function( _DecryptFolder value)  decryptFolder,required TResult Function( _DeleteFolder value)  deleteFolder,required TResult Function( _CreateFolder value)  createFolder,required TResult Function( _LoadNextPage value)  loadNextPage,required TResult Function( _DeleteImage value)  deleteImage,}){
final _that = this;
switch (_that) {
case _Setup():
return setup(_that);case _PickFiles():
return pickFiles(_that);case _DecryptImage():
return decryptImage(_that);case _DecryptFolder():
return decryptFolder(_that);case _DeleteFolder():
return deleteFolder(_that);case _CreateFolder():
return createFolder(_that);case _LoadNextPage():
return loadNextPage(_that);case _DeleteImage():
return deleteImage(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Setup value)?  setup,TResult? Function( _PickFiles value)?  pickFiles,TResult? Function( _DecryptImage value)?  decryptImage,TResult? Function( _DecryptFolder value)?  decryptFolder,TResult? Function( _DeleteFolder value)?  deleteFolder,TResult? Function( _CreateFolder value)?  createFolder,TResult? Function( _LoadNextPage value)?  loadNextPage,TResult? Function( _DeleteImage value)?  deleteImage,}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _PickFiles() when pickFiles != null:
return pickFiles(_that);case _DecryptImage() when decryptImage != null:
return decryptImage(_that);case _DecryptFolder() when decryptFolder != null:
return decryptFolder(_that);case _DeleteFolder() when deleteFolder != null:
return deleteFolder(_that);case _CreateFolder() when createFolder != null:
return createFolder(_that);case _LoadNextPage() when loadNextPage != null:
return loadNextPage(_that);case _DeleteImage() when deleteImage != null:
return deleteImage(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? currentRoute)?  setup,TResult Function()?  pickFiles,TResult Function( EncryptedImage image,  String password,  String? path)?  decryptImage,TResult Function( String password)?  decryptFolder,TResult Function( String folderName)?  deleteFolder,TResult Function( String folderName)?  createFolder,TResult Function()?  loadNextPage,TResult Function( EncryptedImage image)?  deleteImage,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that.currentRoute);case _PickFiles() when pickFiles != null:
return pickFiles();case _DecryptImage() when decryptImage != null:
return decryptImage(_that.image,_that.password,_that.path);case _DecryptFolder() when decryptFolder != null:
return decryptFolder(_that.password);case _DeleteFolder() when deleteFolder != null:
return deleteFolder(_that.folderName);case _CreateFolder() when createFolder != null:
return createFolder(_that.folderName);case _LoadNextPage() when loadNextPage != null:
return loadNextPage();case _DeleteImage() when deleteImage != null:
return deleteImage(_that.image);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? currentRoute)  setup,required TResult Function()  pickFiles,required TResult Function( EncryptedImage image,  String password,  String? path)  decryptImage,required TResult Function( String password)  decryptFolder,required TResult Function( String folderName)  deleteFolder,required TResult Function( String folderName)  createFolder,required TResult Function()  loadNextPage,required TResult Function( EncryptedImage image)  deleteImage,}) {final _that = this;
switch (_that) {
case _Setup():
return setup(_that.currentRoute);case _PickFiles():
return pickFiles();case _DecryptImage():
return decryptImage(_that.image,_that.password,_that.path);case _DecryptFolder():
return decryptFolder(_that.password);case _DeleteFolder():
return deleteFolder(_that.folderName);case _CreateFolder():
return createFolder(_that.folderName);case _LoadNextPage():
return loadNextPage();case _DeleteImage():
return deleteImage(_that.image);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? currentRoute)?  setup,TResult? Function()?  pickFiles,TResult? Function( EncryptedImage image,  String password,  String? path)?  decryptImage,TResult? Function( String password)?  decryptFolder,TResult? Function( String folderName)?  deleteFolder,TResult? Function( String folderName)?  createFolder,TResult? Function()?  loadNextPage,TResult? Function( EncryptedImage image)?  deleteImage,}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that.currentRoute);case _PickFiles() when pickFiles != null:
return pickFiles();case _DecryptImage() when decryptImage != null:
return decryptImage(_that.image,_that.password,_that.path);case _DecryptFolder() when decryptFolder != null:
return decryptFolder(_that.password);case _DeleteFolder() when deleteFolder != null:
return deleteFolder(_that.folderName);case _CreateFolder() when createFolder != null:
return createFolder(_that.folderName);case _LoadNextPage() when loadNextPage != null:
return loadNextPage();case _DeleteImage() when deleteImage != null:
return deleteImage(_that.image);case _:
  return null;

}
}

}

/// @nodoc


class _Setup extends EncrpytedGalleryPageEvent {
  const _Setup({required this.currentRoute}): super._();
  

 final  String? currentRoute;

/// Create a copy of EncrpytedGalleryPageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupCopyWith<_Setup> get copyWith => __$SetupCopyWithImpl<_Setup>(this, _$identity);







}

/// @nodoc
abstract mixin class _$SetupCopyWith<$Res> implements $EncrpytedGalleryPageEventCopyWith<$Res> {
  factory _$SetupCopyWith(_Setup value, $Res Function(_Setup) _then) = __$SetupCopyWithImpl;
@useResult
$Res call({
 String? currentRoute
});




}
/// @nodoc
class __$SetupCopyWithImpl<$Res>
    implements _$SetupCopyWith<$Res> {
  __$SetupCopyWithImpl(this._self, this._then);

  final _Setup _self;
  final $Res Function(_Setup) _then;

/// Create a copy of EncrpytedGalleryPageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentRoute = freezed,}) {
  return _then(_Setup(
currentRoute: freezed == currentRoute ? _self.currentRoute : currentRoute // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _PickFiles extends EncrpytedGalleryPageEvent {
  const _PickFiles(): super._();
  










}




/// @nodoc


class _DecryptImage extends EncrpytedGalleryPageEvent {
  const _DecryptImage({required this.image, required this.password, required this.path}): super._();
  

 final  EncryptedImage image;
 final  String password;
 final  String? path;

/// Create a copy of EncrpytedGalleryPageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecryptImageCopyWith<_DecryptImage> get copyWith => __$DecryptImageCopyWithImpl<_DecryptImage>(this, _$identity);







}

/// @nodoc
abstract mixin class _$DecryptImageCopyWith<$Res> implements $EncrpytedGalleryPageEventCopyWith<$Res> {
  factory _$DecryptImageCopyWith(_DecryptImage value, $Res Function(_DecryptImage) _then) = __$DecryptImageCopyWithImpl;
@useResult
$Res call({
 EncryptedImage image, String password, String? path
});




}
/// @nodoc
class __$DecryptImageCopyWithImpl<$Res>
    implements _$DecryptImageCopyWith<$Res> {
  __$DecryptImageCopyWithImpl(this._self, this._then);

  final _DecryptImage _self;
  final $Res Function(_DecryptImage) _then;

/// Create a copy of EncrpytedGalleryPageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? image = null,Object? password = null,Object? path = freezed,}) {
  return _then(_DecryptImage(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as EncryptedImage,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _DecryptFolder extends EncrpytedGalleryPageEvent {
  const _DecryptFolder({required this.password}): super._();
  

 final  String password;

/// Create a copy of EncrpytedGalleryPageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecryptFolderCopyWith<_DecryptFolder> get copyWith => __$DecryptFolderCopyWithImpl<_DecryptFolder>(this, _$identity);







}

/// @nodoc
abstract mixin class _$DecryptFolderCopyWith<$Res> implements $EncrpytedGalleryPageEventCopyWith<$Res> {
  factory _$DecryptFolderCopyWith(_DecryptFolder value, $Res Function(_DecryptFolder) _then) = __$DecryptFolderCopyWithImpl;
@useResult
$Res call({
 String password
});




}
/// @nodoc
class __$DecryptFolderCopyWithImpl<$Res>
    implements _$DecryptFolderCopyWith<$Res> {
  __$DecryptFolderCopyWithImpl(this._self, this._then);

  final _DecryptFolder _self;
  final $Res Function(_DecryptFolder) _then;

/// Create a copy of EncrpytedGalleryPageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? password = null,}) {
  return _then(_DecryptFolder(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _DeleteFolder extends EncrpytedGalleryPageEvent {
  const _DeleteFolder({required this.folderName}): super._();
  

 final  String folderName;

/// Create a copy of EncrpytedGalleryPageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteFolderCopyWith<_DeleteFolder> get copyWith => __$DeleteFolderCopyWithImpl<_DeleteFolder>(this, _$identity);







}

/// @nodoc
abstract mixin class _$DeleteFolderCopyWith<$Res> implements $EncrpytedGalleryPageEventCopyWith<$Res> {
  factory _$DeleteFolderCopyWith(_DeleteFolder value, $Res Function(_DeleteFolder) _then) = __$DeleteFolderCopyWithImpl;
@useResult
$Res call({
 String folderName
});




}
/// @nodoc
class __$DeleteFolderCopyWithImpl<$Res>
    implements _$DeleteFolderCopyWith<$Res> {
  __$DeleteFolderCopyWithImpl(this._self, this._then);

  final _DeleteFolder _self;
  final $Res Function(_DeleteFolder) _then;

/// Create a copy of EncrpytedGalleryPageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? folderName = null,}) {
  return _then(_DeleteFolder(
folderName: null == folderName ? _self.folderName : folderName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _CreateFolder extends EncrpytedGalleryPageEvent {
  const _CreateFolder({required this.folderName}): super._();
  

 final  String folderName;

/// Create a copy of EncrpytedGalleryPageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateFolderCopyWith<_CreateFolder> get copyWith => __$CreateFolderCopyWithImpl<_CreateFolder>(this, _$identity);







}

/// @nodoc
abstract mixin class _$CreateFolderCopyWith<$Res> implements $EncrpytedGalleryPageEventCopyWith<$Res> {
  factory _$CreateFolderCopyWith(_CreateFolder value, $Res Function(_CreateFolder) _then) = __$CreateFolderCopyWithImpl;
@useResult
$Res call({
 String folderName
});




}
/// @nodoc
class __$CreateFolderCopyWithImpl<$Res>
    implements _$CreateFolderCopyWith<$Res> {
  __$CreateFolderCopyWithImpl(this._self, this._then);

  final _CreateFolder _self;
  final $Res Function(_CreateFolder) _then;

/// Create a copy of EncrpytedGalleryPageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? folderName = null,}) {
  return _then(_CreateFolder(
folderName: null == folderName ? _self.folderName : folderName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _LoadNextPage extends EncrpytedGalleryPageEvent {
  const _LoadNextPage(): super._();
  










}




/// @nodoc


class _DeleteImage extends EncrpytedGalleryPageEvent {
  const _DeleteImage({required this.image}): super._();
  

 final  EncryptedImage image;

/// Create a copy of EncrpytedGalleryPageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteImageCopyWith<_DeleteImage> get copyWith => __$DeleteImageCopyWithImpl<_DeleteImage>(this, _$identity);







}

/// @nodoc
abstract mixin class _$DeleteImageCopyWith<$Res> implements $EncrpytedGalleryPageEventCopyWith<$Res> {
  factory _$DeleteImageCopyWith(_DeleteImage value, $Res Function(_DeleteImage) _then) = __$DeleteImageCopyWithImpl;
@useResult
$Res call({
 EncryptedImage image
});




}
/// @nodoc
class __$DeleteImageCopyWithImpl<$Res>
    implements _$DeleteImageCopyWith<$Res> {
  __$DeleteImageCopyWithImpl(this._self, this._then);

  final _DeleteImage _self;
  final $Res Function(_DeleteImage) _then;

/// Create a copy of EncrpytedGalleryPageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? image = null,}) {
  return _then(_DeleteImage(
image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as EncryptedImage,
  ));
}


}

/// @nodoc
mixin _$EncrpytedGalleryPageState {









}

/// @nodoc
class $EncrpytedGalleryPageStateCopyWith<$Res>  {
$EncrpytedGalleryPageStateCopyWith(EncrpytedGalleryPageState _, $Res Function(EncrpytedGalleryPageState) __);
}


/// Adds pattern-matching-related methods to [EncrpytedGalleryPageState].
extension EncrpytedGalleryPageStatePatterns on EncrpytedGalleryPageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Decrypted value)?  decrypted,TResult Function( _FolderDeleted value)?  folderDeleted,TResult Function( _Failure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Decrypted() when decrypted != null:
return decrypted(_that);case _FolderDeleted() when folderDeleted != null:
return folderDeleted(_that);case _Failure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Decrypted value)  decrypted,required TResult Function( _FolderDeleted value)  folderDeleted,required TResult Function( _Failure value)  failure,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Decrypted():
return decrypted(_that);case _FolderDeleted():
return folderDeleted(_that);case _Failure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Decrypted value)?  decrypted,TResult? Function( _FolderDeleted value)?  folderDeleted,TResult? Function( _Failure value)?  failure,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Decrypted() when decrypted != null:
return decrypted(_that);case _FolderDeleted() when folderDeleted != null:
return folderDeleted(_that);case _Failure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<EncryptedEntity> entities,  bool isLoading,  bool hasMore)?  loaded,TResult Function( Uint8List data)?  decrypted,TResult Function()?  folderDeleted,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.entities,_that.isLoading,_that.hasMore);case _Decrypted() when decrypted != null:
return decrypted(_that.data);case _FolderDeleted() when folderDeleted != null:
return folderDeleted();case _Failure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<EncryptedEntity> entities,  bool isLoading,  bool hasMore)  loaded,required TResult Function( Uint8List data)  decrypted,required TResult Function()  folderDeleted,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.entities,_that.isLoading,_that.hasMore);case _Decrypted():
return decrypted(_that.data);case _FolderDeleted():
return folderDeleted();case _Failure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<EncryptedEntity> entities,  bool isLoading,  bool hasMore)?  loaded,TResult? Function( Uint8List data)?  decrypted,TResult? Function()?  folderDeleted,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.entities,_that.isLoading,_that.hasMore);case _Decrypted() when decrypted != null:
return decrypted(_that.data);case _FolderDeleted() when folderDeleted != null:
return folderDeleted();case _Failure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial extends EncrpytedGalleryPageState {
  const _Initial(): super._();
  










}




/// @nodoc


class _Loading extends EncrpytedGalleryPageState {
  const _Loading(): super._();
  










}




/// @nodoc


class _Loaded extends EncrpytedGalleryPageState {
  const _Loaded({required final  List<EncryptedEntity> entities, required this.isLoading, required this.hasMore}): _entities = entities,super._();
  

 final  List<EncryptedEntity> _entities;
 List<EncryptedEntity> get entities {
  if (_entities is EqualUnmodifiableListView) return _entities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entities);
}

 final  bool isLoading;
 final  bool hasMore;

/// Create a copy of EncrpytedGalleryPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);







}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $EncrpytedGalleryPageStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<EncryptedEntity> entities, bool isLoading, bool hasMore
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of EncrpytedGalleryPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entities = null,Object? isLoading = null,Object? hasMore = null,}) {
  return _then(_Loaded(
entities: null == entities ? _self._entities : entities // ignore: cast_nullable_to_non_nullable
as List<EncryptedEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _Decrypted extends EncrpytedGalleryPageState {
  const _Decrypted({required this.data}): super._();
  

 final  Uint8List data;

/// Create a copy of EncrpytedGalleryPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecryptedCopyWith<_Decrypted> get copyWith => __$DecryptedCopyWithImpl<_Decrypted>(this, _$identity);







}

/// @nodoc
abstract mixin class _$DecryptedCopyWith<$Res> implements $EncrpytedGalleryPageStateCopyWith<$Res> {
  factory _$DecryptedCopyWith(_Decrypted value, $Res Function(_Decrypted) _then) = __$DecryptedCopyWithImpl;
@useResult
$Res call({
 Uint8List data
});




}
/// @nodoc
class __$DecryptedCopyWithImpl<$Res>
    implements _$DecryptedCopyWith<$Res> {
  __$DecryptedCopyWithImpl(this._self, this._then);

  final _Decrypted _self;
  final $Res Function(_Decrypted) _then;

/// Create a copy of EncrpytedGalleryPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_Decrypted(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}


}

/// @nodoc


class _FolderDeleted extends EncrpytedGalleryPageState {
  const _FolderDeleted(): super._();
  










}




/// @nodoc


class _Failure extends EncrpytedGalleryPageState {
  const _Failure({required this.message}): super._();
  

 final  String message;

/// Create a copy of EncrpytedGalleryPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailureCopyWith<_Failure> get copyWith => __$FailureCopyWithImpl<_Failure>(this, _$identity);







}

/// @nodoc
abstract mixin class _$FailureCopyWith<$Res> implements $EncrpytedGalleryPageStateCopyWith<$Res> {
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

/// Create a copy of EncrpytedGalleryPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Failure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
