// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encryption_page_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EncryptionPageEvent {







@override
String toString() {
  return 'EncryptionPageEvent()';
}


}

/// @nodoc
class $EncryptionPageEventCopyWith<$Res>  {
$EncryptionPageEventCopyWith(EncryptionPageEvent _, $Res Function(EncryptionPageEvent) __);
}


/// Adds pattern-matching-related methods to [EncryptionPageEvent].
extension EncryptionPageEventPatterns on EncryptionPageEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Setup value)?  setup,TResult Function( _SetPassword value)?  setPassword,TResult Function( _ToggleGalleryVisibility value)?  toggleGalleryVisibility,TResult Function( _SetOutputFolder value)?  setOutputFolder,TResult Function( _ToggleDeleteOriginals value)?  toggleDeleteOriginals,TResult Function( _Encrypt value)?  encrypt,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _SetPassword() when setPassword != null:
return setPassword(_that);case _ToggleGalleryVisibility() when toggleGalleryVisibility != null:
return toggleGalleryVisibility(_that);case _SetOutputFolder() when setOutputFolder != null:
return setOutputFolder(_that);case _ToggleDeleteOriginals() when toggleDeleteOriginals != null:
return toggleDeleteOriginals(_that);case _Encrypt() when encrypt != null:
return encrypt(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Setup value)  setup,required TResult Function( _SetPassword value)  setPassword,required TResult Function( _ToggleGalleryVisibility value)  toggleGalleryVisibility,required TResult Function( _SetOutputFolder value)  setOutputFolder,required TResult Function( _ToggleDeleteOriginals value)  toggleDeleteOriginals,required TResult Function( _Encrypt value)  encrypt,}){
final _that = this;
switch (_that) {
case _Setup():
return setup(_that);case _SetPassword():
return setPassword(_that);case _ToggleGalleryVisibility():
return toggleGalleryVisibility(_that);case _SetOutputFolder():
return setOutputFolder(_that);case _ToggleDeleteOriginals():
return toggleDeleteOriginals(_that);case _Encrypt():
return encrypt(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Setup value)?  setup,TResult? Function( _SetPassword value)?  setPassword,TResult? Function( _ToggleGalleryVisibility value)?  toggleGalleryVisibility,TResult? Function( _SetOutputFolder value)?  setOutputFolder,TResult? Function( _ToggleDeleteOriginals value)?  toggleDeleteOriginals,TResult? Function( _Encrypt value)?  encrypt,}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _SetPassword() when setPassword != null:
return setPassword(_that);case _ToggleGalleryVisibility() when toggleGalleryVisibility != null:
return toggleGalleryVisibility(_that);case _SetOutputFolder() when setOutputFolder != null:
return setOutputFolder(_that);case _ToggleDeleteOriginals() when toggleDeleteOriginals != null:
return toggleDeleteOriginals(_that);case _Encrypt() when encrypt != null:
return encrypt(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<GalleryImage> images)?  setup,TResult Function( String password)?  setPassword,TResult Function()?  toggleGalleryVisibility,TResult Function( String outputFolder)?  setOutputFolder,TResult Function()?  toggleDeleteOriginals,TResult Function()?  encrypt,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that.images);case _SetPassword() when setPassword != null:
return setPassword(_that.password);case _ToggleGalleryVisibility() when toggleGalleryVisibility != null:
return toggleGalleryVisibility();case _SetOutputFolder() when setOutputFolder != null:
return setOutputFolder(_that.outputFolder);case _ToggleDeleteOriginals() when toggleDeleteOriginals != null:
return toggleDeleteOriginals();case _Encrypt() when encrypt != null:
return encrypt();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<GalleryImage> images)  setup,required TResult Function( String password)  setPassword,required TResult Function()  toggleGalleryVisibility,required TResult Function( String outputFolder)  setOutputFolder,required TResult Function()  toggleDeleteOriginals,required TResult Function()  encrypt,}) {final _that = this;
switch (_that) {
case _Setup():
return setup(_that.images);case _SetPassword():
return setPassword(_that.password);case _ToggleGalleryVisibility():
return toggleGalleryVisibility();case _SetOutputFolder():
return setOutputFolder(_that.outputFolder);case _ToggleDeleteOriginals():
return toggleDeleteOriginals();case _Encrypt():
return encrypt();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<GalleryImage> images)?  setup,TResult? Function( String password)?  setPassword,TResult? Function()?  toggleGalleryVisibility,TResult? Function( String outputFolder)?  setOutputFolder,TResult? Function()?  toggleDeleteOriginals,TResult? Function()?  encrypt,}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that.images);case _SetPassword() when setPassword != null:
return setPassword(_that.password);case _ToggleGalleryVisibility() when toggleGalleryVisibility != null:
return toggleGalleryVisibility();case _SetOutputFolder() when setOutputFolder != null:
return setOutputFolder(_that.outputFolder);case _ToggleDeleteOriginals() when toggleDeleteOriginals != null:
return toggleDeleteOriginals();case _Encrypt() when encrypt != null:
return encrypt();case _:
  return null;

}
}

}

