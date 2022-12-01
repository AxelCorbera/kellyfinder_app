import 'package:app/src/ui/widgets/button/custom_button.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChristmasLottery extends StatelessWidget {
  String dontShowAgain = 'No volver a mostrar';
  String close = 'Cerrar';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.black54,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)
            ),
            height: MediaQuery.of(context).size.height/1.1,
            width:  MediaQuery.of(context).size.width/1.1,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height/1.3,
                      child: Image.network(
                        'http://dev.kellyfindermail.com/kellyfinder_back/public/categorias/sorteo.jpg',
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return FutureCircularIndicator();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: SimpleDialogOption(
                        child: Text(
                          dontShowAgain.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          await dontShow();
                          Navigator.pop(context, true);
                        },
                      ),
                    ),
                    CustomButton(text: close.toUpperCase(),
                      function: (){
                        Navigator.pop(context, true);
                      },),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  dontShow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lottery', false);
  }
}