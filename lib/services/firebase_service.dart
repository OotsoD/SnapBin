import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
final String USER_COLLECTION = 'users';

class FirebaseService{

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseStorage _storage = FirebaseStorage.instance;
FirebaseFirestore _db = FirebaseFirestore.instance;
Map? currenntUser;


FirebaseService();

Future<bool> registerUser({
    required String email,
    required String password,
    required String name,
     File? image,
    Uint8List? imageBytes,
}) async {
    try{
        UserCredential _userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        String _userId = _userCredential.user!.uid;
       // String _fileName = Timestamp.now().millisecondsSinceEpoch.toString() + p.extension(image.path) ;
   // UploadTask _task =  _storage.ref('images/$_userId/$_fileName').putFile(image);
          String? _downloadUrl;

        if (image != null || imageBytes != null) {
            String _fileName = Timestamp.now().millisecondsSinceEpoch.toString();
            Reference ref = _storage.ref('images/$_userId/$_fileName');
            UploadTask _task = image != null 
              ? ref.putFile(image) 
              : ref.putData(imageBytes!); // Use putData for web uploads

            _downloadUrl = await (await _task).ref.getDownloadURL();
        }

        await _db.collection(USER_COLLECTION).doc(_userId).set({
            "name": name,
            "email": email,
            "image": _downloadUrl ?? "",
        });

        return true;
    } catch (e) {
        print(e);
        return false;
    }
}



Future<bool> loginUser({required String email, required String password}) async {
  try{
    UserCredential _userCredential =  await _auth.signInWithEmailAndPassword(email: email , password: password);
  
   if(_userCredential.user != null){
    currenntUser = await getUserData(uid: _userCredential.user!.uid );
    return true;
   }
   else 
    return false;
   
   }catch(e){
        print(e);
        return false;
   }

}

Future <Map?> getUserData({required String uid}) async{
   DocumentSnapshot _doc = await _db.collection(USER_COLLECTION).doc(uid).get();
   return _doc.data() as Map?;
}
  }


