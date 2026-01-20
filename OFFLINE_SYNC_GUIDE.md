# Offline Sync Implementation Guide

## Overview

Your POS app now supports offline functionality for sales, purchases, and products. When the device loses internet connectivity, data is automatically saved to a local SQLite database and synced to the server when connectivity is restored. Sales and products also support offline reads by caching the latest server data locally and merging it with unsynced records.

## Features Implemented

### 1. Offline Storage
- **Sales**: Can be created offline and automatically synced when online
- **Purchases**: Can be created offline and automatically synced when online
- **Products**: Can be created offline and automatically synced when online
- **Product images**: Local file paths are stored for offline-created products and uploaded during sync

### 2. Automatic Sync
- The app monitors internet connectivity in real-time
- When internet connection is restored, pending data automatically syncs to the server
- Sync happens in the background without user interaction

### 3. User Feedback
- Users receive clear messages when data is saved offline
- Success messages indicate when data is synced successfully
- If an upload fails while online, the app saves the data offline and notifies the user

## How It Works

### Architecture

1. **DatabaseHelper** (`lib/Database/database_helper.dart`)
   - Manages SQLite database for offline storage
   - Tables: `offline_sales`, `offline_purchases`, `offline_products`, `sync_queue`, `cached_sales`, `cached_products`, `cached_meta`
   - Tracks sync status for all offline records
   - Caches server data for offline reads

2. **ConnectivityService** (`lib/Services/connectivity_service.dart`)
   - Monitors internet connectivity using `internet_connection_checker_plus`
   - Broadcasts connectivity changes to the app
   - Provides real-time connectivity status

3. **SyncService** (`lib/Services/sync_service.dart`)
   - Listens for connectivity changes
   - Automatically syncs pending data when online
   - Handles retry logic and error management
   - Syncs in order: Products → Purchases → Sales

4. **Updated Repositories**
   - `SaleRepo` (`lib/Screens/Sales/Repo/sales_repo.dart`)
   - `PurchaseRepo` (`lib/Screens/Purchase/Repo/purchase_repo.dart`)
   - Both check connectivity before API calls
   - Save data offline if no internet connection

### Workflow

#### Creating a Sale/Purchase Offline:

1. User creates a sale or purchase
2. App checks internet connectivity
3. If offline:
   - Data is saved to local SQLite database
   - User sees: "Sale/Purchase saved offline! Will sync when online."
   - UI is updated locally
4. If online:
   - Data is sent directly to the server
   - Normal flow continues

#### Offline Reads:
1. When online, sales/products lists are cached locally
2. When offline, cached data is shown and merged with unsynced records
3. Offline-created products use local images when available

#### Automatic Sync:

1. Device regains internet connection
2. ConnectivityService detects the change
3. SyncService automatically starts syncing:
   - Retrieves all unsynced records from database
   - Sends them to the server in order
   - Marks successfully synced records
   - Retries failed syncs on next connectivity change

## Database Schema

### offline_sales
```sql
- id (PRIMARY KEY)
- party_id
- customer_phone
- sale_date
- discount_amount
- discount_percent
- total_amount
- due_amount
- vat_amount
- vat_percent
- vat_id
- change_amount
- is_paid
- payment_type
- rounded_option
- rounding_amount
- unrounded_total_amount
- discount_type
- shipping_charge
- note
- products (JSON)
- image_path (TEXT)
- created_at
- synced (0 or 1)
```

### offline_purchases
```sql
- id (PRIMARY KEY)
- party_id
- vat_id
- purchase_date
- discount_amount
- discount_percent
- total_amount
- vat_amount
- vat_percent
- due_amount
- change_amount
- is_paid
- payment_type
- discount_type
- shipping_charge
- products (JSON)
- created_at
- synced (0 or 1)
```

### offline_products
```sql
- id (PRIMARY KEY)
- product_data (JSON)
- image_path (TEXT)
- created_at
- synced (0 or 1)
```

### sync_queue
```sql
- id (PRIMARY KEY)
- operation_type (POST/PUT/DELETE)
- endpoint (API URL)
- data (JSON)
- created_at
- retry_count
- status (pending/completed)
- error_message
```

### cached_sales / cached_products
```sql
- id (PRIMARY KEY)
- data (JSON)
- updated_at (TEXT)
```

### cached_meta
```sql
- key (PRIMARY KEY)
- value (TEXT)
- updated_at (TEXT)
```

## Testing

### Test Offline Mode:
1. Turn off internet/WiFi on your device
2. Create a sale or purchase
3. Verify you see "Saved offline! Will sync when online."
4. Turn internet back on
5. Check server logs to verify data was synced

### Test Auto-Sync:
1. Create multiple sales/purchases offline
2. Enable internet connection
3. Watch console logs for sync progress
4. Verify all data appears on the server

## Configuration

### Adjusting Sync Behavior

In `lib/Services/sync_service.dart`, you can modify:
- Sync order (currently: Products → Purchases → Sales)
- Retry logic
- Error handling
- Sync frequency

### Monitoring Sync Status

You can check pending sync count:
```dart
final syncService = SyncService();
final pendingCount = await syncService.getPendingSyncCount();
print('Pending items: $pendingCount');
```

### Manual Sync Trigger

To manually trigger sync:
```dart
final syncService = SyncService();
await syncService.syncAll();
```

### Clear Synced Data

To clean up synced records from local database:
```dart
final syncService = SyncService();
await syncService.clearSyncedData();
```

## Dependencies Added

```yaml
sqflite: ^2.3.0  # Local SQLite database
```

Existing dependencies used:
- `internet_connection_checker_plus`: For connectivity monitoring
- `path_provider`: For database file location

## Future Enhancements

Consider implementing:
1. **Sync Status UI**: Show users pending sync count in the UI
2. **Conflict Resolution**: Handle cases where same data is modified on server
3. **Partial Sync**: Sync in batches for better performance
4. **Manual Retry**: Allow users to manually retry failed syncs
5. **Sync History**: Keep logs of sync operations
6. **Background Sync**: Use background tasks for syncing
7. **Media Handling**: Extend offline image/file sync to other entities
8. **Product Updates**: Support updating existing products offline

## Troubleshooting

### Data Not Syncing:
- Check console logs for error messages
- Verify internet connectivity
- Check server API endpoints are accessible
- Verify auth token is valid

### Duplicate Data:
- Ensure sync marks records as synced properly
- Check if network timeout is causing duplicate attempts

### Slow Sync:
- Consider implementing batch syncing
- Add loading indicators for user feedback
- Optimize database queries

## Notes

- Images attached to sales are NOT currently supported in offline mode
- Product creation offline is scaffolded but needs API endpoint implementation
- Sync happens automatically on connectivity restore
- Failed syncs will retry on next connectivity change
- All timestamps use ISO 8601 format
