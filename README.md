# 🕐 Chronos - Application de Gestion du Temps

## 📌 Technos utilisées

| Techno | Rôle |
|--------|------|
| **Flutter** | Framework pour créer l'app (iOS, Android, Web, Desktop) |
| **Dart** | Langage de programmation (comme Java/Kotlin mais plus simple) |
| **Isar** | Base de données locale (plus rapide que SQLite, stocke des objets directement) |

### 🗄️ Isar en 2 mots :
- Stocke des **objets Dart** directement (pas besoin de requêtes SQL)
- Fonctionne **hors ligne** (les données restent sur le téléphone)
- **Rapide** même avec 1000+ tâches

---

## 📁 Structure du projet
lib/
├── main.dart # Point d'entrée de l'app
│
├── database/
│ └── app_database.dart # Configuration de la base de données Isar
│
├── models/ # Les "tables" de la base de données
│ ├── task.dart # Tâche (titre, date, description...)
│ ├── category.dart # Catégorie (Travail, Personnel...)
│ ├── priority.dart # Priorité (Basse, Moyenne, Haute)
│ ├── status.dart # Statut (À faire, En cours, Terminé)
│ ├── habit.dart # Habitude (lien vers une tâche)
│ ├── days.dart # Jours de répétition d'une habitude
│ ├── notification.dart # Rappel d'une tâche
│ ├── settings.dart # Paramètres (mode sombre, couleurs...)
│ └── *.g.dart # 📢 Fichiers générés automatiquement (NE PAS TOUCHER)
│
├── repositories/ # La "logique" pour lire/écrire dans la BDD
│ ├── task_repository.dart
│ ├── category_repository.dart
│ ├── priority_repository.dart
│ ├── status_repository.dart
│ ├── habit_repository.dart
│ ├── notification_repository.dart
│ └── settings_repository.dart
│
├── services/ # Services (fonctionnalités transversales)
│ └── (à venir : notifications, thème, synchronisation...)
│
├── views/ # Pages de l'app
│ └── (à venir)
│
└── widgets/ # Petits composants réutilisables
└── (à venir)


> ⚠️ Les fichiers `.g.dart` sont **générés automatiquement** par Isar.  
> **Ne les modifie jamais manuellement !**

### `repositories/`
Chaque repository contient **toutes les méthodes** pour interagir avec une table :
// Exemple avec TaskRepository
taskRepository.getAllTasks()          // Récupère tout
taskRepository.getTaskById(5)         // Récupère une tâche
taskRepository.saveTask(task)         // Crée ou met à jour
taskRepository.deleteTask(5)          // Supprime
taskRepository.getTodayTasks()        // Tâches du jour
taskRepository.getTasksByCategory(2)  // Filtre par catégorie
taskRepository.getLateTasks()         // Tâches en retard

dart run build_runner watch --delete-conflicting-outputs   -> Génère automatiquement les fichiers .g.dart à chaque modification (à laisser tourner)