/// @nodoc


class _Setup extends EncryptionPageEvent {
  const _Setup({required final  List<GalleryImage> images}): _images = images,super._();
  

 final  List<GalleryImage> _images;
 List<GalleryImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}


/// Create a copy of EncryptionPageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupCopyWith<_Setup> get copyWith => __$SetupCopyWithImpl<_Setup>(this, _$identity);





@override
String toString() {
  return 'EncryptionPageEvent.setup(images: $images)';
}


}

/// @nodoc
abstract mixin class _$SetupCopyWith<$Res> implements $EncryptionPageEventCopyWith<$Res> {
  factory _$SetupCopyWith(_Setup value, $Res Function(_Setup) _then) = __$SetupCopyWithImpl;
@useResult
$Res call({
 List<GalleryImage> images
});




}
/// @nodoc
class __$SetupCopyWithImpl<$Res>
    implements _$SetupCopyWith<$Res> {
  __$SetupCopyWithImpl(this._self, this._then);

  final _Setup _self;
  final $Res Function(_Setup) _then;

/// Create a copy of EncryptionPageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? images = null,}) {
  return _then(_Setup(
images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<GalleryImage>,
  ));
}


}

/// @nodoc


class _SetPassword extends EncryptionPageEvent {
  const _SetPassword({required this.password}): super._();
  

 final  String password;

/// Create a copy of EncryptionPageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetPasswordCopyWith<_SetPassword> get copyWith => __$SetPasswordCopyWithImpl<_SetPassword>(this, _$identity);





@override
String toString() {
  return 'EncryptionPageEvent.setPassword(password: $password)';
}


}

