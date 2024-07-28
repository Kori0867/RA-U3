import 'dart:async';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rtdata/pantallas/GTemp.dart';
import 'package:rtdata/pantallas/GHume.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AfterLayoutMixin<Home> {
  double humidity = 0, temperature = 0;
  bool isLoading = false;

  String get temperatureMessage {
    if (temperature < 0) {
      return "Hace frío";
    } else if (temperature <= 30) {
      return "Temperatura agradable";
    } else {
      return "Temperatura muy alta";
    }
  }

  Color get temperatureColor {
    if (temperature < 0) {
      return Colors.blue;
    } else if (temperature <= 30) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String get humidityMessage {
    if (humidity < 0) {
      return "Tiempo seco";
    } else if (humidity < 50) {
      return "Humedad media";
    } else {
      return "Humedad alta";
    }
  }

  Color get humidityColor {
    if (humidity < 0) {
      return Colors.brown;
    } else if (humidity < 50) {
      return Colors.yellow;
    } else {
      return Colors.purple;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Casa Milton"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              await getData();
              setState(() {
                isLoading = false;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: GTemp(temperatura: temperature)),
              const Divider(height: 5),
              Expanded(child: GHume(humedad: humidity)),
              const Divider(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Temperatura: $temperature"),
                  SizedBox(width: 20),
                  Text("Humedad: $humidity"),
                ],
              ),
              const Divider(height: 5),
              Container(
                padding: EdgeInsets.all(16),
                color: temperatureColor,
                child: Center(
                  child: Text(
                    temperatureMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                color: humidityColor,
                child: Center(
                  child: Text(
                    humidityMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    Timer.periodic(
      const Duration(seconds: 30), //duracion del tiempo
          (timer) async {
        await getData();
      },
    );
  }

  Future<void> getData() async {
    final ref = FirebaseDatabase.instance.ref();
    final temp = await ref.child("Living Room/temperature/value").get();
    final humi = await ref.child("Living Room/humidity/value").get();
    if (temp.exists && humi.exists) {
      setState(() {
        temperature = double.parse(temp.value.toString());
        humidity = double.parse(humi.value.toString());
      });
    } else {
      setState(() {
        temperature = -1;
        humidity = -1;
      });
    }
  }
}
