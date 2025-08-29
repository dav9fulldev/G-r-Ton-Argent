import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<String?> pickAndUploadProfilePhoto(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Sélectionner l'image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) {
        _setLoading(false);
        return null;
      }

      // Upload vers Firebase Storage
      final String fileName = 'profile_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child(fileName);
      
      final UploadTask uploadTask = storageRef.putFile(File(image.path));
      final TaskSnapshot snapshot = await uploadTask;
      
      // Obtenir l'URL de téléchargement
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Mettre à jour Firestore
      await _firestore.collection('users').doc(userId).update({
        'profilePhotoUrl': downloadUrl,
      });

      _setLoading(false);
      return downloadUrl;

    } catch (e) {
      _setError('Erreur lors du téléchargement de la photo: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  Future<String?> takeAndUploadProfilePhoto(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Prendre une photo
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) {
        _setLoading(false);
        return null;
      }

      // Upload vers Firebase Storage
      final String fileName = 'profile_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child(fileName);
      
      final UploadTask uploadTask = storageRef.putFile(File(image.path));
      final TaskSnapshot snapshot = await uploadTask;
      
      // Obtenir l'URL de téléchargement
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Mettre à jour Firestore
      await _firestore.collection('users').doc(userId).update({
        'profilePhotoUrl': downloadUrl,
      });

      _setLoading(false);
      return downloadUrl;

    } catch (e) {
      _setError('Erreur lors de la prise de photo: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  Future<void> deleteProfilePhoto(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Supprimer de Firestore
      await _firestore.collection('users').doc(userId).update({
        'profilePhotoUrl': null,
      });

      _setLoading(false);
    } catch (e) {
      _setError('Erreur lors de la suppression: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> showImageSourceDialog(BuildContext context, String userId, Function(String?) onPhotoUpdated) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final photoUrl = await takeAndUploadProfilePhoto(userId);
                  onPhotoUpdated(photoUrl);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final photoUrl = await pickAndUploadProfilePhoto(userId);
                  onPhotoUpdated(photoUrl);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }
}
