import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class ImageHelper {
  static final uuid = Uuid();

  // 이미지를 앱의 로컬 저장소에 저장
  static Future<String> saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageName = '${uuid.v4()}${path.extension(imageFile.path)}';
    final imagePath = path.join(directory.path, 'diary_images', imageName);
    
    // 디렉토리가 없으면 생성
    final imageDir = Directory(path.dirname(imagePath));
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    // 이미지 파일 복사
    await imageFile.copy(imagePath);
    return imagePath;
  }

  // 이미지 삭제
  static Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // 다이어리 삭제 시 관련된 모든 이미지 삭제
  static Future<void> deleteAllImagesForDiary(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      await deleteImage(imagePath);
    }
  }
} 