import 'package:flutter/material.dart';

class GradesList extends StatefulWidget {
  const GradesList({super.key});

  @override
  State<GradesList> createState() => _GradesListState();
}

class _GradesListState extends State<GradesList> {
  Map overviewScreenData = {};
  List<Map<String, dynamic>> gradesList = [];

  double screenHeight = 0;
  double screenWidth = 0;

  // Helper method to get icons based on grade weight
  Icon _getGradeIcon(double weight) {
    if (weight <= 1) {
      return Icon(Icons.school_outlined, color: Colors.black); // Small weight
    } else if (weight <= 3) {
      return Icon(Icons.school_rounded, color: Colors.black54); // Medium weight
    } else {
      return Icon(Icons.school, color: Colors.black); // High weight
    }
  }

  String formatNumber(double number) {
    return number % 1 == 0
        ? number.toInt().toString()
        : number.toString().replaceAll('.', ',');
  }

  Widget getGradesWeightedAverage(List<Map<String, dynamic>> databaseResponse) {
    if (databaseResponse.isEmpty) {
      return Text("Žádné známky", style: TextStyle(fontSize: 10));
    }

    double weightedValue = 0.0;
    double totalWeight = 0.0;

    List graphicValue = [];
    List graphicWeight = [];

    for (var doc in databaseResponse) {
      int value = (doc["value"] ?? 0).toInt();
      double weight = (doc["weight"] ?? 1).toDouble();

      weightedValue += value * weight;
      totalWeight += weight;

      graphicValue.add("$value*${formatNumber(weight)}");
      graphicWeight.add(formatNumber(weight));
    }
    double average = (totalWeight > 0) ? (weightedValue / totalWeight) : 0;

    String finalValue = graphicValue.join(" + ");
    String finalWeight = graphicWeight.join(" + ");

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                finalValue,
                style: TextStyle(fontSize: 12),
              ),
              Divider(
                  thickness: 1,
                  color: Colors.black,
                  height: screenHeight * 0.03),
              Text(
                finalWeight,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Text("="),
        SizedBox(width: 8),
        Text(average.toStringAsFixed(2)),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    // This method is called after initState() and guarantees that the context is fully available for use.
    super.didChangeDependencies();
    if (overviewScreenData.isEmpty) {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
      overviewScreenData = ModalRoute.of(context)!.settings.arguments as Map;
      gradesList = overviewScreenData["gradesList"] ?? [];
      print("Hej ted jsem v subjectu ${overviewScreenData} ${gradesList}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Subject: ${overviewScreenData["subject"] ?? " "}"),
        backgroundColor: Colors.deepOrangeAccent[100],
      ),
      body: (gradesList.isEmpty)
          ? Center(child: Text('No homeworks available'))
          : Column(children: [
              Expanded(
                child: (gradesList.isEmpty)
                    ? Center(child: Text("No grades available"))
                    : ListView.builder(
                        itemCount: gradesList.length, // Number of items to display
                        itemBuilder: (context, index) {
                          //final student = gradesList[index];
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ListTile(
                                leading:
                                    _getGradeIcon(gradesList[index]["weight"]),
                                title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          (gradesList[index]["message"].length > 23) ? "${gradesList[index]["message"].substring(0, 24)}.." : gradesList[index]["message"],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Text(
                                          "weight: ${gradesList[index]["weight"]}x",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontFamily: "Lato",
                                          ))
                                    ]),
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${gradesList[index]["value"]}"),
                                    Text("${gradesList[index]["teacherShort"]}"),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, "/home/grades/seeGrade",
                                      arguments: {
                                        "myUser": overviewScreenData["myUser"],
                                        "gradeMap": gradesList[index],
                                        "subject": overviewScreenData["subject"],
                                      });
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(13),
                color: Colors.grey[300],
                child: Center(
                    child: getGradesWeightedAverage(overviewScreenData["gradesList"])),
              ),
            ]),
    );
  }
}
