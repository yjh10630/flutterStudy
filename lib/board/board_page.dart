import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:study_flutter/model/response_common_board_info.dart';

import '../club/test.dart';
import '../ex_list.dart';
import '../ex_list2.dart';
import '../utils/color_palette.dart';
import 'board_read_page.dart';
import 'board_ui.dart';
import 'board_write_page.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({Key? key, required this.pageTitle}): super(key: key);

  final String pageTitle;

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<ResponseBoardInfo>> _fetchData() async {
    await Future.delayed(const Duration(seconds: 1));
    final data = await rootBundle.loadString('localdata/board/club_board.json');
    return List<ResponseBoardInfo>.from(jsonDecode(data).map((x) => ResponseBoardInfo.fromJson(x)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        openBuilder: (BuildContext context, VoidCallback _) {
          return BoardWritePage(pageTitle: widget.pageTitle,);
        },
        closedElevation: 6.0,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(56.0 / 2),
          ),
        ),
        closedColor: Colors.redAccent,
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          return const SizedBox(
            height: 56.0,
            width: 56.0,
            child: Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        title: Text(widget.pageTitle),
        actions: [],
      ),
      body: _boardListBuilder(),
    );
  }

  Widget _boardListBuilder() => FutureBuilder<List<ResponseBoardInfo>>(
    future: _fetchData(),
    builder: (context, snapshot) {
      Widget childWidget;
      switch(snapshot.connectionState) {
        case ConnectionState.none:
        case ConnectionState.waiting:
        case ConnectionState.active:
          childWidget = Container(
            key: const ValueKey(0),
            padding: const EdgeInsets.only(top: 24),
            alignment: Alignment.topCenter,
            color: Colors.black.withOpacity(0.8),
            child: const CircularProgressIndicator(color: Colors.redAccent,)
          );
          break;
        case ConnectionState.done:
          if (snapshot.hasData) {
            if (snapshot.requireData.isEmpty) {
              childWidget = const _BoardEmptyWidget(key: ValueKey(1));
            } else {
              childWidget = ListView.builder(
                  key: const ValueKey(2),
                  shrinkWrap: false,
                  itemCount: snapshot.requireData.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.black.withOpacity(0.8),
                      child: _OpenContainerWrapper(
                          transitionType: ContainerTransitionType.fadeThrough,
                          closedBuilder: (context, openContainer) {
                            return BoardItemWidget(
                                data: snapshot.requireData[index],
                                callback: openContainer,
                                isLastItem: snapshot.requireData.length - 1 == index
                            );
                          },
                          widget: BoardReadPage(data: snapshot.requireData[index],)),
                    );
                  }
              );
            }
          } else {
            childWidget = Container(
              key: const ValueKey(3),
              color: Colors.black.withOpacity(0.8),
            );
            Fluttertoast.showToast(
                msg: '일시적인 오류가 있어 불러오지 못했습니다.\n잠시 후 다시 시도해주세요.',
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT
            );
          }
          break;
      }
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child,),
        child: childWidget,
      );
    },
  );
}

class _BoardEmptyWidget extends StatelessWidget {
  const _BoardEmptyWidget({Key? key}): super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      padding: const EdgeInsets.only(top: 48),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          '아직 게시글이 없습니다',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.5)
          ),
        ),
      ),
    );
  }
}

class _OpenContainerWrapper extends StatelessWidget {
  const _OpenContainerWrapper({
    required this.closedBuilder,
    required this.transitionType,
    required this.widget,
  });

  final CloseContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      transitionType: transitionType,
      openBuilder: (BuildContext context, VoidCallback _) {
        return widget;
      },
      tappable: false,
      closedElevation: 0.0,
      openElevation: 0.0,
      closedBuilder: closedBuilder,
    );
  }
}