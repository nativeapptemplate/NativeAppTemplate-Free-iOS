# Pagination for ItemTags Index API

## Context

The `GET /api/v1/shopkeeper/shops/{shop_id}/item_tags` endpoint currently returns all item tags without pagination. Adding Pagy pagination with backward-compatible behavior so existing clients continue working.

## Current State

- **Pagy 43** already installed and configured (`config/initializers/pagy.rb`: default limit 20)
- **`Pagy::Method`** already included in `Display::BaseController` — not yet in the shopkeeper API base controller
- **Response format:** JSON:API via `jsonapi-serializer` gem (`{ data: [...], included: [...] }`)
- **Neither iOS nor Android** clients send pagination params or parse pagination metadata

## API Changes

### Request

New optional query parameter:
- `page` (integer) — page number, defaults to 1

When `page` param is present, returns 20 items per page (Pagy default).
When `page` param is absent, returns up to 1000 items (backward compat — remove once clients are updated).

### Response

New `meta` key added to top-level JSON:API response:

```json
{
  "data": [...],
  "included": [...],
  "meta": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 55,
    "limit": 20
  }
}
```

## Backend Implementation (Rails API)

### Files to modify

1. **`app/controllers/api/v1/shopkeeper/base_controller.rb`**
   - Add `include Pagy::Backend`
   - Add private `pagy_meta(pagy)` helper

2. **`app/controllers/api/v1/shopkeeper/item_tags_controller.rb`**
   - Update `index` action to use `pagy()` with backward-compat limit logic
   - Add `meta` option to serializer

3. **`test/controllers/api/v1/shopkeeper/item_tags_controller_test.rb`**
   - Test pagination meta presence
   - Test pagination with explicit page param
   - Test overflow returns empty data
   - Test backward compat (no page param returns large limit)

4. **`docs/openapi.yaml`**
   - Add `page` query parameter to item_tags index
   - Add `meta` object to response schema

### Code changes

**base_controller.rb** — add after existing includes:
```ruby
include Pagy::Method

# in private section:
def pagy_meta(pagy)
  {
    current_page: pagy.page,
    total_pages:  pagy.pages,
    total_count:  pagy.count,
    limit:        pagy.limit
  }
end
```

**item_tags_controller.rb** — replace index:
```ruby
def index
  authorize ItemTag

  @pagy, @item_tags = pagy(
    @shop.item_tags.order(queue_number: :asc).includes(:shop),
    limit: params[:page].present? ? Pagy::OPTIONS[:limit] : 1000
  )

  options = {}
  options[:include] = [:shop]
  options[:meta] = pagy_meta(@pagy)
  render json: ItemTagSerializer.new(@item_tags, options).serializable_hash
end
```

## iOS Client Changes

### Usage of `GET /shops/{shop_id}/item_tags`

This endpoint is used in two places:
1. **`UI/Shop Settings/ItemTag List/ItemTagListView.swift`** — item tag management list (should paginate)
2. **`UI/Shop Detail/ShopDetailView.swift`** — shop overview (should retrieve all item_tags, no `page` param)

ShopDetailView should continue calling without `page` param to get all items (backward-compat limit 1000). Only ItemTagListView should send `page` param for paginated results.

### Files to modify

1. **`Networking/Requests/ItemTagsRequest.swift`** — `GetItemTagsRequest`
   - Add optional `page` query parameter

2. **`Networking/JSONAPI/JSONAPIDocument.swift`** (or create `PaginationMeta`)
   - Parse `meta` from response into a pagination struct

3. **`Models/PaginationMeta.swift`** (new)
   - Struct: `currentPage`, `totalPages`, `totalCount`, `limit`

4. **`Data/Repositories/ItemTagRepository.swift`**
   - Update `reload(shopId:)` to accept optional page param
   - Store pagination meta alongside item tags
   - Add `loadMore(shopId:)` or `loadPage(shopId:page:)` method

5. **`UI/Shop Settings/ItemTag List/ItemTagListViewModel.swift`**
   - Implement "load more" or infinite scroll logic
   - Track current page and whether more pages exist

6. **`UI/Shop Settings/ItemTag List/ItemTagListView.swift`**
   - Add scroll-to-bottom trigger for loading next page
   - Show loading indicator during pagination

7. **`UI/Shop Detail/ShopDetailView.swift`** (or its ViewModel)
   - No changes needed — continue calling without `page` param to get all items

## Android Client Changes

### Files to modify

1. **`data/item_tag/ItemTagApi.kt`**
   - Add `@Query("page") page: Int?` parameter to `getItemTags()`

2. **`data/item_tag/model/Meta.kt`** (or new `PaginationMeta.kt`)
   - Parse pagination fields from `meta` object (already has a `Meta` class — may need to add pagination fields)

3. **`data/item_tag/ItemTagRepositoryImpl.kt`**
   - Accept page parameter in fetch methods
   - Store pagination state

4. **`ui/shop_settings/item_tag_list/ItemTagListViewModel.kt`**
   - Implement pagination state management
   - Add `loadMore()` function

5. **`ui/shop_settings/item_tag_list/ItemTagListScreen.kt`** (or equivalent composable)
   - Add infinite scroll / load more UI

## Migration Strategy

1. Deploy API with backward-compat (large limit when no page param) — **do this first**
2. Update iOS and Android clients:
   - ItemTagListView/Screen: send `page` param and handle `meta` for pagination
   - ShopDetailView/Screen: keep calling without `page` param (gets all items)
3. The backward-compat large limit should remain long-term since ShopDetailView needs all items
