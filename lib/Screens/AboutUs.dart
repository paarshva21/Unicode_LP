import 'package:flutter/material.dart';

//About Us page, giving info about me and the API
class AboutUs extends StatefulWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
        backgroundColor: Colors.green,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Expanded(
          child: Column(
            children: [
              Text(
                "About the developer",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.0),
              ),
              Padding(padding: EdgeInsets.all(5)),
              Text(
                "Larder: The ultimate Food Recipe App was developed by Paarshva Chitaliya,who is currently pursuing a Computer Engineering degree from Dwarkadas J. Sanghvi College of Engineering. "
                "He hopes this recipe app enables its users to fulfill and nurture their love of cooking to the fullest extent. In his spare time, he will be found either kicking a football or listening to music.",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w300),
              ),
              Padding(padding: EdgeInsets.all(5)),
              Divider(
                color: Colors.black,
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
              Padding(padding: EdgeInsets.all(5)),
              Text(
                "About the API",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.0),
              ),
              Padding(padding: EdgeInsets.all(5)),
              Text(
                "The API used to fetch various recipes in this app is the free to use Spoonacular API. As they say on their website, \"spoonacular will be the first food management system that combines dining out, eating store-bought food, and cooking at home to help you find and organize the restaurants, products, and recipes that fit your diet and can help you reach your nutrition goals.\"",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w300),
              ),
              Padding(padding: EdgeInsets.all(5)),
              Divider(
                color: Colors.black,
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
