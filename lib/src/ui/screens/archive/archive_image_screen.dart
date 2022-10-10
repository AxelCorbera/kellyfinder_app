import 'package:app/src/model/archive/archive.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ArchiveImageScreen extends StatefulWidget {
  final String image;
  final List<ArchiveImage> images;

  const ArchiveImageScreen({Key key, this.image, this.images}) : super(key: key);

  @override
  _ArchiveImageScreenState createState() => _ArchiveImageScreenState();
}

class _ArchiveImageScreenState extends State<ArchiveImageScreen> {

  int firstPage = 0;

  PageController _pageController;

  @override
  void initState() {

    firstPage = widget.images.indexWhere((element) => element.pic == widget.image);

    _pageController = PageController(initialPage: firstPage);

    super.initState();
  }

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
      body: Stack(
        children: [
          PageView(
            onPageChanged: (int index) {
              setState(() {
                firstPage = index;
              });
            },
            controller: _pageController,
            children: List.generate(
              widget.images.length,
              //(index) => Image.network(images[index], fit: BoxFit.fitWidth),
                  (index) => PhotoView(
                imageProvider: NetworkImage(widget.images[index].pic),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.contained * 1.5,
                initialScale: PhotoViewComputedScale.contained,
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                      (index) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 2.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: firstPage == index
                            ? Theme.of(context).accentColor
                            : Colors.white38,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      /*body: PhotoViewGallery.builder(
      itemCount: widget.images.length,
      pageController: _pageController,
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(
            widget.images[index].pic,
          ),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained * 1.5,
        );
      },
      scrollPhysics: BouncingScrollPhysics(),
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes,
            ),
          ),
        ),
      backgroundDecoration: BoxDecoration(
        color: Colors.black,
      ),
        customSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
    ),*/
      /*PhotoView(
        imageProvider: NetworkImage(image),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 1.5,
        initialScale: PhotoViewComputedScale.contained,
      ),*/
    );
  }
}
