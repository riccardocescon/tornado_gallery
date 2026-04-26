// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'archive_page_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ArchivePageEvent {







@override
String toString() {
  return 'ArchivePageEvent()';
}


}

/// @nodoc
class $ArchivePageEventCopyWith<$Res>  {
$ArchivePageEventCopyWith(ArchivePageEvent _, $Res Function(ArchivePageEvent) __);
}


/// Adds pattern-matching-related methods to [ArchivePageEvent].
extension ArchivePageEventPatterns on ArchivePageEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Setup value)?  setup,TResult Function( _ArchivePageDelete value)?  delete,TResult Function( _ArchivePageEncryptAll value)?  encryptAll,TResult Function( _ArchivePageDecryptAll value)?  decryptAll,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _ArchivePageDelete() when delete != null:
return delete(_that);case _ArchivePageEncryptAll() when encryptAll != null:
return encryptAll(_that);case _ArchivePageDecryptAll() when decryptAll != null:
return decryptAll(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Setup value)  setup,required TResult Function( _ArchivePageDelete value)  delete,required TResult Function( _ArchivePageEncryptAll value)  encryptAll,required TResult Function( _ArchivePageDecryptAll value)  decryptAll,}){
final _that = this;
switch (_that) {
case _Setup():
return setup(_that);case _ArchivePageDelete():
return delete(_that);case _ArchivePageEncryptAll():
return encryptAll(_that);case _ArchivePageDecryptAll():
return decryptAll(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Setup value)?  setup,TResult? Function( _ArchivePageDelete value)?  delete,TResult? Function( _ArchivePageEncryptAll value)?  encryptAll,TResult? Function( _ArchivePageDecryptAll value)?  decryptAll,}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _ArchivePageDelete() when delete != null:
return delete(_that);case _ArchivePageEncryptAll() when encryptAll != null:
return encryptAll(_that);case _ArchivePageDecryptAll() when decryptAll != null:
return decryptAll(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  setup,TResult Function( String path,  String? assetId)?  delete,TResult Function()?  encryptAll,TResult Function( String passphrase)?  decryptAll,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup();case _ArchivePageDelete() when delete != null:
return delete(_that.path,_that.assetId);case _ArchivePageEncryptAll() when encryptAll != null:
return encryptAll();case _ArchivePageDecryptAll() when decryptAll != null:
return decryptAll(_that.passphrase);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  setup,required TResult Function( String path,  String? assetId)  delete,required TResult Function()  encryptAll,required TResult Function( String passphrase)  decryptAll,}) {final _that = this;
switch (_that) {
case _Setup():
return setup();case _ArchivePageDelete():
return delete(_that.path,_that.assetId);case _ArchivePageEncryptAll():
return encryptAll();case _ArchivePageDecryptAll():
return decryptAll(_that.passphrase);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  setup,TResult? Function( String path,  String? assetId)?  delete,TResult? Function()?  encryptAll,TResult? Function( String passphrase)?  decryptAll,}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup();case _ArchivePageDelete() when delete != null:
return delete(_that.path,_that.assetId);case _ArchivePageEncryptAll() when encryptAll != null:
return encryptAll();case _ArchivePageDecryptAll() when decryptAll != null:
return decryptAll(_that.passphrase);case _:
  return null;

}
}

}

/// @nodoc


class _Setup extends ArchivePageEvent {
  const _Setup(): super._();
  








@override
String toString() {
  return 'ArchivePageEvent.setup()';
}


}




/// @nodoc


class _ArchivePageDelete extends ArchivePageEvent {
  const _ArchivePageDelete({required this.path, this.assetId}): super._();
  

 final  String path;
 final  String? assetId;

/// Create a copy of ArchivePageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArchivePageDeleteCopyWith<_ArchivePageDelete> get copyWith => __$ArchivePageDeleteCopyWithImpl<_ArchivePageDelete>(this, _$identity);





@override
String toString() {
  return 'ArchivePageEvent.delete(path: $path, assetId: $assetId)';
}


}

