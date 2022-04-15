import 'package:ntp/ntp.dart';

class DateNTP {
  static DateNTP instance = new DateNTP();

  Future<DateTime> getTime() async {
    return await NTP.now();
  }
}
