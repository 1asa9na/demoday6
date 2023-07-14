import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:sample_statistics/sample_statistics.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  http.Response? response;
  bool getBreathability = false;
  bool getTextileType = true;
  String? bytes;
  String report = "";

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("clothview.ru"),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.person_2_sharp)),
          ],
        ),
        body: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Text("Показать в результате следующие поля:"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: CheckboxListTile(
                      value: getTextileType,
                      onChanged: (value) => setState(
                        () => {getTextileType = !getTextileType},
                      ),
                      title: Text("Тип материала"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: CheckboxListTile(
                      value: getBreathability,
                      onChanged: (value) => setState(
                        () => {getBreathability = !getBreathability},
                      ),
                      title: Text("Воздухопроницаемость"),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(report),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: FloatingActionButton(
                  onPressed: getFromGallery,
                  child: Icon(Icons.add_sharp),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: FloatingActionButton(
                  onPressed: () => setState(() => composeReport()),
                  child: Icon(Icons.send_sharp),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: bytes != null
            ? BottomAppBar(
                child: Text(base64Decode(bytes!).lengthInBytes / 1048576 > 1
                    ? '${num.parse((base64Decode(bytes!).lengthInBytes / 1048576).toStringAsFixed(2))} MB'
                    : '${num.parse((base64Decode(bytes!).lengthInBytes / 1024).toStringAsFixed(2))} KB'))
            : null,
      );

  Future<void> classifier(String bytes) async {
    http.Response response = await http.post(
      Uri.parse("https://clothview.ru/api/ml/classifier"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'image': bytes}),
    );
    this.response = jsonDecode(response.body);
  }

  double mockBreathability(String bytes) {
    return truncatedNormalSample(1, 0, 1000, 500, 300, seed: bytes.hashCode)[0];
  }

  void getFromGallery() async {
    final list = await ImagePickerWeb.getImageAsBytes();
    if (list != null) {
      setState(
        () {
          bytes = base64Encode(list);
        },
      );
    }
  }

  void composeReport() {
    classifier(bytes!);
    String report = "";
    String? textileType = getTextileType
        ? response != null && response!.statusCode == 200
            ? jsonDecode(response!.body)[0]['result'] == 'tricot'
                ? 'трикотаж'
                : jsonDecode(response!.body)[0]['result'] == 'cloth'
                    ? 'ткань'
                    : jsonDecode(response!.body)[0]['result']
            : "неизвестно"
        : null;
    String? breathability =
        getBreathability ? mockBreathability(bytes!).toString() : null;
    report += textileType != null ? "Тип ткани: $textileType\n" : "";
    report +=
        breathability != null ? "Воздухопроницаемость: $breathability\n" : "";
    this.report = report;
  }
}