/// @nodoc
abstract mixin class _$ArchivePageDeleteCopyWith<$Res> implements $ArchivePageEventCopyWith<$Res> {
  factory _$ArchivePageDeleteCopyWith(_ArchivePageDelete value, $Res Function(_ArchivePageDelete) _then) = __$ArchivePageDeleteCopyWithImpl;
@useResult
$Res call({
 String path, String? assetId
});




}
/// @nodoc
class __$ArchivePageDeleteCopyWithImpl<$Res>
    implements _$ArchivePageDeleteCopyWith<$Res> {
  __$ArchivePageDeleteCopyWithImpl(this._self, this._then);

  final _ArchivePageDelete _self;
  final $Res Function(_ArchivePageDelete) _then;

/// Create a copy of ArchivePageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,Object? assetId = freezed,}) {
  return _then(_ArchivePageDelete(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,assetId: freezed == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _ArchivePageEncryptAll extends ArchivePageEvent {
  const _ArchivePageEncryptAll(): super._();
  








@override
String toString() {
  return 'ArchivePageEvent.encryptAll()';
}


}




/// @nodoc


class _ArchivePageDecryptAll extends ArchivePageEvent {
  const _ArchivePageDecryptAll({required this.passphrase}): super._();
  

 final  String passphrase;

/// Create a copy of ArchivePageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArchivePageDecryptAllCopyWith<_ArchivePageDecryptAll> get copyWith => __$ArchivePageDecryptAllCopyWithImpl<_ArchivePageDecryptAll>(this, _$identity);





@override
String toString() {
  return 'ArchivePageEvent.decryptAll(passphrase: $passphrase)';
}


}

/// @nodoc
abstract mixin class _$ArchivePageDecryptAllCopyWith<$Res> implements $ArchivePageEventCopyWith<$Res> {
  factory _$ArchivePageDecryptAllCopyWith(_ArchivePageDecryptAll value, $Res Function(_ArchivePageDecryptAll) _then) = __$ArchivePageDecryptAllCopyWithImpl;
@useResult
$Res call({
 String passphrase
});




}
/// @nodoc
class __$ArchivePageDecryptAllCopyWithImpl<$Res>
    implements _$ArchivePageDecryptAllCopyWith<$Res> {
  __$ArchivePageDecryptAllCopyWithImpl(this._self, this._then);

  final _ArchivePageDecryptAll _self;
  final $Res Function(_ArchivePageDecryptAll) _then;

/// Create a copy of ArchivePageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? passphrase = null,}) {
  return _then(_ArchivePageDecryptAll(
passphrase: null == passphrase ? _self.passphrase : passphrase // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ArchivePageState {









}

/// @nodoc
class $ArchivePageStateCopyWith<$Res>  {
$ArchivePageStateCopyWith(ArchivePageState _, $Res Function(ArchivePageState) __);
}


/// Adds pattern-matching-related methods to [ArchivePageState].
extension ArchivePageStatePatterns on ArchivePageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Deleting value)?  deleting,TResult Function( _UI value)?  ui,TResult Function( _DecryptingAllUI value)?  decryptingAllUI,TResult Function( _Failure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Deleting() when deleting != null:
return deleting(_that);case _UI() when ui != null:
return ui(_that);case _DecryptingAllUI() when decryptingAllUI != null:
return decryptingAllUI(_that);case _Failure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Deleting value)  deleting,required TResult Function( _UI value)  ui,required TResult Function( _DecryptingAllUI value)  decryptingAllUI,required TResult Function( _Failure value)  failure,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Deleting():
return deleting(_that);case _UI():
return ui(_that);case _DecryptingAllUI():
return decryptingAllUI(_that);case _Failure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Deleting value)?  deleting,TResult? Function( _UI value)?  ui,TResult? Function( _DecryptingAllUI value)?  decryptingAllUI,TResult? Function( _Failure value)?  failure,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Deleting() when deleting != null:
return deleting(_that);case _UI() when ui != null:
return ui(_that);case _DecryptingAllUI() when decryptingAllUI != null:
return decryptingAllUI(_that);case _Failure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<String> paths)?  deleting,TResult Function( List<EncryptedImage> images)?  ui,TResult Function( DearchivingState dearchivingState)?  decryptingAllUI,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Deleting() when deleting != null:
return deleting(_that.paths);case _UI() when ui != null:
return ui(_that.images);case _DecryptingAllUI() when decryptingAllUI != null:
return decryptingAllUI(_that.dearchivingState);case _Failure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<String> paths)  deleting,required TResult Function( List<EncryptedImage> images)  ui,required TResult Function( DearchivingState dearchivingState)  decryptingAllUI,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Deleting():
return deleting(_that.paths);case _UI():
return ui(_that.images);case _DecryptingAllUI():
return decryptingAllUI(_that.dearchivingState);case _Failure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<String> paths)?  deleting,TResult? Function( List<EncryptedImage> images)?  ui,TResult? Function( DearchivingState dearchivingState)?  decryptingAllUI,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Deleting() when deleting != null:
return deleting(_that.paths);case _UI() when ui != null:
return ui(_that.images);case _DecryptingAllUI() when decryptingAllUI != null:
return decryptingAllUI(_that.dearchivingState);case _Failure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial extends ArchivePageState {
  const _Initial(): super._();
  










}




