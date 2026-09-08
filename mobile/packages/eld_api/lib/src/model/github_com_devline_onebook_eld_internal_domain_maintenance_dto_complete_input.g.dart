// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_com_devline_onebook_eld_internal_domain_maintenance_dto_complete_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput
    extends GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput {
  @override
  final num? cost;
  @override
  final String? currency;
  @override
  final String? invoiceKey;
  @override
  final String? invoiceNo;
  @override
  final String? notes;
  @override
  final DateTime? performedAt;
  @override
  final String? vendor;

  factory _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput(
          [void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder)?
              updates]) =>
      (GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder()
            ..update(updates))
          ._build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput._(
      {this.cost,
      this.currency,
      this.invoiceKey,
      this.invoiceNo,
      this.notes,
      this.performedAt,
      this.vendor})
      : super._();
  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput rebuild(
          void Function(
                  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder
      toBuilder() =>
          GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput &&
        cost == other.cost &&
        currency == other.currency &&
        invoiceKey == other.invoiceKey &&
        invoiceNo == other.invoiceNo &&
        notes == other.notes &&
        performedAt == other.performedAt &&
        vendor == other.vendor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cost.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, invoiceKey.hashCode);
    _$hash = $jc(_$hash, invoiceNo.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, performedAt.hashCode);
    _$hash = $jc(_$hash, vendor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput')
          ..add('cost', cost)
          ..add('currency', currency)
          ..add('invoiceKey', invoiceKey)
          ..add('invoiceNo', invoiceNo)
          ..add('notes', notes)
          ..add('performedAt', performedAt)
          ..add('vendor', vendor))
        .toString();
  }
}

class GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder
    implements
        Builder<
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput,
            GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder> {
  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput? _$v;

  num? _cost;
  num? get cost => _$this._cost;
  set cost(num? cost) => _$this._cost = cost;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  String? _invoiceKey;
  String? get invoiceKey => _$this._invoiceKey;
  set invoiceKey(String? invoiceKey) => _$this._invoiceKey = invoiceKey;

  String? _invoiceNo;
  String? get invoiceNo => _$this._invoiceNo;
  set invoiceNo(String? invoiceNo) => _$this._invoiceNo = invoiceNo;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  DateTime? _performedAt;
  DateTime? get performedAt => _$this._performedAt;
  set performedAt(DateTime? performedAt) => _$this._performedAt = performedAt;

  String? _vendor;
  String? get vendor => _$this._vendor;
  set vendor(String? vendor) => _$this._vendor = vendor;

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder() {
    GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput
        ._defaults(this);
  }

  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _cost = $v.cost;
      _currency = $v.currency;
      _invoiceKey = $v.invoiceKey;
      _invoiceNo = $v.invoiceNo;
      _notes = $v.notes;
      _performedAt = $v.performedAt;
      _vendor = $v.vendor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput
          other) {
    _$v = other
        as _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput;
  }

  @override
  void update(
      void Function(
              GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInputBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput build() =>
      _build();

  _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput
      _build() {
    final _$result = _$v ??
        _$GithubComDevlineOnebookEldInternalDomainMaintenanceDtoCompleteInput._(
          cost: cost,
          currency: currency,
          invoiceKey: invoiceKey,
          invoiceNo: invoiceNo,
          notes: notes,
          performedAt: performedAt,
          vendor: vendor,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
