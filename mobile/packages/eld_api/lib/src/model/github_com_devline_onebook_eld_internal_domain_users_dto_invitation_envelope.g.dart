// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_users_dto_invitation_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope
    extends GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSent? data;

  factory _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope,
            GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope? _$v;

  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationSentBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainUsersDtoInvitationEnvelope',
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
