import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class CreateChannel extends StatefulWidget {
  final String name;

  const CreateChannel({Key? key, this.name = ''}) : super(key: key);
  @override
  _CreateChannelState createState() => _CreateChannelState();
}

class _CreateChannelState extends State<CreateChannel> {
  String canJoin = 'Public';
  String canPost = 'Public';
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void setName(String input) {
    print(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {},
          ),
          title: const Text('Create'),
        ),
        body: Stack(
          children: [
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: elements(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: createButton(context),
          ),
          Padding(
              padding: defaultTargetPlatform == TargetPlatform.android
                  ? const EdgeInsets.only(bottom: 4)
                  : const EdgeInsets.only(bottom: 10)),
        ])
        
        );
  }

  Padding createButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          openModalSuccess(context);
        },
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Color.fromARGB(255, 17, 10, 208)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        child: const Text('Create Channel',
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Column elements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Channel Information',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
            padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 4)
                : const EdgeInsets.only(bottom: 10)),
        const Text(
          'Image: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Padding(
            padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 4)
                : const EdgeInsets.only(bottom: 10)),
        InkWell(
          onTap: () {
            getImage();
            // Add your code here
          },
          child: _image == null
              ? const Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 68,
                  color: Color.fromARGB(221, 13, 39, 232),
                )
              : ClipOval(
                  child: Image.file(
                    File(_image!.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        Padding(
            padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 4)
                : const EdgeInsets.only(bottom: 10)),
        const Text(
          'Name: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Padding(
            padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 4)
                : const EdgeInsets.only(bottom: 10)),
        TextField(
          maxLength: 75,

          onChanged: (value) {
            setName(value);
          },
          //style
          style: const TextStyle(
            fontSize: 20,
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            hintText: 'Channel Name',
            fillColor: Color(0xE8EDF4FF),
            filled: true,
          ),
        ),
        Padding(
            padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 4)
                : const EdgeInsets.only(bottom: 10)
              ),
        const Text(
          'Description: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Padding(
            padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 4)
                : const EdgeInsets.only(bottom: 10)),
        TextField(
          maxLength: 300,
          maxLines: null,
          minLines: defaultTargetPlatform==TargetPlatform.android ? 3 : 5,
          onChanged: (value) {
            setName(value);
          },
          style: const TextStyle(
            fontSize: 20,
            overflow: TextOverflow.visible,
          ),
          decoration: const InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: Colors.red),
            ),
            hintText: 'Description of the channel',
            fillColor: Color(0xE8EDF4FF),
            filled: true,
          ),
        ),
        Padding(padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 4)
                : const EdgeInsets.only(bottom: 10)),
        const Text(
          'Privacy',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
            padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 4)
                : const EdgeInsets.only(bottom: 10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Who can Join? ',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 10)),
            TextButton(
              onPressed: () {
                // Handle button press
                modalOpen(context, 'canJoin');
              },
              child: Text(
                '$canJoin 🔽',
                style: const TextStyle(fontSize: 20, color: Colors.black87),
              ),
            )
          ],
        ),
        const Padding(padding: EdgeInsets.only(bottom: 7)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Who can post?',
              style: TextStyle(
                fontSize: 20,
              ),
            ),

            const Padding(padding: EdgeInsets.only(left: 10)),
            // Remove the @override annotation
            TextButton(
              onPressed: () {
                // Handle button press
                modalOpen(context, 'canPost');
              },
              child: Text(
                '$canPost 🔽',
                style: const TextStyle(fontSize: 20, color: Colors.black87),
              ),
            )
          ],
        ),
      ],
    );
  }

  Future<dynamic> modalOpen(BuildContext context, String select) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <String>[
            'Private',
            'Public',
            'Invite Only',
            'Classroom Only'
          ].map((String value) {
            return ListTile(
              title: Text(value),
              onTap: () {
                setState(() {
                  if (select == 'canPost') {
                    canPost = value;
                  } else {
                    canJoin = value;
                  }
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}

void openModalSuccess(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return const SizedBox(
        height: 200, // You can adjust this value as needed
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              Text(
                'Success!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
