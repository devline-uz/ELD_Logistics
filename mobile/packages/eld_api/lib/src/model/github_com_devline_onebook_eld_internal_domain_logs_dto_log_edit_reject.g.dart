// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_logs_dto_log_edit_reject.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject
    extends GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject {
  @override
  final String reason;

  factory _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRejectBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRejectBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject._(
      {required this.reason})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRejectBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRejectBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRejectBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject')
          ..add('reason', reason))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRejectBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject,
            GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRejectBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRejectBuilder() {
    GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject._defaults(
        this);
  }

  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRejectBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject other) {
    _$v =
        other as _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditRejectBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason,
              r'GithubComDevlineOnebookEldInternalDomainLogsDtoLogEditReject',
              'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
