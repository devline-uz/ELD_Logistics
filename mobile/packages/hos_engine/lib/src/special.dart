// Port of backend/internal/hos/special.go (Q4.1, Q4.2, Q4.3, Q5).
import 'model.dart';
import 'policy.dart';

/// Go: `EffectiveStatus` — maps a raw status plus special mode to the status
/// used by the HOS math. Q4.1: PC movement is OFF, not DR. Q4.2: YM is ON.
DutyStatus? effectiveStatus(DutyStatus? s, Special sp) {
  switch (sp) {
    case Special.pc:
      return DutyStatus.off;
    case Special.ym:
      return DutyStatus.on;
    case Special.none:
      return s;
  }
}

/// Go: `CountsAsDriving` — does the segment consume the DRIVE counter?
/// Q4.1: PC does not. Q4.2: YM does not (it only consumes SHIFT).
bool countsAsDriving(DutyStatus? s, Special sp) => effectiveStatus(s, sp) == DutyStatus.dr;

/// Go: `CountsAsOnDuty` — does the segment consume SHIFT and CYCLE (Q10.5)?
bool countsAsOnDuty(DutyStatus? s, Special sp) {
  final e = effectiveStatus(s, sp);
  return e == DutyStatus.on || e == DutyStatus.dr;
}

/// Go: `ShouldStartDriving` — the auto-DR rule: ECM (or GPS fallback) speed at
/// or above `motion_threshold_kmh` starts driving (Q5).
bool shouldStartDriving(double speedKmh, HosPolicy p) => speedKmh >= p.motionThresholdKmh;

/// Go: `ShouldExitYardMove` — yard move must end and switch to DR because speed
/// exceeded `ym_max_speed_kmh` (Q4.2).
bool shouldExitYardMove(double speedKmh, HosPolicy p) => speedKmh > p.ymMaxSpeedKmh;

/// Go: `SpecialAllowed` — does the company policy allow the special mode (Q4)?
bool specialAllowed(Special sp, HosPolicy p) {
  switch (sp) {
    case Special.pc:
      return p.allowPc;
    case Special.ym:
      return p.allowYm;
    case Special.none:
      return true;
  }
}

/// Go: `normalizeStatus` — unit capability rules. Q4.3: without a sleeper berth
/// SB cannot be selected, so such records are treated as OFF. Disallowed
/// special modes fall back to the plain status.
({DutyStatus? status, Special special}) normalizeStatus(DutyStatus? s, Special sp, HosPolicy p) {
  var special = sp;
  var status = s;
  if (!specialAllowed(special, p)) special = Special.none;
  if (status == DutyStatus.sb && !p.sleeperBerthAvailable) {
    status = DutyStatus.off;
  }
  return (status: status, special: special);
}
