import 'package:equatable/equatable.dart';

abstract class IncomingOrderState extends Equatable {
  const IncomingOrderState();

  @override
  List<Object?> get props => [];
}

class IncomingOrderIdle extends IncomingOrderState {
  const IncomingOrderIdle();
}

class IncomingOrderAccepting extends IncomingOrderState {
  const IncomingOrderAccepting();
}

class IncomingOrderRejecting extends IncomingOrderState {
  const IncomingOrderRejecting();
}

class IncomingOrderAccepted extends IncomingOrderState {
  const IncomingOrderAccepted();
}

class IncomingOrderRejected extends IncomingOrderState {
  const IncomingOrderRejected();
}

class IncomingOrderError extends IncomingOrderState {
  final String message;

  const IncomingOrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
