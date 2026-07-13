// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PurchaseEvent {







@override
String toString() {
  return 'PurchaseEvent()';
}


}

/// @nodoc
class $PurchaseEventCopyWith<$Res>  {
$PurchaseEventCopyWith(PurchaseEvent _, $Res Function(PurchaseEvent) __);
}


/// Adds pattern-matching-related methods to [PurchaseEvent].
extension PurchaseEventPatterns on PurchaseEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Setup value)?  setup,TResult Function( _LoadProducts value)?  loadProducts,TResult Function( _Buy value)?  buy,TResult Function( _Restore value)?  restore,TResult Function( _EntitlementChanged value)?  entitlementChanged,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _LoadProducts() when loadProducts != null:
return loadProducts(_that);case _Buy() when buy != null:
return buy(_that);case _Restore() when restore != null:
return restore(_that);case _EntitlementChanged() when entitlementChanged != null:
return entitlementChanged(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Setup value)  setup,required TResult Function( _LoadProducts value)  loadProducts,required TResult Function( _Buy value)  buy,required TResult Function( _Restore value)  restore,required TResult Function( _EntitlementChanged value)  entitlementChanged,}){
final _that = this;
switch (_that) {
case _Setup():
return setup(_that);case _LoadProducts():
return loadProducts(_that);case _Buy():
return buy(_that);case _Restore():
return restore(_that);case _EntitlementChanged():
return entitlementChanged(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Setup value)?  setup,TResult? Function( _LoadProducts value)?  loadProducts,TResult? Function( _Buy value)?  buy,TResult? Function( _Restore value)?  restore,TResult? Function( _EntitlementChanged value)?  entitlementChanged,}){
final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup(_that);case _LoadProducts() when loadProducts != null:
return loadProducts(_that);case _Buy() when buy != null:
return buy(_that);case _Restore() when restore != null:
return restore(_that);case _EntitlementChanged() when entitlementChanged != null:
return entitlementChanged(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  setup,TResult Function()?  loadProducts,TResult Function( ProProduct product)?  buy,TResult Function( bool silent)?  restore,TResult Function( ProEntitlement entitlement)?  entitlementChanged,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup();case _LoadProducts() when loadProducts != null:
return loadProducts();case _Buy() when buy != null:
return buy(_that.product);case _Restore() when restore != null:
return restore(_that.silent);case _EntitlementChanged() when entitlementChanged != null:
return entitlementChanged(_that.entitlement);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  setup,required TResult Function()  loadProducts,required TResult Function( ProProduct product)  buy,required TResult Function( bool silent)  restore,required TResult Function( ProEntitlement entitlement)  entitlementChanged,}) {final _that = this;
switch (_that) {
case _Setup():
return setup();case _LoadProducts():
return loadProducts();case _Buy():
return buy(_that.product);case _Restore():
return restore(_that.silent);case _EntitlementChanged():
return entitlementChanged(_that.entitlement);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  setup,TResult? Function()?  loadProducts,TResult? Function( ProProduct product)?  buy,TResult? Function( bool silent)?  restore,TResult? Function( ProEntitlement entitlement)?  entitlementChanged,}) {final _that = this;
switch (_that) {
case _Setup() when setup != null:
return setup();case _LoadProducts() when loadProducts != null:
return loadProducts();case _Buy() when buy != null:
return buy(_that.product);case _Restore() when restore != null:
return restore(_that.silent);case _EntitlementChanged() when entitlementChanged != null:
return entitlementChanged(_that.entitlement);case _:
  return null;

}
}

}

/// @nodoc


class _Setup extends PurchaseEvent {
  const _Setup(): super._();
  








@override
String toString() {
  return 'PurchaseEvent.setup()';
}


}




/// @nodoc


class _LoadProducts extends PurchaseEvent {
  const _LoadProducts(): super._();
  








@override
String toString() {
  return 'PurchaseEvent.loadProducts()';
}


}




/// @nodoc


