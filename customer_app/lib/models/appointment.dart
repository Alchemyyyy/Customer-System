class Appointment {
  final int id;
  final int customerId;
  final String appointmentDate;
  final String appointmentTime;
  final String service;

  Appointment({
    required this.id,
    required this.customerId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.service,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      customerId: json['customer_id'],
      appointmentDate: json['appointment_date'],
      appointmentTime: json['appointment_time'],
      service: json['service'],
    );
  }
}
