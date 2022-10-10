import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class CommuniqueImageViewer extends StatefulWidget {
  final String image;
  CommuniqueImageViewer({this.image});

  @override
  _CommuniqueImageViewerState createState() => _CommuniqueImageViewerState();
}

class _CommuniqueImageViewerState extends State<CommuniqueImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      /*appBar: AppBar(centerTitle:true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),*/
      appBar: AppBar(centerTitle:true,
        elevation: 0,
        backgroundColor: Colors.black,
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(widget.image),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained * 1.5,
          initialScale: PhotoViewComputedScale.contained,
        ),
      ),
    );
  }
}
