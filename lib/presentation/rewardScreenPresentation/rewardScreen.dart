import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/presentation/rewardScreenPresentation/rewardScreenPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen();

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: ChangeNotifierProvider.value(
          value: Dependencies.rewardScreenPresentation,

          child: Consumer<RewardScreenPresentation>(
            builder: (BuildContext context,RewardScreenPresentation rewardScreenPresentation,Widget? child) {
              return Container(
                height: ScreenUtil().screenHeight,

                color:Colors.yellow,

                child: ListView(
                  children: [
                  
                        Card(
                      color: Colors.brown,
                      child: Container(
                        height: 700.h,
                      color: Colors.brown,
                      ),
                    ),
                    Card(
                      color: Colors.red,
                      child: Container(
                        height: 700.h,
                        color: Colors.red,
                      ),
                      
                    ),
                        Card(
                      color: Colors.blue,
                      child: Container(
                        height: 700.h,
                      color: Colors.blue,
                      ),
                    ),
                        Card(
                      color: Colors.brown,
                      child: Container(
                        height: 700.h,
                      color: Colors.brown,
                      ),
                    )
                  ],
                ),
                
              );
            }
          ),
        ),
      ),
    );
  }
}