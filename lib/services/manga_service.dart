import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:mangadive/models/manga.dart';

class MangaService {
  // TODO: Thay thế các giá trị này bằng thông tin Cloudinary thực tế của bạn
  final cloudinary = CloudinaryPublic(
    'your-cloud-name',
    'your-upload-preset',
    cache: false,
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'mangas';

  // Upload ảnh lên Cloudinary
  Future<String> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, folder: 'manga_covers'),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Không thể upload ảnh: $e');
    }
  }

  // Thêm manga mới
  Future<void> addManga(Manga manga) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(manga.id)
          .set(manga.toJson());
    } catch (e) {
      throw Exception('Không thể thêm manga: $e');
    }
  }

  // Lấy danh sách manga
  Future<List<Manga>> getMangas() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection(collectionName)
              .orderBy('updatedAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Manga.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách manga: $e');
    }
  }

  // Lấy manga theo ID
  Future<Manga?> getMangaById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(collectionName).doc(id).get();
      if (doc.exists) {
        return Manga.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể lấy manga: $e');
    }
  }

  // Cập nhật manga
  Future<void> updateManga(Manga manga) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(manga.id)
          .update(manga.toJson());
    } catch (e) {
      throw Exception('Không thể cập nhật manga: $e');
    }
  }

  // Xóa manga
  Future<void> deleteManga(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Không thể xóa manga: $e');
    }
  }

  // Tăng lượt xem
  Future<void> incrementViewCount(String mangaId) async {
    try {
      await _firestore.collection(collectionName).doc(mangaId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Không thể tăng lượt xem: $e');
    }
  }
}
