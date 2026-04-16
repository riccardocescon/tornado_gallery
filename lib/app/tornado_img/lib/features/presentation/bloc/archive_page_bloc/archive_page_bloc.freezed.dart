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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Setup value)?  setup,TResult Function( _ArchivePageDelete value)?  delete,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _ArchivePageDelete() when delete != null:
return delete(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Setup value)  setup,required TResult Function( _ArchivePageDelete value)  delete,}){
final _that = this;
switch (_that) {
case _Setup():
return setup(_that);case _ArchivePageDelete():
return delete(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Setup value)?  setup,TResult? Function( _ArchivePageDelete value)?  delete,}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _ArchivePageDelete() when delete != null:
return delete(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  setup,TResult Function( String path, String? assetId)?  delete,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup();case _ArchivePageDelete() when delete != null:
return delete(_that.path, _that.assetId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  setup,required TResult Function( String path, String? assetId)  delete,}) {final _that = this;
switch (_that) {
case _Setup():
return setup();case _ArchivePageDelete():
return delete(_that.path, _that.assetId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  setup,TResult? Function( String path, String? assetId)?  delete,}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup();case _ArchivePageDelete() when delete != null:
return delete(_that.path, _that.assetId);case _:
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
 String path
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
as String,
assetId: freezed == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Deleting value)?  deleting,TResult Function( _UI value)?  ui,TResult Function( _Failure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Deleting() when deleting != null:
return deleting(_that);case _UI() when ui != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Deleting value)  deleting,required TResult Function( _UI value)  ui,required TResult Function( _Failure value)  failure,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Deleting():
return deleting(_that);case _UI():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Deleting value)?  deleting,TResult? Function( _UI value)?  ui,TResult? Function( _Failure value)?  failure,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Deleting() when deleting != null:
return deleting(_that);case _UI() when ui != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<String> paths)?  deleting,TResult Function( List<EncryptedImage> images)?  ui,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Deleting() when deleting != null:
return deleting(_that.paths);case _UI() when ui != null:
return ui(_that.images);case _Failure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<String> paths)  deleting,required TResult Function( List<EncryptedImage> images)  ui,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Deleting():
return deleting(_that.paths);case _UI():
return ui(_that.images);case _Failure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<String> paths)?  deleting,TResult? Function( List<EncryptedImage> images)?  ui,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Deleting() when deleting != null:
return deleting(_that.paths);case _UI() when ui != null:
return ui(_that.images);case _Failure() when failure != null:
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