/// @nodoc


class _Loading extends ArchivePageState {
  const _Loading(): super._();
  










}




/// @nodoc


class _Deleting extends ArchivePageState {
  const _Deleting({required final  List<String> paths}): _paths = paths,super._();
  

 final  List<String> _paths;
 List<String> get paths {
  if (_paths is EqualUnmodifiableListView) return _paths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paths);
}


/// Create a copy of ArchivePageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeletingCopyWith<_Deleting> get copyWith => __$DeletingCopyWithImpl<_Deleting>(this, _$identity);







}

/// @nodoc
abstract mixin class _$DeletingCopyWith<$Res> implements $ArchivePageStateCopyWith<$Res> {
  factory _$DeletingCopyWith(_Deleting value, $Res Function(_Deleting) _then) = __$DeletingCopyWithImpl;
@useResult
$Res call({
 List<String> paths
});




}
/// @nodoc
class __$DeletingCopyWithImpl<$Res>
    implements _$DeletingCopyWith<$Res> {
  __$DeletingCopyWithImpl(this._self, this._then);

  final _Deleting _self;
  final $Res Function(_Deleting) _then;

/// Create a copy of ArchivePageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? paths = null,}) {
  return _then(_Deleting(
paths: null == paths ? _self._paths : paths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class _UI extends ArchivePageState {
  const _UI({required final  List<EncryptedImage> images}): _images = images,super._();
  

 final  List<EncryptedImage> _images;
 List<EncryptedImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}


/// Create a copy of ArchivePageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UICopyWith<_UI> get copyWith => __$UICopyWithImpl<_UI>(this, _$identity);







}

/// @nodoc
abstract mixin class _$UICopyWith<$Res> implements $ArchivePageStateCopyWith<$Res> {
  factory _$UICopyWith(_UI value, $Res Function(_UI) _then) = __$UICopyWithImpl;
@useResult
$Res call({
 List<EncryptedImage> images
});




}
/// @nodoc
class __$UICopyWithImpl<$Res>
    implements _$UICopyWith<$Res> {
  __$UICopyWithImpl(this._self, this._then);

  final _UI _self;
  final $Res Function(_UI) _then;

/// Create a copy of ArchivePageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? images = null,}) {
  return _then(_UI(
images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<EncryptedImage>,
  ));
}


}

/// @nodoc


class _DecryptingAllUI extends ArchivePageState {
  const _DecryptingAllUI({required this.dearchivingState}): super._();
  

 final  DearchivingState dearchivingState;

/// Create a copy of ArchivePageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecryptingAllUICopyWith<_DecryptingAllUI> get copyWith => __$DecryptingAllUICopyWithImpl<_DecryptingAllUI>(this, _$identity);







}

/// @nodoc
abstract mixin class _$DecryptingAllUICopyWith<$Res> implements $ArchivePageStateCopyWith<$Res> {
  factory _$DecryptingAllUICopyWith(_DecryptingAllUI value, $Res Function(_DecryptingAllUI) _then) = __$DecryptingAllUICopyWithImpl;
@useResult
$Res call({
 DearchivingState dearchivingState
});




}
/// @nodoc
class __$DecryptingAllUICopyWithImpl<$Res>
    implements _$DecryptingAllUICopyWith<$Res> {
  __$DecryptingAllUICopyWithImpl(this._self, this._then);

  final _DecryptingAllUI _self;
  final $Res Function(_DecryptingAllUI) _then;

/// Create a copy of ArchivePageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? dearchivingState = null,}) {
  return _then(_DecryptingAllUI(
dearchivingState: null == dearchivingState ? _self.dearchivingState : dearchivingState // ignore: cast_nullable_to_non_nullable
as DearchivingState,
  ));
}


}

/// @nodoc


class _Failure extends ArchivePageState {
  const _Failure({required this.message}): super._();
  

 final  String message;

/// Create a copy of ArchivePageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailureCopyWith<_Failure> get copyWith => __$FailureCopyWithImpl<_Failure>(this, _$identity);







}

/// @nodoc
abstract mixin class _$FailureCopyWith<$Res> implements $ArchivePageStateCopyWith<$Res> {
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

/// Create a copy of ArchivePageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Failure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
