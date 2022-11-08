import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mttv/dpadController.dart';
import 'package:mttv/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class SeriesDetailsPage extends StatefulWidget {
  final dynamic movie;
  const SeriesDetailsPage({Key? key, this.movie}) : super(key: key);

  @override
  State<SeriesDetailsPage> createState() => _SeriesDetailsPageState();
}

class _SeriesDetailsPageState extends State<SeriesDetailsPage> {
  Color playColor = Colors.white;
  Color startOverColor = Colors.white;
  Color dropdownColor = Colors.white;
  final FocusNode startOver = FocusNode();
  final FocusNode playNode = FocusNode();
  final FocusNode progressNode = FocusNode();
  final FocusNode dropdownNode = FocusNode();
  dynamic series;
 List seasonDetails = [];
  getSeason(String season)async{
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    seasonDetails = await firestore
        .collection('Series').doc(series.id).collection(season).orderBy("episodeNumber")
        .get()
        .then((value) => value.docs.map((e) => e.data()).toList());
    setState(() {

    });
  }
  
  
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
    series = widget.movie;
    focusLister();
    dropdownvalue = series['subCollection'].first;
      getSeason(dropdownvalue);
    for(var ele in series['subCollection']){
      items.add(ele);
    }
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
// Initial Selected Value
  String dropdownvalue = '';

// List of items in our dropdown menu
  List<String> items = [];
  bool hasFocus = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,

      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.only(left: 18.sp,top: 18),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(onPressed: (){
                print(items);
                print('items');
              },
                  splashRadius: 1,
                  icon:const Icon(Icons.arrow_back, color: Colors.transparent,)),
              SizedBox(
                width: 100.w,
                height: 90.h,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        SizedBox(
                          width: 60.w,
                          child: Text(series['name'],
                            style: TextStyle(
                                fontSize: 30.sp
                            ),),
                        ),
                        SizedBox(height: 5.h,),
                        SizedBox(
                          width: 50.w,
                          child: Text(series['description'],
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
                                        name: series['name'],
                                        sourceUrl: series['sourceUrl'],
                                          isSeries: true,
                                          ///TODO
                                          nextEpisodes: [],
                                       ),
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
                                        print(seasonDetails);
                                     print(series.id);

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
                        child: Image.network(series['posterUrl']))
                  ],
                ),
              ),
              Focus(
                onFocusChange: (s){
                  setState(() {
                    dropdownColor = s ? Colors.black : Colors.white;
                    hasFocus = s;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: hasFocus ? Colors.white : Colors.black
                  ),
                  width: 13.w,
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButtonHideUnderline(
                      child:
                       DropdownButton(
                         focusNode: dropdownNode,
                         focusColor: Colors.transparent,
                       style: TextStyle(color: dropdownColor,),
                        // dropdownColor: Colors.white,
                       value: dropdownvalue,
                        icon:  Icon(Icons.keyboard_arrow_down,
                        color: dropdownColor),
                      items: items.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                          onTap:()async{
                          await  Future.delayed(const Duration(milliseconds: 100)).then((value){
                          setState(() {
                          });});
                            },
                        );
                      }).toList(),
                      onChanged: (String? newValue){
                        setState((){
                          dropdownvalue = newValue!;
                        });
                       getSeason(newValue!);
                      },
                    ),),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                  physics:const NeverScrollableScrollPhysics(),
                  itemCount: seasonDetails.length,
                  itemBuilder: (ctx,index){
                return SeasonCard(
                  poster: series['posterUrl'],
                seasonDetails: seasonDetails,
                index: index,);
              })
            ],
          ),
        ),
      ),
    );
  }
}

class SeasonCard extends StatefulWidget {
  final dynamic seasonDetails ;
  final String poster ;
  final int index ;
 const  SeasonCard({Key? key, this.seasonDetails, required this.poster, required this.index}) : super(key: key);

  @override
  State<SeasonCard> createState() => _SeasonCardState();
}

class _SeasonCardState extends State<SeasonCard> {
  List nextEpisodes = [];
final FocusNode play = FocusNode();
bool hasChange = false;
int index = 0 ;
dynamic seasonDetails ;
@override
  void initState() {
  seasonDetails = widget.seasonDetails;
  index = widget.index;
  nextEpisodes = seasonDetails;
    // TODO: implement initState
    super.initState();
  }
@override
  void dispose() {
  play.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return
    //   Focus(
    //   focusNode: play,
    //   onFocusChange: (s){
    //   setState(() {
    //         hasChange = s;
    //       });
    //       print("obejcr $s");
    //   },
    //   onKeyEvent: (k,s){
    // if (k.runtimeType == RawKeyDownEvent &&
    // s.isKeyPressed(LogicalKeyboardKey.select)) {
    //
    // }
    //
    // },
      // onClick: (){

      // },
      // onFocus: (s){
      //   setState(() {
      //     hasChange = s;
      //   });
      //   print("obejcr $s");
      // },
      // child:
    Container(
        padding:const EdgeInsets.symmetric(vertical: 8),
        margin:const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          // border: Border.all(color: play.hasFocus ? Colors.white : Colors.black)
        ),
        // height: 40.h,
        width: 60.w,
        child: ListTile(
          focusNode: play,
          // focusColor: Colors.transparent,
          onTap: (){
            print("ob $index");
            print(nextEpisodes.length);
             // nextEpisodes.removeRange(0, index + 1);
            nextEpisodes.removeAt(0);
             print(seasonDetails.length);
            print(nextEpisodes.length);
            print(nextEpisodes);
            print(seasonDetails);
            print(seasonDetails[index]['sourceUrl']);
            print('Episode ${index + 1} - ${seasonDetails[index]['name']} ');
              // Navigator.push(context, MaterialPageRoute (
              //   builder: (BuildContext context) =>  Player(sourceUrl: seasonDetails[index]['sourceUrl'],
              //    isSeries: true,
              //   nextEpisodes: nextEpisodes,
              //     name: "Episode ${index + 1} - ${seasonDetails[index]['name']} ",),
              // ),);
          },
          // minVerticalPadding: 10,
          leading:
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                Container(
                  height: 40.h,
                  width: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(fit: BoxFit.cover,
                          image: NetworkImage(widget.poster,))
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  width: 20.h,
                  height: 3.h,
                  color: Colors.black.withOpacity(.5),
                  child: Text("Episode - ${index + 1}"),
                ),
              ],),

          title: Text(seasonDetails[index]['name']),
          subtitle: Text(seasonDetails[index]['description']),
          trailing: Icon( Icons.play_arrow ,
            color:
            // play.hasFocus ?
          // Colors.black :
            Colors.white,
          size: 20.sp,),
        ),
      );

  }
}
