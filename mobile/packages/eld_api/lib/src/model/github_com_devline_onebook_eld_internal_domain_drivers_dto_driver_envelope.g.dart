// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_drivers_dto_driver_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainDriversDtoDriver? data;

  factory _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope,
            GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverBuilder get data =>
      _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainDriversDtoDriverBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainDriversDtoDriverBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoDriverEnvelope',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
