import 'package:flutter/material.dart';
import 'package:mttv/player.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class MovieDetailsPage extends StatefulWidget {
  final dynamic movie;
  const MovieDetailsPage({Key? key, this.movie}) : super(key: key);

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  Color playColor = Colors.white;
  Color startOverColor = Colors.white;
  final FocusNode startOver = FocusNode();
  final FocusNode playNode = FocusNode();
  final FocusNode progressNode = FocusNode();
  dynamic movie;

  focusLister(){
    startOver.addListener(() {
      setState(() {
        (startOver.hasFocus)
            ? startOverColor = Colors.black
            : startOverColor = Colors.white;
      });

    });
    playNode.addListener(() {
      setState(() {
        (playNode.hasFocus)
            ? playColor = Colors.black
            : playColor = Colors.white;
      });

    });
  }

  @override
  void initState() {
    movie = widget.movie;
    focusLister();
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Container(
        width: 100.w,
        padding:const EdgeInsets.all(30),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60.w,
                  child: Text(movie['name'],
                  style: TextStyle(
                    fontSize: 30.sp
                  ),),
                ),
                SizedBox(height: 5.h,),
                SizedBox(
                  width: 50.w,
                  child: Text(movie['description'],
                    style: TextStyle(
                        fontSize: 15.sp
                    ),
                  textAlign: TextAlign.start,),
                ),
                SizedBox(height: 10.h,),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: playColor == Colors.white
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(1),
                          shape: BoxShape.circle
                        // borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                          splashRadius: 1,
                          focusNode: playNode,
                          autofocus: true,
                          onPressed: () {
                            print('object');
                          Navigator.push(context,MaterialPageRoute (
                            builder: (BuildContext context) =>  Player(
                              sourceUrl: movie['sourceUrl'],
                                 isSeries: false,
                            nextEpisodes: const[], name: movie['name'],),
                          ), );
                          },
                          icon: Icon(
                            Icons.play_arrow,
                            size: 50,
                            color:
                            playColor.withOpacity(1),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Resume' ,style: TextStyle(fontSize: 18.sp),),
                    ),
                    // SizedBox(width: 8.w,),
                    Column(mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: startOverColor == Colors.white
                                ? Colors.white.withOpacity(0.2)
                                : Colors.white.withOpacity(1),
                            shape: BoxShape.circle
                            // borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                              splashRadius: 1,
                              focusNode: startOver,
                              autofocus: true,
                              onPressed: () {

                              },
                              icon: Icon(
                                Icons.restart_alt,
                                size: 30,
                                color:
                                startOverColor.withOpacity(1),
                              )),
                        ),
                     SizedBox(height: 1.h,),
                     startOver.hasFocus ? const   Text('Start Over') : const SizedBox()
                      ],
                    ),
                  ],
                )

              ],
            ),
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white,width: 10)
                ),
                child: Image.network(movie['posterUrl'],width: 30.w,
                fit: BoxFit.cover,))

          ],
        ),
      ),
    );
  }
}
