import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:orkut/services/firebase_service.dart';


class RegisterPage extends StatefulWidget{

@override
  State<StatefulWidget> createState() {
    return _registerPageState();
  }
}


class _registerPageState extends State<RegisterPage>{

double? _deviceHeight , _deviceWidth;

FirebaseService? _firebaseService;

final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

String? _name,_email,_password;
bool _obscureText = true;
File? _image;
Uint8List? _imageBytes;

@override
  void initState() {
    
    super.initState();
    _firebaseService = GetIt.instance.get<FirebaseService>();

  }


@override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
       body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
            padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth!*0.05),
            child: Column(
            mainAxisAlignment:  MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height : _deviceHeight! * 0.05),
              _titleWidget(),
              SizedBox(height : _deviceHeight! * 0.05),
              _profileImageWidget(),
              SizedBox(height : _deviceHeight! * 0.05),
              _registerform(),
              SizedBox(height : _deviceHeight! * 0.05),
              _registerButton()
            ],
            ),
            
            ),
          ),
        ),
        ),
        );
  
  
  
  }
  Widget _titleWidget() {
    return Text("SnapBin", style: TextStyle( fontSize: 25,fontWeight: FontWeight.w600));
  }


  Widget _registerform(){
    return  Container(
      child: Form(
        key : _registerFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _nameTextField(),
            SizedBox(height : _deviceHeight! * 0.05),
            _emailTF(),
            SizedBox(height : _deviceHeight! * 0.05),
            _passTF(),
            SizedBox(height : _deviceHeight! * 0.05),
          ],
        ),
      
      
      ),
    );

  }

  Widget _profileImageWidget() {
  return GestureDetector(
    onTap: () async {
      // Pick an image
      final _result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (_result != null) {
        setState(() {
          if (kIsWeb) {
            // Use bytes for web
            _imageBytes = _result.files.first.bytes;
          } else {
            // Use path for mobile/desktop
            _image = File(_result.files.first.path!);
          }
        });
      } else {
        print("No image selected");
      }
    },
    child: Container(
      height: _deviceHeight! * 0.30,
      width: _deviceWidth! * 0.30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: _imageBytes != null
            ? DecorationImage(
                fit: BoxFit.cover,
                image: MemoryImage(_imageBytes!), // Use bytes for web
              )
            : _image != null
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(_image!), // Use FileImage for mobile
                  )
                : DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        "https://i.pravatar.cc/150?img=21&t=${DateTime.now().millisecondsSinceEpoch}"),
                  ),
        color: Colors.grey[200], // Placeholder color
      ),
      child: (_imageBytes == null && _image == null)
          ? Icon(Icons.person, size: _deviceHeight! * 0.10, color: Colors.grey)
          : null, // Placeholder icon
    ),
  );
}


  Widget _nameTextField(){
    return TextFormField(
      decoration: InputDecoration(hintText: "Name"),
      validator: (_value) => _value!.length > 0 ? null : "Please Enter Your Name",
      onSaved: (_value){
        setState(() {
          _name = _value;
        });
      },
    );
  }

  Widget _emailTF(){
    return TextFormField(
      decoration: InputDecoration(hintText: "Email"),
      onSaved: (_value){
        setState(() {
          _email = _value;
        });
      },
      validator: (_value) {
        bool _result = _value!.contains(RegExp(r'^(?=.{1,254}$)(?=.{1,64}@)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,63}$'));
         return _result ? null : "Please enter a valid email";
      },
      
    );
  }

   Widget _passTF(){
    return TextFormField(
      obscureText : _obscureText,
      decoration: InputDecoration(hintText: "Password",
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        }, icon: Icon( _obscureText ? Icons.visibility : Icons.visibility_off,))),
      
      onSaved: (_value){
        setState(() {
          _password = _value;
        });
      },
      validator: (_value) {
        bool _result = _value!.contains(RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'));
        return _result ? null : "Please enter a strong password";
      },
       
    );
  }


  Widget _registerButton(){
  return MaterialButton(
    onPressed: _regisUser,
    minWidth:  _deviceWidth!*0.50,
    height : _deviceHeight!*0.05,
    color: Colors.deepPurple,
    child: const Text('Register',style: TextStyle(color: Colors.white70, fontWeight:FontWeight.w700 ),),
    );
}

void _regisUser() async{
  if(_registerFormKey.currentState!.validate()){
    _registerFormKey.currentState!.save();
   bool _result = await _firebaseService!.registerUser(
  email: _email!,
  password: _password!,
  name: _name!,
  image: _image, // Pass null or use bytes if on web
  imageBytes: _imageBytes, // New parameter for web uploads
);
 if(_result){
  Navigator.pushReplacementNamed(context,'login');

 }
  }
}

}


