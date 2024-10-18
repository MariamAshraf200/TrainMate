import 'entit.dart';

List<int> mapDailyWeatherToModelInput(DailyWeather dailyWeather) {
  int isRainy = dailyWeather.condition.toLowerCase().contains('rain') ? 1 : 0;
  int isSunny = dailyWeather.condition.toLowerCase().contains('sun') ? 1 : 0;
  int isHot = dailyWeather.maxTempC >= 30 ? 1 : 0;
  int isMild =
      (dailyWeather.maxTempC >= 20 && dailyWeather.maxTempC < 30) ? 1 : 0;
  int isHumidityNormal = 1;
  return [isRainy, isSunny, isHot, isMild, isHumidityNormal];
}
