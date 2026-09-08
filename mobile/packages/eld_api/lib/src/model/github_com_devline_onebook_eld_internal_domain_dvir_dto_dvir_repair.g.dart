// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_dvir_dto_dvir_repair.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair
    extends GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair {
  @override
  final num? cost;
  @override
  final String? invoiceKey;
  @override
  final String? invoiceNo;
  @override
  final String mechanicNote;
  @override
  final String mechanicSignatureKey;
  @override
  final String? vendor;

  factory _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair._(
      {this.cost,
      this.invoiceKey,
      this.invoiceNo,
      required this.mechanicNote,
      required this.mechanicSignatureKey,
      this.vendor})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair &&
        cost == other.cost &&
        invoiceKey == other.invoiceKey &&
        invoiceNo == other.invoiceNo &&
        mechanicNote == other.mechanicNote &&
        mechanicSignatureKey == other.mechanicSignatureKey &&
        vendor == other.vendor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cost.hashCode);
    _$hash = $jc(_$hash, invoiceKey.hashCode);
    _$hash = $jc(_$hash, invoiceNo.hashCode);
    _$hash = $jc(_$hash, mechanicNote.hashCode);
    _$hash = $jc(_$hash, mechanicSignatureKey.hashCode);
    _$hash = $jc(_$hash, vendor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair')
          ..add('cost', cost)
          ..add('invoiceKey', invoiceKey)
          ..add('invoiceNo', invoiceNo)
          ..add('mechanicNote', mechanicNote)
          ..add('mechanicSignatureKey', mechanicSignatureKey)
          ..add('vendor', vendor))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder
    implements
        Builder<GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair,
            GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair? _$v;

  num? _cost;
  num? get cost => _$this._cost;
  set cost(num? cost) => _$this._cost = cost;

  String? _invoiceKey;
  String? get invoiceKey => _$this._invoiceKey;
  set invoiceKey(String? invoiceKey) => _$this._invoiceKey = invoiceKey;

  String? _invoiceNo;
  String? get invoiceNo => _$this._invoiceNo;
  set invoiceNo(String? invoiceNo) => _$this._invoiceNo = invoiceNo;

  String? _mechanicNote;
  String? get mechanicNote => _$this._mechanicNote;
  set mechanicNote(String? mechanicNote) => _$this._mechanicNote = mechanicNote;

  String? _mechanicSignatureKey;
  String? get mechanicSignatureKey => _$this._mechanicSignatureKey;
  set mechanicSignatureKey(String? mechanicSignatureKey) =>
      _$this._mechanicSignatureKey = mechanicSignatureKey;

  String? _vendor;
  String? get vendor => _$this._vendor;
  set vendor(String? vendor) => _$this._vendor = vendor;

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder() {
    GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cost = $v.cost;
      _invoiceKey = $v.invoiceKey;
      _invoiceNo = $v.invoiceNo;
      _mechanicNote = $v.mechanicNote;
      _mechanicSignatureKey = $v.mechanicSignatureKey;
      _vendor = $v.vendor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair other) {
    _$v = other as _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepairBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair build() => _build();

  _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair._(
          cost: cost,
          invoiceKey: invoiceKey,
          invoiceNo: invoiceNo,
          mechanicNote: BuiltValueNullFieldError.checkNotNull(
              mechanicNote,
              r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair',
              'mechanicNote'),
          mechanicSignatureKey: BuiltValueNullFieldError.checkNotNull(
              mechanicSignatureKey,
              r'GithubComDevlineOnebookEldInternalDomainDvirDtoDvirRepair',
              'mechanicSignatureKey'),
          vendor: vendor,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
