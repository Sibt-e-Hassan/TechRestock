# Firestore catalog schema (production)

Use these collections in Firebase Console. The app reads them dynamically; no code changes are required when you add real data.

## `markets/{marketId}`

| Field | Type | Required | Notes |
|-------|------|----------|--------|
| `name` | string | yes | Display name |
| `location` | string | yes | e.g. `Karachi, Pakistan` |
| `shopCount` | number | yes | Shown on home card |
| `country` | string | yes | Used for country filter |
| `imageUrl` | string | recommended | HTTPS image for home list |
| `title` | string | optional | Legacy; `name` is primary |
| `shopName` | string | optional | Legacy subtitle |
| `badge` | string | optional | e.g. `Trending` |
| `updatedAt` | timestamp | optional | |

## `shops/{shopId}`

| Field | Type | Required | Notes |
|-------|------|----------|--------|
| `name` | string | yes | |
| `category` | string | yes | Grouped on market detail |
| `marketId` | string | yes | Must match a `markets` doc id |
| `imageUrl` | string | recommended | |
| `updatedAt` | timestamp | optional | |

## `products/{productId}`

| Field | Type | Required | Notes |
|-------|------|----------|--------|
| `title` | string | yes | |
| `shopName` | string | yes | Display label |
| `shopId` | string | yes | Links to `shops/{shopId}` for shop detail |
| `priceLabel` | string | yes | e.g. `Rs 4,400` (base per-unit price, display only) |
| `country` | string | yes | Home country filter |
| `imageUrl` | string | recommended | |
| `badge` | string | optional | `New`, `Bulk`, etc. |
| `unit` | string | optional | Wholesale selling unit — `carton`, `bori`, `dozen`, `kg`. Defaults to `unit`. |
| `minOrderQty` | int | optional | Minimum order quantity (MOQ). Defaults to `1`. |
| `priceTiers` | array | optional | Bulk price breaks: `[{ minQty: int, priceLabel: string }]`, ascending by `minQty`. Empty = flat price. |
| `updatedAt` | timestamp | optional | |

## `users/{uid}` / `users/{uid}/cart/{productId}`

Profile: `fullName`, `email`, `createdAt`. Cart items mirror product fields + `quantity`, `addedAt`.

## `orders/{orderId}`

Created by the app on **Send inquiry**: `userId`, `items[]`, `totalPrice`, `itemCount`, `status`, `timestamp`.

---

`lib/utils/firestore_seed.dart` is a **demo template** only (hidden in production builds). Copy field names from its `_markets`, `_shops`, and `_products` lists when entering real documents in Console.