/// @nodoc
abstract mixin class _$SetPasswordCopyWith<$Res> implements $EncryptionPageEventCopyWith<$Res> {
  factory _$SetPasswordCopyWith(_SetPassword value, $Res Function(_SetPassword) _then) = __$SetPasswordCopyWithImpl;
@useResult
$Res call({
 String password
});




}
/// @nodoc
class __$SetPasswordCopyWithImpl<$Res>
    implements _$SetPasswordCopyWith<$Res> {
  __$SetPasswordCopyWithImpl(this._self, this._then);

  final _SetPassword _self;
  final $Res Function(_SetPassword) _then;

/// Create a copy of EncryptionPageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? password = null,}) {
  return _then(_SetPassword(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ToggleGalleryVisibility extends EncryptionPageEvent {
  const _ToggleGalleryVisibility(): super._();
  








@override
String toString() {
  return 'EncryptionPageEvent.toggleGalleryVisibility()';
}


}




/// @nodoc


class _SetOutputFolder extends EncryptionPageEvent {
  const _SetOutputFolder({required this.outputFolder}): super._();
  

 final  String outputFolder;

/// Create a copy of EncryptionPageEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetOutputFolderCopyWith<_SetOutputFolder> get copyWith => __$SetOutputFolderCopyWithImpl<_SetOutputFolder>(this, _$identity);





@override
String toString() {
  return 'EncryptionPageEvent.setOutputFolder(outputFolder: $outputFolder)';
}


}

/// @nodoc
abstract mixin class _$SetOutputFolderCopyWith<$Res> implements $EncryptionPageEventCopyWith<$Res> {
  factory _$SetOutputFolderCopyWith(_SetOutputFolder value, $Res Function(_SetOutputFolder) _then) = __$SetOutputFolderCopyWithImpl;
@useResult
$Res call({
 String outputFolder
});




}
/// @nodoc
class __$SetOutputFolderCopyWithImpl<$Res>
    implements _$SetOutputFolderCopyWith<$Res> {
  __$SetOutputFolderCopyWithImpl(this._self, this._then);

  final _SetOutputFolder _self;
  final $Res Function(_SetOutputFolder) _then;

/// Create a copy of EncryptionPageEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? outputFolder = null,}) {
  return _then(_SetOutputFolder(
outputFolder: null == outputFolder ? _self.outputFolder : outputFolder // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ToggleDeleteOriginals extends EncryptionPageEvent {
  const _ToggleDeleteOriginals(): super._();
  








@override
String toString() {
  return 'EncryptionPageEvent.toggleDeleteOriginals()';
}


}




/// @nodoc


class _Encrypt extends EncryptionPageEvent {
  const _Encrypt(): super._();
  








@override
String toString() {
  return 'EncryptionPageEvent.encrypt()';
}


}




/// @nodoc
mixin _$EncryptionPageState {









}

/// @nodoc
class $EncryptionPageStateCopyWith<$Res>  {
$EncryptionPageStateCopyWith(EncryptionPageState _, $Res Function(EncryptionPageState) __);
}


/// Adds pattern-matching-related methods to [EncryptionPageState].
extension EncryptionPageStatePatterns on EncryptionPageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _UI value)?  ui,TResult Function( _SettingsUI value)?  settingsUi,TResult Function( _Encrypting value)?  encrypting,TResult Function( _Encrypted value)?  encrypted,TResult Function( _Failure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _UI() when ui != null:
return ui(_that);case _SettingsUI() when settingsUi != null:
return settingsUi(_that);case _Encrypting() when encrypting != null:
return encrypting(_that);case _Encrypted() when encrypted != null:
return encrypted(_that);case _Failure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _UI value)  ui,required TResult Function( _SettingsUI value)  settingsUi,required TResult Function( _Encrypting value)  encrypting,required TResult Function( _Encrypted value)  encrypted,required TResult Function( _Failure value)  failure,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _UI():
return ui(_that);case _SettingsUI():
return settingsUi(_that);case _Encrypting():
return encrypting(_that);case _Encrypted():
return encrypted(_that);case _Failure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _UI value)?  ui,TResult? Function( _SettingsUI value)?  settingsUi,TResult? Function( _Encrypting value)?  encrypting,TResult? Function( _Encrypted value)?  encrypted,TResult? Function( _Failure value)?  failure,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _UI() when ui != null:
return ui(_that);case _SettingsUI() when settingsUi != null:
return settingsUi(_that);case _Encrypting() when encrypting != null:
return encrypting(_that);case _Encrypted() when encrypted != null:
return encrypted(_that);case _Failure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<GalleryImage> images,  String size,  String dateTime)?  ui,TResult Function( bool galleryVisible,  String outputFolder,  bool deleteOriginals)?  settingsUi,TResult Function()?  encrypting,TResult Function()?  encrypted,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _UI() when ui != null:
return ui(_that.images,_that.size,_that.dateTime);case _SettingsUI() when settingsUi != null:
return settingsUi(_that.galleryVisible,_that.outputFolder,_that.deleteOriginals);case _Encrypting() when encrypting != null:
return encrypting();case _Encrypted() when encrypted != null:
return encrypted();case _Failure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<GalleryImage> images,  String size,  String dateTime)  ui,required TResult Function( bool galleryVisible,  String outputFolder,  bool deleteOriginals)  settingsUi,required TResult Function()  encrypting,required TResult Function()  encrypted,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _UI():
return ui(_that.images,_that.size,_that.dateTime);case _SettingsUI():
return settingsUi(_that.galleryVisible,_that.outputFolder,_that.deleteOriginals);case _Encrypting():
return encrypting();case _Encrypted():
return encrypted();case _Failure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<GalleryImage> images,  String size,  String dateTime)?  ui,TResult? Function( bool galleryVisible,  String outputFolder,  bool deleteOriginals)?  settingsUi,TResult? Function()?  encrypting,TResult? Function()?  encrypted,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _UI() when ui != null:
return ui(_that.images,_that.size,_that.dateTime);case _SettingsUI() when settingsUi != null:
return settingsUi(_that.galleryVisible,_that.outputFolder,_that.deleteOriginals);case _Encrypting() when encrypting != null:
return encrypting();case _Encrypted() when encrypted != null:
return encrypted();case _Failure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial extends EncryptionPageState {
  const _Initial(): super._();
  










}




