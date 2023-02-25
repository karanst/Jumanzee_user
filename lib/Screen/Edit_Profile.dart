import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Jumanzee/Helper/Color.dart';
import 'package:Jumanzee/Helper/Constant.dart';
import 'package:Jumanzee/Helper/Public%20Api/api.dart';
import 'package:Jumanzee/Helper/Session.dart';
import 'package:Jumanzee/Helper/widgets.dart';
import 'package:Jumanzee/Model/UpdateUserModels.dart';
import 'package:Jumanzee/Model/delete_account_model.dart';
import 'package:Jumanzee/Screen/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:http/http.dart' as http;
import '../Helper/String.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool edit = true;
  DateTime selectedDate = DateTime.now();

  var userNameController = TextEditingController();
  var emailController = TextEditingController();
  var dob;

  String? newDob;
  //image

  File? _image;
  final picker = ImagePicker();

  String? typeImage;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _cropImage(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<Null> _cropImage(image) async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: image,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
        ]
            : [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Jumanzeee',
            toolbarColor: colors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      showToast("Uploading Image");
      _image = croppedFile;
      setState(() {
      });
      UpdateUserModels? model =await uploadImage(typeImage == "pro"?"image":"bank_pass", _image!.path);
       if(model!.error == false){
         setState(() {
           showToast(model.message);
         });
       }
    }
  }

  Future<DeleteAccountModel?> deleteAccount() async {
    var header = headers;
    var request = http.MultipartRequest('POST',Uri.parse('https://jumanzee.com/app/v1/api/remove_user/$CUR_USERID'));
    // request.fields.addAll({'user_id': '$CUR_USERID'});

    request.headers.addAll(header);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final str = await response.stream.bytesToString();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Login()));
      var data  = DeleteAccountModel.fromJson(json.decode(str));
      setSnackbar(data.message.toString(), context);
      return DeleteAccountModel.fromJson(json.decode(str));

    } else {
      return null;
    }
  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
      return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: FutureBuilder(
              future: userDetails(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  var user = snapshot.data;
                  return Scaffold(
                    appBar: AppBar(
                      leading: IconButton(onPressed: (){
                        Navigator.pop(context , true);
                      }, icon: Icon(Icons.arrow_back)),
                      backgroundColor: Colors.white,
                      iconTheme: IconThemeData(color: colors.primary),
                      actions: [
                        edit
                            ? TextButton(
                                onPressed: () {
                                  setState(() {
                                    edit = false;
                                    userNameController.text =
                                        user!.date![0].username;
                                    emailController.text = user!.date![0].email;
                                    dob = user!.date![0].dob;
                                  });
                                },
                                child: Text("Edit", style: TextStyle(fontWeight: FontWeight.bold , fontSize: 14 , color: colors.primary)))
                            : TextButton(
                                onPressed: () async {
                                  if (dob != null) {
                                    DateTime date = selectedDate;
                                    var userName = userNameController.text;
                                    var email = emailController.text;
                                    var updateDOB = dob == null
                                        ? "${date.day}-${date.month}-${date.year}"
                                        : dob;
                                    UpdateUserModels? model =
                                        await updateUserDetails(
                                            userName, email, updateDOB);
                                    if (model!.error == false) {
                                      setState(() {
                                        showToast(model.message);
                                        edit = true;
                                      });
                                    } else {
                                      showToast(model.message);
                                    }
                                  }else{
                                    showToast("Select Date");
                                  }
                                },
                                child: Text("Save" , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 , color: colors.primary),))
                      ],
                      title: Text(
                        "Profile",
                        style: TextStyle(color: colors.primary),
                      ),
                    ),
                    body: ListView(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        edit
                            ? Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      user!.date![0].proPic != ""
                                          ? CircleAvatar(
                                              backgroundColor: Colors.white,
                                              radius: 50,
                                              backgroundImage: NetworkImage(
                                                  "$imageUrl${user!.date![0].proPic}"),
                                            )
                                          : CircleAvatar(
                                              radius: 50,
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                            ),
                                      CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.white,
                                          child: IconButton(
                                              onPressed: () {
                                                typeImage = "pro";
                                                getImage();
                                              },
                                              icon: Icon(
                                                Icons.edit,
                                                color: colors.primary,
                                                size: 15,
                                              )))
                                    ],
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.person),
                                    title: Text("User Name"),
                                    trailing: Text("${user!.date![0].username}"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.email),
                                    title: Text("Email Id"),
                                    trailing: Text("${user!.date![0].email}"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.call),
                                    title: Text("Phone Number"),
                                    trailing: Text("${user!.date![0].mobile}"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.accessibility),
                                    title: Text("Gender"),
                                    trailing: Text("${user!.date![0].gender}"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.date_range),
                                    title: Text("Date Of Birth"),
                                    trailing: user!.date![0].dob != null
                                        ? Text("${user!.date![0].dob}")
                                        : TextButton(
                                            onPressed: () {
                                              setState(() {
                                                edit = false;
                                                userNameController.text =
                                                    user!.date![0].username;
                                                emailController.text =
                                                    user!.date![0].email;
                                                dob = user!.date![0].dob;
                                              });
                                            },
                                            child: Text("Update")),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.document_scanner),
                                    title: Text("Upload Passbook"),
                                    trailing: TextButton(
                                            onPressed: () {
                                              typeImage ="pas";
                                              getImage();
                                            }, child: Text("Upload")),
                                    subtitle: user!.date![0].bankPass != ""
                                        ? Image.network(
                                            "$imageUrl${user!.date![0].bankPass}")
                                        : Text(""),
                                  )
                                ],
                              )
                            : Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: userNameController,
                                        decoration: InputDecoration(
                                            label: Text("User Name")),
                                      ),
                                      TextField(
                                        controller: emailController,
                                        decoration:
                                            InputDecoration(label: Text("Email")),
                                      ),
                                      getDob(),
                                    ],
                                  ),
                                ),
                              ),

                        Padding(
                          padding: const EdgeInsets.only(top: 50, left: 20.0, right: 20),
                          child: ElevatedButton(
                              onPressed: (){
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        // title: Text("Confirm Exit"),
                                        content: Text("Are you sure you want to delete your account?"),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(primary: colors.primary),
                                            child: Text("YES"),
                                            onPressed: () {
                                              deleteAccount();
                                            },
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(primary: colors.primary),
                                            child: Text("NO"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    });
                              },
                              child: Text("Delete Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600
                              ),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            fixedSize: Size(300, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            )
                          ),),
                        )
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Icon(Icons.error_outline);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ),
    );
  }

  getDob() {
    DateTime date = selectedDate;
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: ListTile(
        onTap: () {
          _selectDate(context);
        },
        title: Text("Select Date Of Birth"),
        subtitle: dob != null
            ? Text(dob)
            : Text("${date.day}-${date.month}-${date.year}"),
        trailing: Icon(Icons.calendar_today_outlined),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1970),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                // primary: Color(0xffFF00FF), // header background color
                onPrimary: Colors.black, // header text color
                onSurface: Colors.black, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.black, // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (selected != null && selected != selectedDate)
      setState(() {
        selectedDate = selected;
        DateTime date = selectedDate;
        dob = "${date.day}-${date.month}-${date.year}";
      });
  }
}