class _Buy extends PurchaseEvent {
  const _Buy({required this.product}): super._();
  

 final  ProProduct product;

/// Create a copy of PurchaseEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuyCopyWith<_Buy> get copyWith => __$BuyCopyWithImpl<_Buy>(this, _$identity);





@override
String toString() {
  return 'PurchaseEvent.buy(product: $product)';
}


}

/// @nodoc
abstract mixin class _$BuyCopyWith<$Res> implements $PurchaseEventCopyWith<$Res> {
  factory _$BuyCopyWith(_Buy value, $Res Function(_Buy) _then) = __$BuyCopyWithImpl;
@useResult
$Res call({
 ProProduct product
});




}
/// @nodoc
class __$BuyCopyWithImpl<$Res>
    implements _$BuyCopyWith<$Res> {
  __$BuyCopyWithImpl(this._self, this._then);

  final _Buy _self;
  final $Res Function(_Buy) _then;

/// Create a copy of PurchaseEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? product = null,}) {
  return _then(_Buy(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProProduct,
  ));
}


}

/// @nodoc


class _Restore extends PurchaseEvent {
  const _Restore({this.silent = false}): super._();
  

@JsonKey() final  bool silent;

/// Create a copy of PurchaseEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestoreCopyWith<_Restore> get copyWith => __$RestoreCopyWithImpl<_Restore>(this, _$identity);





@override
String toString() {
  return 'PurchaseEvent.restore(silent: $silent)';
}


}

