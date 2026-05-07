import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/model_note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Xóa error sau khi UI đã hiển thị
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Chỉ gọi 1 lần khi khởi động app
  Future<void> loadNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await DatabaseHelper.instance.readAll();
    } catch (e) {
      _error = 'Không thể tải danh sách ghi chú';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fix #1: Không gọi lại loadNotes() — cập nhật thẳng vào list
  Future<void> addNote(Note note) async {
    try {
      final id = await DatabaseHelper.instance.create(note);
      // Dùng copyWith để gắn id vừa trả về từ DB
      final newNote = note.copyWith(id: id);
      _notes.insert(0, newNote); // chèn đầu vì sort DESC theo updatedAt
      notifyListeners();
    } catch (e) {
      _error = 'Không thể thêm ghi chú';
      notifyListeners();
    }
  }

  // Fix #1: Cập nhật trực tiếp trong list, sort lại thay vì query DB
  Future<void> updateNote(Note note) async {
    try {
      await DatabaseHelper.instance.update(note);
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
        // Giữ đúng thứ tự updatedAt DESC
        _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
      notifyListeners();
    } catch (e) {
      _error = 'Không thể cập nhật ghi chú';
      notifyListeners();
    }
  }

  // Fix #1: Xóa trực tiếp khỏi list, không query lại DB
  Future<void> deleteNote(int id) async {
    try {
      await DatabaseHelper.instance.delete(id);
      _notes.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Không thể xóa ghi chú';
      notifyListeners();
    }
  }
}
