import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class SupabaseService {
  static final supabase = Supabase.instance.client;
  
  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      final String path = 'public/$fileName';
      await supabase.storage
          .from('images')
          .uploadBinary(path, imageBytes);
      
      // Get public URL
      final String imageUrl = supabase.storage
          .from('images')
          .getPublicUrl(path);
      
      return imageUrl;
    } catch (e) {
      print('Error uploading to Supabase: $e');
      return null;
    }
  }
}