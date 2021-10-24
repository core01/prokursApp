import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prokurs/models/arguments/ratesScreenArguments.dart';
import 'package:prokurs/models/city.dart';
import 'package:prokurs/pages/rates.dart';

class HomePage extends StatefulWidget {
  // const Home({ Key? key }) : super(key: key);
  static const routeName = '/';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  var cities = [
    City(id: 3, title: 'Нур-Султан'),
    City(id: 2, title: 'Алматы'),
    City(id: 4, title: 'Усть-Каменогорск'),
    City(id: 6, title: 'Риддер'),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ...cities.map(
                  (city) => ElevatedButton(
                    child: Text(city.title),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        RatesPage.routeName,
                        arguments: RatesScreenArguments(city),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
