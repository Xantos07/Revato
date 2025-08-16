# # 🌙 Revato - Journal de Rêves Intelligent

> Notez vos rêves avec Revato, l'application mobile qui révolutionne la tenue d'un journal onirique.

## ✨ Vue d'ensemble

**Revato** est une application mobile innovante développée en Flutter qui permet de capturer, organiser et analyser vos rêves de manière intuitive. Découvrez les patterns cachés de votre subconscient et explorez votre monde onirique comme jamais auparavant.

### 🎯 Pourquoi Revato ?

- **📱 Interface intuitive** : Saisie rapide dès le réveil
- **🧠 Analyses intelligentes** : Statistiques et patterns automatiques  
- **🔒 Confidentialité totale** : Vos données restent locales
- **🎨 Design moderne** : Material Design épuré
- **🌐 Visualisation réseau** : Explorez les connexions entre vos rêves

## 📱 Fonctionnalités

### 🎯 Capture Intelligente
- **Saisie rapide** : Interface optimisée pour capturer vos rêves au réveil
- **Rédactions multicouches** : Structurez vos récits avec différents niveaux de détail
- **Tags personnalisables** : Organisez par thèmes, émotions, et motifs récurrents
- **Catégories flexibles** : Système de classification entièrement personnalisable

### 📊 Analyses Avancées
- **Statistiques visuelles** : Graphiques interactifs de vos patterns de rêves
- **Métriques de qualité** : Suivi de la richesse de vos descriptions
- **Système de streaks** : Motivation avec des séries de journaling quotidien
- **Analyse temporelle** : Tendances par jour, semaine, mois

### 🕸️ Visualisation Réseau
- **Graphe interactif** : Interface web pour explorer les connexions
- **Détection de motifs** : Identification automatique des thèmes récurrents
- **Navigation temporelle** : Voyagez dans votre historique onirique
- **Filtrage avancé** : Recherche multicritères instantanée

### 🏷️ Organisation
- **Glisser-déposer** : Réorganisation intuitive des catégories
- **Filtres intelligents** : Retrouvez vos rêves par critères multiples
- **Interface adaptative** : S'adapte aux thèmes système
- **Performance optimisée** : Expérience fluide même avec de gros volumes

## 🚀 Installation

### Prérequis
- **Flutter** 3.7.2 ou supérieur
- **Dart** SDK 2.19.0+
- **Android Studio** ou **VS Code** avec extensions Flutter/Dart

### Étapes d'installation

1. **Clonez le repository**
```bash
git clone https://github.com/Xantos07/Revato.git
cd Revato/revato_app
```

2. **Installez les dépendances**
```bash
flutter pub get
```

3. **Configurez l'environnement**
```bash
flutter doctor -v
```

4. **Lancez l'application**
```bash
# Debug
flutter run

# Release
flutter build apk --release
```

## 🏗️ Architecture

Revato suit les meilleures pratiques de développement Flutter avec une **architecture MVVM** :

```
📦 lib/
├── 🎨 Screen/           # Écrans de l'application
├── 🔧 widgets/          # Composants réutilisables
├── 🧠 viewmodel/        # Logique de présentation (MVVM)
├── 🏢 services/         # Services métier et données
│   ├── business/        # Logique métier
│   └── repository/      # Accès aux données
├── 💾 database/         # Configuration SQLite
├── 📦 model/            # Modèles de données
└── 🎯 main.dart         # Point d'entrée
```

### Patterns utilisés
- **MVVM** : Séparation claire View/ViewModel/Model
- **Repository Pattern** : Abstraction de l'accès aux données
- **Business Service** : Encapsulation de la logique métier
- **Provider** : Gestion d'état réactive

## 🛠️ Technologies

