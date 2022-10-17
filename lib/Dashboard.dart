
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:mttv/dpadController.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hls.dart';
import 'home_page.dart';
class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  List movies = [];
  getMovies()async{
    FirebaseFirestore firestore = FirebaseFirestore.instance;
   movies =  await firestore.collection('Movies').get().then((value) =>
    value.docs.map((e) => e.data()).toList());
   print(movies.last['posterUrl']);
  }

  final List<String> imgList = [
    'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
    'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
    'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
    'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
  ];

   List<Widget> imageSliders = [];
  final FocusNode carouselNode = FocusNode();
  final FocusNode carNode = FocusNode();
  Color carouselBorder = Colors.black54;
 bool isSelected = false;
  String image = '';
  String name = '';
  String description = '';
 Widget topContainer() {
   return Focus(
     focusNode: carNode,
     onFocusChange: (k){
       setState(() {
         if(k){
           carouselNode.requestFocus();
           isSelected = false;
         }
       });
     },
     child: Container(
       height: 40.h,
       margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
         borderRadius: const BorderRadius.all(Radius.circular(5.0)),
         child: Stack(
           children: <Widget>[
             Positioned(
               right: 0.0,
               top: 0,
               child: Image.network(image,
                   fit: BoxFit.fitWidth,
                   width: 50.w,
                 height: 40.h,
               ),
             ),
             Positioned(
               // bottom: 0.0,
               left: 0.0,
               // right: 0.0,
               child: Container(
                 width: 51.w,
                 decoration: const BoxDecoration(
                   gradient: LinearGradient(
                     colors: [
                       Color.fromARGB(200, 0, 0, 0),
                       Color.fromARGB(0, 0, 0, 0)
                     ],
                     begin: Alignment.bottomRight,
                     end: Alignment.topRight,
                   ),
                 ),
                 padding: const EdgeInsets.symmetric(
                     vertical: 10.0, horizontal: 20.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text(
                       name,
                       style: const TextStyle(
                         color: Colors.white,
                         fontSize: 20.0,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                     SizedBox(height: 5.h,),
                     Text(
                       description,
                       textAlign: TextAlign.left,
                       style: const TextStyle(
                         color: Colors.white,
                         fontSize: 20.0,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ],
         )),
 ),
   );}
  int _current = 0;
  final CarouselController _controller = CarouselController();
  @override
  void initState() {
getMovies();
    imageSliders  = imgList
        .map((item) => Container(
            margin: const EdgeInsets.all(5.0),
           child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
             child: Stack(
          children: <Widget>[
                Image.network(item, fit: BoxFit.cover, width: 1000.0),
                    Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                      child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(200, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: Text(
                      'No. ${imgList.indexOf(item)} image',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
              ],
            )),
      ))
        .toList();

    carouselNode.addListener(() {
      setState(() {
        (carouselNode.hasFocus)
            ? carouselBorder = Colors.white
            : carouselBorder = Colors.black54;
      });
    });
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             SizedBox(height: 5.h,),
            isSelected ?  topContainer()     :
            Column(
              children: [
                RawKeyboardListener(
                  focusNode: carouselNode,
                  onKey: (k) async {
                    print(k.data.logicalKey);
                    if (k.runtimeType == RawKeyDownEvent && k.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                      print("next");
                      _controller.nextPage();
                    } else if (k.runtimeType == RawKeyDownEvent && k.isKeyPressed(LogicalKeyboardKey.arrowLeft )) {
                      _controller.previousPage();

                      print("prev");
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: carouselBorder)
                    ),
                    height: 40.h,
                    width: 100.w,
                    child: CarouselSlider(
                      items: imageSliders,
                      carouselController: _controller,
                      options: CarouselOptions(
                        viewportFraction: 1,
                          autoPlay: false,
                          enlargeCenterPage: true,
                          aspectRatio: 2.0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          }),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imgList.asMap().entries.map((entry) {
                    return Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    );
                  }).toList(),
                ),
              ],
            ),

            const Text(
              'Continue Watching',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 35.h,
              // width: 10.w,
              child: ListView.builder(
                itemCount: movies.length,
                scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx,index){
                return  ImageCard(image:movies[index]['posterUrl'],
                subtitleUrl: movies[index]['subtitleUrl'],
                sourceUrl: movies[index]['sourceUrl'],
                desc: movies[index]['description'],
                name: movies[index]['name'],
                context: this,);
              }),
            ),
            IconButton(
              // focusNode: carNode,
              icon: const Icon(Icons.confirmation_num_sharp),onPressed: (){
                getMovies();
                Navigator.push(context, MaterialPageRoute (
                  builder: (BuildContext context) => HomePage(sourceUrl: movies[4]['sourceUrl'], subtitleUrl: ''),
                ),);
            },)
          ],
        ),
      ),
    );
  }
}

class ImageCard extends StatefulWidget {
  const ImageCard({Key? key, required this.image, required this.context, required this.desc, required this.name, required this.sourceUrl, required this.subtitleUrl}) : super(key: key);
final State context;
  final String image;
  final String desc;
  final String name;
  final String sourceUrl;
  final String subtitleUrl;

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  bool hasChange = false;
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return DpadContainer(
      onClick: () {
        print('called');
        setState(() {
          hasChange = false;
        });
        Navigator.push(context, MaterialPageRoute (
          builder: (BuildContext context) =>  HomePage(
            sourceUrl: widget.sourceUrl,
            subtitleUrl: widget.subtitleUrl,
          ),
        ),);
      },
      onFocus: (focus) {
        DashboardState st = widget.context as DashboardState;
      st.image = widget.image;
      st.name = widget.name;
      st.description = widget.desc;
      st.isSelected = true;
      st.topContainer();
      st.
        setState(() {
          hasChange = focus;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Transform.scale(
          alignment: Alignment.centerRight,
          scale: hasChange ? 1.5 : 1,
          origin: Offset.fromDirection(.5),
          child: Container(
            width: 25.h,
            height:40.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: hasChange ? Colors.white : Colors.black,
              border: Border.all(
                color: hasChange
                    ? Colors.white
                    : isClicked
                    ? Colors.blue.shade400
                    : Colors.black,
                width: 5,
              ),
              image: DecorationImage(
                image: NetworkImage(widget.image),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
