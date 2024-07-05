//TODO: style this page
//TODO: add a rout to submit button to go to the channel page

import 'package:flutter_svg/flutter_svg.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'dart:io';
import './drive/drive_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateChannel extends StatefulWidget {
  final String name;

  const CreateChannel({super.key, this.name = ''});
  @override
  _CreateChannelState createState() => _CreateChannelState();
}

class _CreateChannelState extends State<CreateChannel> {
  String canJoin = 'Public';
  String canPost = 'Public';
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String _name = '';

  Future getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }
 

  void setName(String input) {
    print(input);
    setState(() {
      _name = input;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(182, 238, 231, 243),
        title: const Text(
          'Create new channel',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 49, 11, 75),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
            child: elements(),
          ),
          Padding(
            padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 4)
                : const EdgeInsets.only(bottom: 10),
          ),
        ],
      ),
      bottomNavigationBar: createButton(context),
    );
  }

  Padding createButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ElevatedButton(
        onPressed: () async {
          //TODO: add gdrive folder creation
          // await createFolder(_name);
          openModalSuccess(context);
        },
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Color.fromARGB(255, 98, 41, 138)),
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
        Padding(
            padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 4, top: 10)
                : const EdgeInsets.only(bottom: 10, top: 15)),
        // const Text(
        //   'Image: ',
        //   style: TextStyle(
        //     fontWeight: FontWeight.bold,
        //     fontSize: 18,
        //   ),
        // ),
        Padding(
            padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 4)
                : const EdgeInsets.only(bottom: 10)),
        Center(
          child: InkWell(
            onTap: () {
              getImage();
              // Add your code here
            },
            child: _image == null
                ? Stack(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/account.svg',
                        height: 140.0,
                        width: 140.0,
                        color: Color.fromARGB(255, 217, 206, 225),
                      ),
                      const Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 32,
                        color: Color.fromARGB(255, 98, 41, 138),
                      ),
                    ],
                  )
                : ClipOval(
                    child: Image.file(
                      File(_image!.path),
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),

        Padding(
            padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 15)
                : const EdgeInsets.only(bottom: 20)),

        // Name: Label
        Padding(
          padding: defaultTargetPlatform == TargetPlatform.android
              ? const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 4)
              : const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 4),
          child: const Text(
            'Channel Name: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),

        //Name: TextField
        TextField(
          maxLength: 75,
          onChanged: (value) {
            setName(value);
          },
          //style
          style: const TextStyle(
            fontSize: 20,
            color: Color.fromARGB(229, 78, 27, 112),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(15.0),
            hintText: 'DocStax',
            hintStyle: const TextStyle(
                fontSize: 17.0,
                color: Color.fromARGB(146, 78, 27, 112),
                fontWeight: FontWeight.w400),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color.fromARGB(182, 238, 231, 243),
          ),
        ),

        //Description: label
        Padding(
          padding: defaultTargetPlatform == TargetPlatform.android
              ? const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 4)
              : const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 4),
          child: const Text(
            'Description: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),

        //Description: Input Field
        TextField(
          maxLength: 300,
          maxLines: null,
          minLines: defaultTargetPlatform == TargetPlatform.android ? 3 : 5,
          onChanged: (value) {
            setName(value);
          },
          style: const TextStyle(
            fontSize: 20,
            overflow: TextOverflow.visible,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(15.0),
            hintText: 'This is the DocStax Channel',
            hintStyle: const TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(146, 78, 27, 112),
              fontWeight: FontWeight.w400,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color.fromARGB(182, 238, 231, 243),
          ),
        ),

        Padding(
            padding: defaultTargetPlatform == TargetPlatform.android
                ? const EdgeInsets.only(bottom: 8)
                : const EdgeInsets.only(bottom: 15)),

        //Who can join line
        Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 10, right: 0, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Who can Join? ',
                style: TextStyle(
                  fontSize: 19,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle button press
                  modalOpen(context, 'canJoin');
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 10, top: 7, right: 10, bottom: 7), // Add padding
                  // Add padding

                  decoration: BoxDecoration(
                    color: const Color.fromARGB(182, 238, 231, 243),
                    borderRadius:
                        BorderRadius.circular(30), // Set border radius
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$canJoin',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(width: 7),
                      const Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: Color.fromARGB(255, 98, 41, 138),
                        size: 25,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),

        //Who can post? line
        Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 10, right: 0, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Who can Post? ',
                style: TextStyle(
                  fontSize: 19,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle button press
                  modalOpen(context, 'canPost');
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 10, top: 7, right: 10, bottom: 7), // Add padding
                  // Add padding

                  decoration: BoxDecoration(
                    color: const Color.fromARGB(182, 238, 231, 243),
                    borderRadius:
                        BorderRadius.circular(30), // Set border radius
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$canPost',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(width: 7),
                      const Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: Color.fromARGB(255, 98, 41, 138),
                        size: 25,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
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
