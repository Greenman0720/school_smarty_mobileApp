import 'package:flutter/material.dart';

import 'constants.dart';

class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
                color: loginLightBlue
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                //Image.asset('assets/images/800smarty1.png',
                //    width: 220,
                //  height: 220,
                // ),
              ],
            ),
          ),

        )
    );
  }
}
