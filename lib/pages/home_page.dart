import 'package:article_movie_app/bloc/get_movies_bloc.dart';
import 'package:article_movie_app/model/movie.dart';
import 'package:article_movie_app/model/movie_response.dart';
import 'package:article_movie_app/widgets/now_playing.dart';
import 'package:article_movie_app/widgets/top_movies.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:article_movie_app/style/theme.dart' as Style;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      appBar: AppBar(
        backgroundColor: Style.Colors.mainColor,
        centerTitle: true,
        leading: Icon(
          EvaIcons.menu2Outline,
          color: Colors.white,
        ),
        title: Text("Movie App"),
        actions: [
          IconButton(
              icon: Icon(
                EvaIcons.searchOutline,
                color: Colors.white,
              ),
              onPressed: () {
                showSearch(context: (context), delegate: MovieSearch());
              })
        ],
      ),
      drawer: Drawer(),
      body: ListView(
        children: [NowPlaying(), TopMovies()],
      ),
    );
  }
}

class MovieSearch extends SearchDelegate<String> {
  Widget _buildLoadingWidget() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 25.0,
          width: 25.0,
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 4.0,
          ),
        )
      ],
    ));
  }

  Widget _buildErrorWidget(Object? error) {
    final text = error is String ? error : 'An error has ocurred';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Error occured: $text"),
        ],
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, '');
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text('Results...');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    moviesBloc..getMovies();
    return StreamBuilder<MovieResponse>(
        stream: moviesBloc.subject.stream,
        builder: (context, AsyncSnapshot<MovieResponse> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.error.length > 0) {
              return _buildErrorWidget(snapshot.data!.error);
            }
            return listWidget(snapshot.data!);
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error);
          } else {
            return _buildLoadingWidget();
          }
        });
  }

  Widget listWidget(MovieResponse data) {
    final List<Movie> suggestionList = query.isEmpty
        ? data.movies.take(10).toList()
        : data.movies.where((q) => q.title.startsWith(query)).toList();

    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         MovieDetailPage(movie: SuggestionList[index]),
              //   ),
              // );
            },
            child: ListTile(
              leading: Icon(
                Icons.movie,
                color: Style.Colors.secondColor,
              ),
              title: Text(suggestionList[index].title),
            ),
          );
        });
  }
}