### Core
- **[Flutter](https://flutter.dev/)** 3.7.2+ - Framework UI multiplateforme
- **[Dart](https://dart.dev/)** - Langage de programmation

### Base de données
- **[SQLite](https://www.sqlite.org/)** via [sqflite](https://pub.dev/packages/sqflite) - Stockage local
- **[shared_preferences](https://pub.dev/packages/shared_preferences)** - Préférences utilisateur

### État et Navigation
- **[Provider](https://pub.dev/packages/provider)** - Gestion d'état
- **Material Navigation** - Navigation native Flutter

### UI/UX
- **Material Design 3** - Design system moderne
- **[webview_flutter](https://pub.dev/packages/webview_flutter)** - Visualisations web intégrées

### Utilitaires
- **[diacritic](https://pub.dev/packages/diacritic)** - Normalisation des caractères
- **[flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)** - Génération d'icônes

## 📊 Fonctionnalités en détail

### Système de Tags et Catégories
- **Catégories prédéfinies** : Lieu, Acteur, Ressenti, Perspective, etc.
- **Tags personnalisés** : Liberté totale de classification
- **Édition visuelle** : Interface glisser-déposer intuitive
- **Validation intelligente** : Prévention des doublons

### Statistiques et Analyses
- **Vue d'ensemble** : Métriques générales (total, fréquence, richesse)
- **Qualité du contenu** : Pourcentage de rêves avec rédactions détaillées
- **Streaks motivants** : Séries de jours consécutifs avec gamification
- **Analyse temporelle** : Patterns par jour/semaine/mois
- **Top tags** : Classification automatique des thèmes populaires

### Interface Web Intégrée
- **Graphe interactif** : Visualisation des connexions entre rêves
- **Navigation fluide** : Zoom, pan, filtres en temps réel
- **Responsive design** : Adapté mobile et desktop
- **Export possible** : Données exportables pour analyse externe

## 🔒 Confidentialité et Sécurité

- **🏠 100% Local** : Aucune donnée envoyée sur internet
- **🔐 Pas de compte** : Utilisation immédiate sans inscription
- **🧹 Suppression facile** : Désinstallation = suppression complète

## 🎨 Captures d'écran

*Screenshots à venir - L'application est en cours de finalisation*

## 🤝 Contribution

Les contributions sont les bienvenues ! Voici comment participer :

### 🐛 Signaler un bug
1. Vérifiez que le bug n'est pas déjà signalé dans les [Issues](https://github.com/Xantos07/Revato/issues)
2. Ouvrez une nouvelle issue avec le template bug
3. Décrivez précisément le problème et les étapes de reproduction

### ✨ Proposer une fonctionnalité
1. Ouvrez une issue avec le template feature request
2. Décrivez clairement la fonctionnalité souhaitée
3. Expliquez pourquoi elle serait utile

### 🔧 Contribuer au code
1. **Fork** le projet
2. Créez votre **branche feature** (`git checkout -b feature/amazing-feature`)
3. **Commit** vos changements (`git commit -m 'Add amazing feature'`)
4. **Push** vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrez une **Pull Request**

## 📋 Roadmap

### 🎯 Version 1.0 (Actuelle)
- [x] Interface de saisie et modification de rêves
- [x] Système de tags et catégories
- [x] Statistiques de base
- [x] Visualisation graphique


### 🚀 Version À venir
- [ ] Export PDF/CSV
- [ ] Thèmes personnalisables
- [ ] Synchronisation cloud optionnelle


## 📄 Licence

Ce projet est sous licence Mozilla Public License Version 2.0 - voir le fichier [LICENSE](../LICENSE) pour plus de détails.


- **[Xantos07](https://github.com/Xantos07)** 

---

<div align="center">

**⭐ Si ce projet vous plaît, n'hésitez pas à lui donner une étoile ! ⭐**

*"Chaque rêve est une fenêtre sur votre inconscient. Revato vous donne les clés pour l'ouvrir."*

---

Made with ❤️ by [Xantos07](https://github.com/Xantos07) | Open Source | Mozilla Public License Version 2.0

