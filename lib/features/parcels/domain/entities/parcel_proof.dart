import '../../../../core/services/location/device_location.dart';

/// How the Driver proves a parcel was handed over (`proof_type`, API docs
/// §13) — the same two proofs as normal orders.
sealed class ParcelProof {
  const ParcelProof();
}

/// The six-digit code the recipient shows. Sent once, never stored.
class ParcelOtpProof extends ParcelProof {
  final String otp;

  const ParcelOtpProof(this.otp);
}

/// The device's position at handover.
class ParcelLocationProof extends ParcelProof {
  final DeviceLocation location;

  const ParcelLocationProof(this.location);
}
