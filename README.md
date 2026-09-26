# Chronos

Application mobile Flutter de gestion du temps : tâches, habitudes, calendrier et statistiques.

Les données restent sur l’appareil (base locale Isar). Aucun compte ni serveur n’est requis.

## Fonctionnalités

- **Accueil** — aperçu du jour : salutation, mini-calendrier, tâches et habitudes
- **Tâches** — titre, description, date, horaires, catégorie, priorité, statut, couleur
- **Habitudes** — répétition sur les jours choisis, suivi quotidien
- **Calendrier** — vues jour, 3 jours, semaine, mois et kanban
- **Statistiques** — progression du jour, semaine et vue d’ensemble
- **Rappels** — notifications locales pour les tâches
- **Personnalisation** — thème clair/sombre, couleur principale, premier jour de la semaine
- **Tutoriel** — guidage au premier lancement

Navigation principale : Accueil, Calendrier, Stats, Réglages.

## Stack technique

| Techno | Rôle |
|--------|------|
| Flutter / Dart | Interface et logique de l’application |
| Riverpod | Gestion d’état |
| Isar (community) | Base de données locale, hors ligne |
| flutter_local_notifications | Rappels sur l’appareil |

Autres dépendances utiles : `intl` et `timezone` (dates), `permission_handler` (autorisations), `shared_preferences` (petits réglages).

## Architecture

Le code suit une séparation simple : **écran → état (Riverpod) → dépôt → base**.

```
lib/
├── main.dart                 Point d’entrée
├── database/                 Ouverture d’Isar
├── models/                   Entités persistées (tâche, habitude, etc.)
├── repositories/             Lecture / écriture en base
├── providers/                État exposé à l’UI (Riverpod)
├── controllers/              Actions métier (tâches, habitudes)
├── services/                 Init, notifications, thème, profil
├── views/                    Écrans
├── widgets/                  Composants réutilisables
└── utils/                    Dates, couleurs, validations
```

Les fichiers `*.g.dart` dans `models/` sont **générés** par Isar. Ne pas les modifier à la main.

## Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) 3.44.4 ou une version récente du canal stable
- SDK Dart compatible (`^3.12.2`, voir `pubspec.yaml`)

Vérifier l’installation :

```bash
flutter doctor
```

## Lancer le projet

```bash
git clone <url-du-depot>
cd chronos
flutter pub get
flutter run
```

Pour viser une plateforme précise : `flutter run -d android`, `-d ios`, `-d windows`, etc.

## Génération de code (Isar)

Après un changement dans un modèle annoté (`@collection`) :

```bash
dart run build_runner build --delete-conflicting-outputs
```

En continu pendant le développement :

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Qualité et CI

En local :

```bash
dart format .
flutter analyze
flutter test
```

Sur GitHub Actions (branche `main` et tags `v*`) : formatage, analyse, tests, scan de secrets (Gitleaks), analyse statique (Semgrep), compilation APK debug. Un tag `v1.0.0` déclenche aussi une APK de release signée.

## Modèle de données (aperçu)

| Entité | Contenu |
|--------|---------|
| Task | Titre, description, date, horaires, couleur, catégorie, priorité, statut |
| Habit | Titre, description, couleur, catégorie |
| Days | Jours de répétition d’une habitude |
| Notification | Rappel lié à une tâche |
| Category / Priority / Status | Listes de référence (valeurs par défaut au premier lancement) |
| Settings | Thème, couleurs, notifications, nom, premier jour de la semaine |

## Licence

Projet non publié (`publish_to: 'none'`). Aucun fichier de licence n’est fourni dans le dépôt pour le moment.
