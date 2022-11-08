import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:mttv/SeriesDetailsPage.dart';
import 'package:mttv/moviesDetailsPage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'player.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List movies = [];
  List series = [];
  List carouselItems = [];
  getMovies() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('Movies')
        .get()
        .then((value) => value.docs.forEach((element) {
              movies.add(element);
            }));
    print(movies.first['isHot']);
    for (var element in movies) {
      if (element['isHot'] == true && element['isTrending'] == true) {
        carouselItems.add(element);
        imageSliders.add(
          Container(
            height: 40.h,
            margin: const EdgeInsets.all(5.0),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      right: 0.0,
                      top: 0,
                      child: Image.network(
                        element['posterUrl'],
                        fit: BoxFit.fitHeight,
                        width: 40.w,
                        height: 40.h,
                      ),
                    ),
                    Positioned(
                      // bottom: 0.0,
                      left: 0.0,
                      // right: 0.0,
                      child: Container(
                        width: 70.w,
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
                              element['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            Text(
                              element['description'],
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
        );
      }
    }
    setState(() {});
  }

  getSeries() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // series =
    await firestore
        .collection('Series')
        .get()
        .then((value) => value.docs.forEach((element) {
              // element.data().addAll({"id": element.id});
              series.add(element);
            }));
    // => e.data().addAll({"id": e.id})).toList());

    for (var element in series) {
      if (element['isHot'] == true && element['isTrending'] == true) {
        carouselItems.add(element);
        imageSliders.add(
          Container(
            height: 40.h,
            margin: const EdgeInsets.all(5.0),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      right: 0.0,
                      top: 0,
                      child: Image.network(
                        element['posterUrl'],
                        fit: BoxFit.fitHeight,
                        width: 40.w,
                        height: 40.h,
                      ),
                    ),
                    Positioned(
                      // bottom: 0.0,
                      left: 0.0,
                      // right: 0.0,
                      child: Container(
                        width: 70.w,
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
                              element['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            Text(
                              element['description'],
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
        );
      }
    }
    setState(() {});
  }

  final List<String> imgList = [
    "https://m.media-amazon.com/images/M/MV5BZGUxZGY1MWMtMWJlMi00ODU2LWE4ZTEtMTM1NDM0YTcyY2E4XkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_Ratio1.0000_AL_.jpg",
    "https://m.media-amazon.com/images/M/MV5BMjMwMmIzNDYtZmM4OS00MzlkLWI0YWMtMzAyOWJhZWJjMzI5XkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_Ratio1.5000_AL_.jpg",
    "https://m.media-amazon.com/images/M/MV5BZDE3MGJiNzctOWE4OS00YTZhLWJlYzQtM2E5Zjc1NjM1YWUwXkEyXkFqcGdeQXVyMTQyMTMwOTk0._V1_Ratio1.0000_AL_.jpg",
    "https://m.media-amazon.com/images/M/MV5BNTMxZGFlZDQtYTc2ZC00ZWU2LTk4YmUtYWVhZTE1MTY4ZGZkXkEyXkFqcGdeQXVyNDI3NjU1NzQ@._V1_Ratio1.0000_AL_.jpg",
    "https://m.media-amazon.com/images/M/MV5BMWQ4MDY0ZTEtMjZmZC00NmM1LTgzNWUtY2ZkYWMyOWUwOWZkXkEyXkFqcGdeQXVyNDI3NjU1NzQ@._V1_Ratio1.0000_AL_.jpg"
  ];

  List<Widget> imageSliders = [];
  final FocusNode carouselNode = FocusNode();
  final FocusNode carNode = FocusNode();
  Color carouselBorder = Colors.black54;
  bool isSelected = false;
  String image =
      "https://m.media-amazon.com/images/M/MV5BMjMwMmIzNDYtZmM4OS00MzlkLWI0YWMtMzAyOWJhZWJjMzI5XkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_Ratio1.5000_AL_.jpg";
  String name = 'Midaway';
  String description =
      'this is a sample descroption of the movie that will be shown in hte top slider ';
  Widget topContainer() {
    return Focus(
      focusNode: carNode,
      onFocusChange: (k) {
        setState(() {
          if (k) {
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
                  child: Image.network(
                    image,
                    fit: BoxFit.fitHeight,
                    width: 30.w,
                    height: 40.h,
                  ),
                ),
                Positioned(
                  // bottom: 0.0,
                  left: 0.0,
                  // right: 0.0,
                  child: Container(
                    width: 70.w,
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
                        SizedBox(
                          height: 5.h,
                        ),
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
    );
  }

  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    getMovies();
    getSeries();

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
            SizedBox(
              height: 5.h,
            ),
            // isSelected ?  topContainer()     :
            Column(
              children: [
                RawKeyboardListener(
                  autofocus: true,
                  focusNode: carouselNode,
                  onKey: (k) async {
                    print(k.data.logicalKey);
                    if (k.runtimeType == RawKeyDownEvent &&
                        k.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                      print("next");
                      _controller.nextPage();
                      carouselNode.requestFocus();
                    } else if (k.runtimeType == RawKeyDownEvent &&
                        k.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
                      _controller.previousPage();
                      carouselNode.requestFocus();
                      print("prev");
                    } else if (k.runtimeType == RawKeyDownEvent &&
                        k.isKeyPressed(LogicalKeyboardKey.select)) {
                      print('selected ');
                      print(carouselItems[_current]['name']);
                      if (carouselItems[_current]['isSeries'] == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                SeriesDetailsPage(
                                    movie: carouselItems[_current]),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => MovieDetailsPage(
                              movie: carouselItems[_current],
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: carouselBorder)),
                    height: 40.h,
                    width: 100.w,
                    child: CarouselSlider(
                      items: imageSliders,
                      carouselController: _controller,
                      options: CarouselOptions(
                          viewportFraction: 1,
                          autoPlay: true,
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
                  children: carouselItems.asMap().entries.map((entry) {
                    return Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness ==
                                      Brightness.dark
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
                  itemBuilder: (ctx, index) {
                    return ImageCard(
                      movie: movies[index],
                    );
                  }),
            ),
            IconButton(
              // focusNode: carNode,
              icon: const Icon(Icons.confirmation_num_sharp),
              onPressed: () async{
                var headers = {
                  'Origin': 'https://swarajyamag.com',
                };
                var params = {
                  'key': 'EgkFQZrx8TRe2cDgBg26qPxd',
                  'accesstype_jwt': 'maNtwyEb5BWBz5a7rss2tZho',
                };
                var query = params.entries.map((p) => '${p.key}=${p.value}').join('&');

                var url = Uri.parse('https://accesstype.com/api/access/v1/members/me/metadata?$query');
                var res = await http.get(url,headers: headers);
                // if (res.statusCode != 200) throw Exception('http.get error: statusCode= ${res.statusCode}');
                print(res.body);
                print(res.statusCode);
                print(series.first.id);
                // print(carouselItems);
                // getSeries();
                // Navigator.push(context, MaterialPageRoute (
                //   builder: (BuildContext context) => Player(sourceUrl: movies[4]['sourceUrl'], subtitleUrl: ''),
                // ),);
              },
            )
          ],
        ),
      ),
    );
  }
}

class ImageCard extends StatefulWidget {
  const ImageCard({Key? key, required this.movie}) : super(key: key);
  final dynamic movie;

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  bool hasChange = false;
  FocusNode isFocused = FocusNode();
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onFocusChange: (s) {
        setState(() {
          hasChange = s;
        });
      },
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MovieDetailsPage(
              movie: widget.movie,
            ),
          ),
        );
      },
      child: Transform.scale(
        scale: hasChange ? 1.1 : 1,
        child: Container(
          padding: const EdgeInsets.all(10),
          width: 25.h,
          height: 40.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: hasChange ? Colors.white : Colors.black,
            border: Border.all(
              color: hasChange
                  ? Colors.white
                  : Colors.black,
              width: 5,
            ),
            image: DecorationImage(
              image: NetworkImage(widget.movie['posterUrl']),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    );
  }
}
