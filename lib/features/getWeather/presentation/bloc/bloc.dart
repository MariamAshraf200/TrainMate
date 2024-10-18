
import 'package:check_weather/features/getWeather/presentation/bloc/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/Usecase/Prediction_usecase.dart';
import '../../domain/Usecase/Weather_usecase.dart';
import 'event.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetWeatherUseCase getWeatherUseCase;
  final GetTennisPredictionUseCase getTennisPredictionUseCase;

  WeatherBloc({
    required this.getTennisPredictionUseCase,
    required this.getWeatherUseCase,
  }) : super(WeatherInitial()) {

    on<GetWeatherEvent>((event, emit) async {
      emit(WeatherLoading());
      try {
        // Fetch weather data
        final weather = await getWeatherUseCase.call(event.latitude, event.longitude);

        // Get AI prediction based on weather

        // Emit weather and prediction to UI
        emit(WeatherLoaded(weather));
      } catch (e) {
        emit(WeatherError(e.toString()));
      }
    });
  }
}
