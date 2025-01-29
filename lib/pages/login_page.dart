
/*In Flutter, MainAxisAlignment.spaceAround is a property used in layout widgets like Row, Column, and Flex to control the distribution of their children along the main axis.
When you use MainAxisAlignment.spaceAround, the children are evenly spaced, and the space between each child, as well as the space before the first child and after the last child, are all equal.*/





import 'package:flutter/material.dart';
import 'package:orkut/services/firebase_service.dart';
import 'package:get_it/get_it.dart';
class LoginPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _loginPageState();
  }
}
final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>(); /// sets the variable that holds or controls the form state.
String? _email;
String? _pass;
bool _obscureText = true;

class _loginPageState extends State<LoginPage>{

  double? _deviceHeight , _deviceWidth;

 FirebaseService? _firebaseService;

 @override
  void initState() {
   
    super.initState();
    _firebaseService = GetIt.instance.get<FirebaseService>();
  }

//used singlechildscrollview instead of form to hold the entire thing.
//used crossalignment strech and allocated height dynamically in login form .
//removed a container fromthe login form that seemed to cause overflow.

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth  = MediaQuery.of(context).size.width;
    return Scaffold(body:  SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: _deviceHeight!*0.05,
          ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _titlewidget(),
              SizedBox(height :  _deviceHeight! * 0.05),
              _loginForm(),
              SizedBox(height :  _deviceHeight! * 0.05),
              SizedBox(height :  _deviceHeight! * 0.05),
              SizedBox(height :  _deviceHeight! * 0.05),
              _loginButton(),
              SizedBox(height :  _deviceHeight! * 0.05),
              
              _noAccount(),
            ],
            ),
          ),
        ),
      ),
    ),
    );
  }
  Widget _titlewidget(){
    return const Text("Snap Bin",style:
     TextStyle(color: Colors.blueGrey,
     fontSize: 25,
     fontWeight: FontWeight.w600),
     );
  }
  Widget _loginForm(){
    return Form(
        key: _loginFormKey,
        child:  Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _emailTF(),
          const SizedBox(height :  15),
          _passTF(),
        ],
        ),
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
          _pass = _value;
        });
      },
      validator: (_value) {
        bool _result = _value!.contains(RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'));
        return _result ? null : "Please enter a strong password";
      },
       
    );
  }

  
  Widget _loginButton(){
    return MaterialButton(
      onPressed: _loginUser,
    minWidth: _deviceWidth! * 0.60 ,
    height: _deviceHeight! * 0.06 ,
    color: Colors.deepPurple,
    child: const Text('Login',style: TextStyle(color: Colors.white70, fontWeight:FontWeight.w700 ),),
    );
  }
  void _loginUser() async {
  if(_loginFormKey.currentState!.validate()){
    _loginFormKey.currentState!.save();
   
    if(_email == null && _pass == null){
      return;
    }
    bool _result = await _firebaseService!.loginUser(email: _email!, password: _pass!);
if(_result){
Navigator.popAndPushNamed(context,"home");
}


  }
}

Widget _noAccount(){
  return GestureDetector(
    onTap: () => Navigator.pushNamed( context , "register"),
    child: const Text("No Account? Click here.",
    style: TextStyle
    (color: Colors.deepPurple,
    fontWeight: FontWeight.w700
    ),
    ),
  );
}
}

