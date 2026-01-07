# Marketplace + Rentals (Flutter)

This zip contains a **ready `lib/` source** + `pubspec.yaml` for:
- Landing page (4 roles)
- Login
- Bottom navigation per role
- Furniture marketplace: add listing (seller) + browse/filter (buyer)
- Real estate rentals: search/filter (tenant) + add property (landlord)
- Local storage using **Hive** (no Firebase)
- RTL Arabic UI (with English-ready structure)

## How to run (fast)
1) Create a new Flutter app on your machine:
```bash
flutter create marketplace_rentals
cd marketplace_rentals
```

2) Replace the generated **lib/** folder and `pubspec.yaml` with the ones from this zip.

3) Get packages + run:
```bash
flutter pub get
flutter run
```

## Notes
- Media picking is implemented as UI + basic selection (paths), ready to extend.
- Storage uses Hive boxes storing Maps (no adapters yet) to keep setup simple.
# world_souq
