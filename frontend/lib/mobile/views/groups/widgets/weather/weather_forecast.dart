import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'weather_card.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WeatherForecast extends StatelessWidget {
  final List<Weather> data;

  const WeatherForecast({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CarouselSlider.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index, int realIndex) {
          return WeatherCard(weather: data[index]);
        },
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height * 0.4  ,
          enableInfiniteScroll: false,
          initialPage: 1,
          viewportFraction: 0.35,
          enlargeCenterPage: false,
          scrollDirection: Axis.horizontal,
          autoPlay: false,
        ),
      ),
    );
  }
}