/// @nodoc
abstract mixin class _$RestoreCopyWith<$Res> implements $PurchaseEventCopyWith<$Res> {
  factory _$RestoreCopyWith(_Restore value, $Res Function(_Restore) _then) = __$RestoreCopyWithImpl;
@useResult
$Res call({
 bool silent
});




}
/// @nodoc
class __$RestoreCopyWithImpl<$Res>
    implements _$RestoreCopyWith<$Res> {
  __$RestoreCopyWithImpl(this._self, this._then);

  final _Restore _self;
  final $Res Function(_Restore) _then;

/// Create a copy of PurchaseEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? silent = null,}) {
  return _then(_Restore(
silent: null == silent ? _self.silent : silent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _EntitlementChanged extends PurchaseEvent {
  const _EntitlementChanged({required this.entitlement}): super._();
  

 final  ProEntitlement entitlement;

/// Create a copy of PurchaseEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntitlementChangedCopyWith<_EntitlementChanged> get copyWith => __$EntitlementChangedCopyWithImpl<_EntitlementChanged>(this, _$identity);





@override
String toString() {
  return 'PurchaseEvent.entitlementChanged(entitlement: $entitlement)';
}


}

/// @nodoc
abstract mixin class _$EntitlementChangedCopyWith<$Res> implements $PurchaseEventCopyWith<$Res> {
  factory _$EntitlementChangedCopyWith(_EntitlementChanged value, $Res Function(_EntitlementChanged) _then) = __$EntitlementChangedCopyWithImpl;
@useResult
$Res call({
 ProEntitlement entitlement
});




}
/// @nodoc
class __$EntitlementChangedCopyWithImpl<$Res>
    implements _$EntitlementChangedCopyWith<$Res> {
  __$EntitlementChangedCopyWithImpl(this._self, this._then);

  final _EntitlementChanged _self;
  final $Res Function(_EntitlementChanged) _then;

/// Create a copy of PurchaseEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entitlement = null,}) {
  return _then(_EntitlementChanged(
entitlement: null == entitlement ? _self.entitlement : entitlement // ignore: cast_nullable_to_non_nullable
as ProEntitlement,
  ));
}


}

/// @nodoc
mixin _$PurchaseState {









}

/// @nodoc
class $PurchaseStateCopyWith<$Res>  {
$PurchaseStateCopyWith(PurchaseState _, $Res Function(PurchaseState) __);
}


/// Adds pattern-matching-related methods to [PurchaseState].
extension PurchaseStatePatterns on PurchaseState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Entitlement value)?  entitlement,TResult Function( _LoadingProducts value)?  loadingProducts,TResult Function( _Products value)?  products,TResult Function( _Purchasing value)?  purchasing,TResult Function( _Restoring value)?  restoring,TResult Function( _Restored value)?  restored,TResult Function( _Failure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Entitlement() when entitlement != null:
return entitlement(_that);case _LoadingProducts() when loadingProducts != null:
return loadingProducts(_that);case _Products() when products != null:
return products(_that);case _Purchasing() when purchasing != null:
return purchasing(_that);case _Restoring() when restoring != null:
return restoring(_that);case _Restored() when restored != null:
return restored(_that);case _Failure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Entitlement value)  entitlement,required TResult Function( _LoadingProducts value)  loadingProducts,required TResult Function( _Products value)  products,required TResult Function( _Purchasing value)  purchasing,required TResult Function( _Restoring value)  restoring,required TResult Function( _Restored value)  restored,required TResult Function( _Failure value)  failure,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Entitlement():
return entitlement(_that);case _LoadingProducts():
return loadingProducts(_that);case _Products():
return products(_that);case _Purchasing():
return purchasing(_that);case _Restoring():
return restoring(_that);case _Restored():
return restored(_that);case _Failure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Entitlement value)?  entitlement,TResult? Function( _LoadingProducts value)?  loadingProducts,TResult? Function( _Products value)?  products,TResult? Function( _Purchasing value)?  purchasing,TResult? Function( _Restoring value)?  restoring,TResult? Function( _Restored value)?  restored,TResult? Function( _Failure value)?  failure,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Entitlement() when entitlement != null:
return entitlement(_that);case _LoadingProducts() when loadingProducts != null:
return loadingProducts(_that);case _Products() when products != null:
return products(_that);case _Purchasing() when purchasing != null:
return purchasing(_that);case _Restoring() when restoring != null:
return restoring(_that);case _Restored() when restored != null:
return restored(_that);case _Failure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( ProEntitlement entitlement)?  entitlement,TResult Function()?  loadingProducts,TResult Function( List<ProProduct> products)?  products,TResult Function()?  purchasing,TResult Function()?  restoring,TResult Function( bool restoredPro)?  restored,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Entitlement() when entitlement != null:
return entitlement(_that.entitlement);case _LoadingProducts() when loadingProducts != null:
return loadingProducts();case _Products() when products != null:
return products(_that.products);case _Purchasing() when purchasing != null:
return purchasing();case _Restoring() when restoring != null:
return restoring();case _Restored() when restored != null:
return restored(_that.restoredPro);case _Failure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( ProEntitlement entitlement)  entitlement,required TResult Function()  loadingProducts,required TResult Function( List<ProProduct> products)  products,required TResult Function()  purchasing,required TResult Function()  restoring,required TResult Function( bool restoredPro)  restored,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Entitlement():
return entitlement(_that.entitlement);case _LoadingProducts():
return loadingProducts();case _Products():
return products(_that.products);case _Purchasing():
return purchasing();case _Restoring():
return restoring();case _Restored():
return restored(_that.restoredPro);case _Failure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( ProEntitlement entitlement)?  entitlement,TResult? Function()?  loadingProducts,TResult? Function( List<ProProduct> products)?  products,TResult? Function()?  purchasing,TResult? Function()?  restoring,TResult? Function( bool restoredPro)?  restored,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Entitlement() when entitlement != null:
return entitlement(_that.entitlement);case _LoadingProducts() when loadingProducts != null:
return loadingProducts();case _Products() when products != null:
return products(_that.products);case _Purchasing() when purchasing != null:
return purchasing();case _Restoring() when restoring != null:
return restoring();case _Restored() when restored != null:
return restored(_that.restoredPro);case _Failure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial extends PurchaseState {
  const _Initial(): super._();
  










}




/// @nodoc


class _Entitlement extends PurchaseState {
  const _Entitlement({required this.entitlement}): super._();
  

