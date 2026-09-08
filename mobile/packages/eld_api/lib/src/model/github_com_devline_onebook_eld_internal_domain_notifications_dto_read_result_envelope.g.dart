// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_notifications_dto_read_result_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope
    extends GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResult?
      data;

  factory _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope
      rebuild(
              void Function(
                      GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope,
            GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder?
      _data;
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope
              ._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GithubComDevlineOnebookEldInternalDomainNotificationsDtoReadResultEnvelope',
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
