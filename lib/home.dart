import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tarea_layouts/news.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Welcome>> welcomesFuture = getWelcomes();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          elevation: 0,
          leading: const Icon(Icons.menu),
          title: const Text("Tesla News"),
          actions: const [
            IconButton(
              onPressed: null,
              icon: Icon(Icons.search),
              color: Colors.white,
            ),
            IconButton(onPressed: null, icon: Icon(Icons.more_vert))
          ],
        ),
        body: Center(
            child: FutureBuilder(
                future: welcomesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    final welcomes = snapshot.data!;
                    return buildWelcomes(welcomes);
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    return const Text("Data not found");
                  }
                })
                ),
        backgroundColor: const Color.fromARGB(255, 206, 206, 206),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //reload
            setState(() {
              welcomesFuture = getWelcomes();
            });
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.refresh),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const BottomAppBar(
          height: 46,
          color: Colors.black,
          shape: CircularNotchedRectangle(),
          notchMargin: 10,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.home, color: Colors.white),
              Icon(Icons.search, color: Color.fromARGB(255, 206, 206, 206)),
              Icon(Icons.favorite, color: Colors.white),
            ],
          ),
        ));
  }

  static Future<List<Welcome>> getWelcomes() async {
  var url = Uri.parse("https://newsapi.org/v2/everything?q=tesla&from=2023-10-05&sortBy=publishedAt&apiKey=3014713cd1554a41af33fbf2c451dc06");
  final response = await http.get(url, headers: {"Content-Type": "application/json"});
  
  if (response.statusCode == 200) {
    final List<Map<String, dynamic>> data = (json.decode(response.body)["articles"] as List).cast<Map<String, dynamic>>();
    
    return data.map((e) => Welcome.fromJson(e)).toList();
  } else {
    throw Exception("Error al llamar a la API: ${response.statusCode}");
  }
}

}





Widget buildWelcomes(List<Welcome> welcomes) {
  return ListView.separated(
    itemCount: welcomes.length,
    itemBuilder: (BuildContext context, int index) {
      final welcome = welcomes[index];
      final formattedTimeDifference =
          formatTimeDifference(welcome.publishedAt!);
        final url = "${welcome.urlToImage}";
      

      return ListTile(
        title: Text("${welcome.title}"),
        leading: Image(image: NetworkImage(url),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        alignment: Alignment.center,),
        subtitle: Text("${welcome.source!.name} • $formattedTimeDifference"),
        trailing:  const Icon(Icons.favorite_outline,),
      );
    },
    separatorBuilder: (BuildContext context, int index) {
      return const Divider(
        thickness: 2,
      );
    },
  );
}


String formatTimeDifference(DateTime publishedAt) {
  final now = DateTime.now();
  final difference = now.difference(publishedAt);

  if (difference.inDays > 0) {
    return "hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}";
  } else if (difference.inHours > 0) {
    return "hace ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}";
  } else if (difference.inMinutes > 0) {
    return "hace ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}";
  } else {
    return "hace unos momentos";
  }
}
