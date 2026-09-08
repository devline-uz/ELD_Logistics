// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_auth_dto_message_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope
    extends GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponse? data;

  factory _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope,
            GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainAuthDtoMessageResponseBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope _build() {
    _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainAuthDtoMessageEnvelope',
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
