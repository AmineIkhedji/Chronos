// lib/utils/validators.dart
class Validators {
  // ============ VALIDATIONS COMMUNES ============

  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le titre est obligatoire';
    }
    if (value.trim().length < 3) {
      return 'Le titre doit contenir au moins 3 caractères';
    }
    if (value.trim().length > 100) {
      return 'Le titre ne doit pas dépasser 100 caractères';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length > 500) {
      return 'La description ne doit pas dépasser 500 caractères';
    }
    return null;
  }

  static String? validateCategory(int? categoryId) {
    if (categoryId == null || categoryId == 0) {
      return 'La catégorie est obligatoire';
    }
    return null;
  }

  static String? validatePriority(int? priorityId) {
    if (priorityId == null || priorityId == 0) {
      return 'La priorité est obligatoire';
    }
    return null;
  }

  static String? validateStatus(int? statusId) {
    if (statusId == null || statusId == 0) {
      return 'Le statut est obligatoire';
    }
    return null;
  }

  static String? validateDays(Set<int> days) {
    if (days.isEmpty) {
      return 'Veuillez sélectionner au moins un jour';
    }
    return null;
  }

  static String? validateCustomizationName(String? value, String itemType) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom de $itemType est obligatoire';
    }
    if (value.trim().length < 2) {
      return 'Le nom de $itemType doit contenir au moins 2 caractères';
    }
    if (value.trim().length > 50) {
      return 'Le nom de $itemType ne doit pas dépasser 50 caractères';
    }
    return null;
  }
}