/// @nodoc


class _Loading extends EncryptionPageState {
  const _Loading(): super._();
  










}




/// @nodoc


class _UI extends EncryptionPageState {
  const _UI({required final  List<GalleryImage> images, required this.size, required this.dateTime}): _images = images,super._();
  

 final  List<GalleryImage> _images;
 List<GalleryImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

 final  String size;
 final  String dateTime;

/// Create a copy of EncryptionPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UICopyWith<_UI> get copyWith => __$UICopyWithImpl<_UI>(this, _$identity);







}

/// @nodoc
abstract mixin class _$UICopyWith<$Res> implements $EncryptionPageStateCopyWith<$Res> {
  factory _$UICopyWith(_UI value, $Res Function(_UI) _then) = __$UICopyWithImpl;
@useResult
$Res call({
 List<GalleryImage> images, String size, String dateTime
});




}
/// @nodoc
class __$UICopyWithImpl<$Res>
    implements _$UICopyWith<$Res> {
  __$UICopyWithImpl(this._self, this._then);

  final _UI _self;
  final $Res Function(_UI) _then;

/// Create a copy of EncryptionPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? images = null,Object? size = null,Object? dateTime = null,}) {
  return _then(_UI(
images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<GalleryImage>,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _SettingsUI extends EncryptionPageState {
  const _SettingsUI({required this.galleryVisible, required this.outputFolder, required this.deleteOriginals}): super._();
  

 final  bool galleryVisible;
 final  String outputFolder;
 final  bool deleteOriginals;

/// Create a copy of EncryptionPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsUICopyWith<_SettingsUI> get copyWith => __$SettingsUICopyWithImpl<_SettingsUI>(this, _$identity);







}

/// @nodoc
abstract mixin class _$SettingsUICopyWith<$Res> implements $EncryptionPageStateCopyWith<$Res> {
  factory _$SettingsUICopyWith(_SettingsUI value, $Res Function(_SettingsUI) _then) = __$SettingsUICopyWithImpl;
@useResult
$Res call({
 bool galleryVisible, String outputFolder, bool deleteOriginals
});




}
/// @nodoc
class __$SettingsUICopyWithImpl<$Res>
    implements _$SettingsUICopyWith<$Res> {
  __$SettingsUICopyWithImpl(this._self, this._then);

  final _SettingsUI _self;
  final $Res Function(_SettingsUI) _then;

/// Create a copy of EncryptionPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? galleryVisible = null,Object? outputFolder = null,Object? deleteOriginals = null,}) {
  return _then(_SettingsUI(
galleryVisible: null == galleryVisible ? _self.galleryVisible : galleryVisible // ignore: cast_nullable_to_non_nullable
as bool,outputFolder: null == outputFolder ? _self.outputFolder : outputFolder // ignore: cast_nullable_to_non_nullable
as String,deleteOriginals: null == deleteOriginals ? _self.deleteOriginals : deleteOriginals // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _Encrypting extends EncryptionPageState {
  const _Encrypting(): super._();
  










}




/// @nodoc


class _Encrypted extends EncryptionPageState {
  const _Encrypted(): super._();
  










}




/// @nodoc


class _Failure extends EncryptionPageState {
  const _Failure({required this.message}): super._();
  

 final  String message;

/// Create a copy of EncryptionPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailureCopyWith<_Failure> get copyWith => __$FailureCopyWithImpl<_Failure>(this, _$identity);







}

/// @nodoc
abstract mixin class _$FailureCopyWith<$Res> implements $EncryptionPageStateCopyWith<$Res> {
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

/// Create a copy of EncryptionPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Failure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
