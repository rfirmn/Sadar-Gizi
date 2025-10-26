import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final String bucketName = 'product-images'; 

  /// Upload image ke Supabase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload file ke bucket
      await _client.storage
          .from(bucketName)
          .upload(fileName, imageFile);

      // Ambil URL publik
      final publicUrl =
          _client.storage.from(bucketName).getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('❌ Upload gagal: $e');
      return null;
    }
  }
}
