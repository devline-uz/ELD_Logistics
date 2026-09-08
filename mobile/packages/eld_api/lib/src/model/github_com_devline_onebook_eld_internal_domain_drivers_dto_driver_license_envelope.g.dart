// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_drivers_dto_driver_license_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope
    extends GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope {
  @override
  final GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicense? data;

  factory _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope._(
      {this.data})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope &&
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
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope')
          ..add('data', data))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope,
            GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope?
      _$v;

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder? _data;
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder
      get data => _$this._data ??=
          GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder();
  set data(
          GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseBuilder?
              data) =>
      _$this._data = data;

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder() {
    GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder
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
      GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelopeBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope
      build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope
      _build() {
    _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope
        _$result;
    try {
      _$result = _$v ??
          _$GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope
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
            r'GithubComDevlineOnebookEldInternalDomainDriversDtoDriverLicenseEnvelope',
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
