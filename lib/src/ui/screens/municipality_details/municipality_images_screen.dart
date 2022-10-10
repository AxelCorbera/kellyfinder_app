import 'package:app/src/model/municipality/image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MunicipalityImagesScreen extends StatefulWidget {
  final int index;
  final List<MunicipalityImage> images;

  const MunicipalityImagesScreen({Key key, this.index = 0, this.images}) : super(key: key);

  @override
  _MunicipalityImagesScreenState createState() =>
      _MunicipalityImagesScreenState();
}

class _MunicipalityImagesScreenState extends State<MunicipalityImagesScreen> {
  PageController controller;

  int currentIndex;

  @override
  void initState() {
    controller = PageController(initialPage: widget.index);
    currentIndex = widget.index;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                currentIndex = index;
              });
            },
            controller: controller,
            children: List.generate(
              widget.images?.length,
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
                  widget.images?.length,
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
                        color: currentIndex == index
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
    );
  }
}