 final  ProEntitlement entitlement;

/// Create a copy of PurchaseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntitlementCopyWith<_Entitlement> get copyWith => __$EntitlementCopyWithImpl<_Entitlement>(this, _$identity);







}

/// @nodoc
abstract mixin class _$EntitlementCopyWith<$Res> implements $PurchaseStateCopyWith<$Res> {
  factory _$EntitlementCopyWith(_Entitlement value, $Res Function(_Entitlement) _then) = __$EntitlementCopyWithImpl;
@useResult
$Res call({
 ProEntitlement entitlement
});




}
/// @nodoc
class __$EntitlementCopyWithImpl<$Res>
    implements _$EntitlementCopyWith<$Res> {
  __$EntitlementCopyWithImpl(this._self, this._then);

  final _Entitlement _self;
  final $Res Function(_Entitlement) _then;

/// Create a copy of PurchaseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entitlement = null,}) {
  return _then(_Entitlement(
entitlement: null == entitlement ? _self.entitlement : entitlement // ignore: cast_nullable_to_non_nullable
as ProEntitlement,
  ));
}


}

/// @nodoc


class _LoadingProducts extends PurchaseState {
  const _LoadingProducts(): super._();
  










}




/// @nodoc


class _Products extends PurchaseState {
  const _Products({required final  List<ProProduct> products}): _products = products,super._();
  

 final  List<ProProduct> _products;
 List<ProProduct> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of PurchaseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductsCopyWith<_Products> get copyWith => __$ProductsCopyWithImpl<_Products>(this, _$identity);







}

/// @nodoc
abstract mixin class _$ProductsCopyWith<$Res> implements $PurchaseStateCopyWith<$Res> {
  factory _$ProductsCopyWith(_Products value, $Res Function(_Products) _then) = __$ProductsCopyWithImpl;
@useResult
$Res call({
 List<ProProduct> products
});




}
/// @nodoc
class __$ProductsCopyWithImpl<$Res>
    implements _$ProductsCopyWith<$Res> {
  __$ProductsCopyWithImpl(this._self, this._then);

  final _Products _self;
  final $Res Function(_Products) _then;

/// Create a copy of PurchaseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? products = null,}) {
  return _then(_Products(
products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<ProProduct>,
  ));
}


}

/// @nodoc


class _Purchasing extends PurchaseState {
  const _Purchasing(): super._();
  










}




/// @nodoc


class _Restoring extends PurchaseState {
  const _Restoring(): super._();
  










}




/// @nodoc


class _Restored extends PurchaseState {
  const _Restored({required this.restoredPro}): super._();
  

 final  bool restoredPro;

/// Create a copy of PurchaseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestoredCopyWith<_Restored> get copyWith => __$RestoredCopyWithImpl<_Restored>(this, _$identity);







}

/// @nodoc
abstract mixin class _$RestoredCopyWith<$Res> implements $PurchaseStateCopyWith<$Res> {
  factory _$RestoredCopyWith(_Restored value, $Res Function(_Restored) _then) = __$RestoredCopyWithImpl;
@useResult
$Res call({
 bool restoredPro
});




}
/// @nodoc
class __$RestoredCopyWithImpl<$Res>
    implements _$RestoredCopyWith<$Res> {
  __$RestoredCopyWithImpl(this._self, this._then);

  final _Restored _self;
  final $Res Function(_Restored) _then;

/// Create a copy of PurchaseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? restoredPro = null,}) {
  return _then(_Restored(
restoredPro: null == restoredPro ? _self.restoredPro : restoredPro // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _Failure extends PurchaseState {
  const _Failure({required this.message}): super._();
  

 final  String message;

/// Create a copy of PurchaseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailureCopyWith<_Failure> get copyWith => __$FailureCopyWithImpl<_Failure>(this, _$identity);







}

/// @nodoc
abstract mixin class _$FailureCopyWith<$Res> implements $PurchaseStateCopyWith<$Res> {
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

/// Create a copy of PurchaseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Failure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
