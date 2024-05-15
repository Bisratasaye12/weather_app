import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HourlyForcast extends StatelessWidget {
  final time;
  final temprature;
  final icon;

  const HourlyForcast(
      {super.key,
      required this.time,
      required this.temprature,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    final timeObj = DateTime.parse(time);
    final formatted_time = DateFormat.j().format(timeObj);
    return Card(
      elevation: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 80,
            child: Column(
              children: [
                Text(
                  formatted_time,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 8,
                ),
                Icon(
                  this.icon == 'Clouds' || this.icon == 'Rain'
                      ? Icons.cloud
                      : Icons.sunny,
                  size: 32,
                ),
                SizedBox(
                  height: 8,
                ),
                Text(temprature)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
