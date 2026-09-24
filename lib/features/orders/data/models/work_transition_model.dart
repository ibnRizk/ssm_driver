import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/current_work.dart';
import '../../domain/entities/work_transition.dart';

class WorkTransitionModel extends WorkTransition {
  const WorkTransitionModel({
    required super.orderId,
    required super.status,
    required super.statusVersion,
    super.isReplay,
  });

  factory WorkTransitionModel.fromJson(Map<String, dynamic> json) {
    return WorkTransitionModel(
      orderId: readInt(json['order_id']),
      status: WorkStatus.fromApi(json['ssm_status'] as String?),
      statusVersion: readInt(json['ssm_status_version']),
      isReplay: json['idempotent_replay'] == true,
    );
  }
}
