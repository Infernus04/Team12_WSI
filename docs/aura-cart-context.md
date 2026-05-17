# Aura Cart Context

## Problem Statement
Williams-Sonoma shoppers are rarely looking for a single SKU in isolation. They are trying to build a mood, a tabletop story, a hosting setup, or a complete culinary experience. A normal ecommerce cart does not help them understand whether pieces belong together, what is missing, or what choice is weakening the overall purchase.

The result is hesitation, fragmented purchases, and lower confidence in premium products.

## Cart-Only Scope
This implementation is intentionally limited to the Cart tab and its mock checkout continuation.

Included:
- cart relationship analysis
- aesthetic confidence and completeness scoring
- completion, swap, and cross-brand bundle suggestions
- occasion-aware cart mode
- reasoning-led recommendation cards
- a premium cart presentation layer
- a full mock checkout flow through confirmation

Not included:
- Home tab redesign
- Registry redesign
- real payment processing
- real order creation infrastructure
- live LLM integration

## Solution Direction
Aura acts as a deterministic purchase-confidence engine for the cart.

It should:
- understand how products relate to one another
- identify when two items harmonize
- identify when one item clashes with the rest of the cart
- recommend a missing third piece when a set feels incomplete
- preserve the strongest anchor item during swap suggestions
- introduce cross-brand discovery when it improves the composition
- explain every suggestion in plain, high-trust language

## AI Rules
The current implementation is backend-based and deterministic.

### Catalog Normalization
- normalize stringified array metadata from `Backend/responses/skus.json`
- repair the known image alias for the Le Creuset demi kettle
- parse brand, color, material, collection, and pattern values into reusable tokens

### Pair Scoring Weights
- collection match: `+30`
- material match: `+20`
- color family match: `+15`
- pattern or aesthetic alignment: `+10`
- complementary product type/family: `+10`
- cross-brand complement: `+5`

### Clash Penalties
- conflicting statement patterns
- conflicting strong color stories
- competing hero pieces with no clear anchor

### Output Behaviors
- choose one anchor item based on average compatibility
- return pair relationships as `match`, `neutral`, or `clash`
- map the cart to one of four aesthetic labels:
  - `Heritage Culinary`
  - `Warm Utility`
  - `Tabletop Classic`
  - `Statement Entertaining`
- keep completeness states:
  - `incomplete`
  - `building`
  - `complete`
  - `clashing`

## Recommendation Rules
- return at most three cards to keep the cart calm
- recommendation types:
  - `completion`
  - `swap`
  - `bundle`
- completion:
  - use the strongest current pair or single anchor
  - suggest the most compatible missing piece
- swap:
  - keep the strongest anchor
  - replace the lowest-compatibility outlier
- bundle:
  - favor a different brand
  - keep the composition feeling intentional

Every recommendation includes:
- title
- badge
- reasoning text
- suggested item
- projected harmony impact

## Occasion Mode
Supported modes:
- `auto`
- `everyday`
- `hosting`
- `gifting`

`auto` is inferred from the cart mix. Manual override re-ranks suggestions and slightly changes the framing without replacing the underlying scoring model.

## API Contracts

### `GET /skus`
Unchanged catalog response for the app’s shop and registry surfaces.

### `POST /cart/analyze`
Request:

```json
{
  "items": [
    { "productId": "2453926", "quantity": 1 }
  ],
  "occasionMode": "auto"
}
```

Response:

```json
{
  "confidenceScore": 78,
  "overallAesthetic": "Heritage Culinary",
  "completenessStatus": "building",
  "activeOccasionMode": "everyday",
  "relationships": [],
  "recommendations": []
}
```

### `POST /checkout/quote`
Request:

```json
{
  "items": [
    { "productId": "2453926", "quantity": 1 }
  ],
  "shippingAddress": {
    "firstName": "Aura",
    "lastName": "Shopper",
    "address1": "1 Market St",
    "address2": "",
    "city": "San Francisco",
    "state": "CA",
    "postalCode": "94105",
    "country": "US"
  }
}
```

Response:

```json
{
  "subtotal": 329.95,
  "shippingOptions": [],
  "tax": 27.22,
  "total": 369.17
}
```

### `POST /checkout/submit`
Request:

```json
{
  "items": [
    { "productId": "2453926", "quantity": 1 }
  ],
  "shippingAddress": {},
  "deliveryOptionId": "standard",
  "paymentSummary": {
    "cardholderName": "Aura Shopper",
    "cardBrand": "Visa",
    "maskedNumber": "•••• 4242"
  },
  "occasionMode": "hosting"
}
```

Response:

```json
{
  "orderId": "AURA-12345678",
  "placedAt": "2026-05-16T17:00:00.000Z",
  "estimatedDelivery": "5-7 business days",
  "confirmationMessage": "Your Aura cart is confirmed."
}
```

## Premium UI Direction
The cart should feel editorial, calm, and high-trust rather than transactional.

Design cues:
- warm ivory and cream surfaces
- walnut and charcoal text hierarchy
- muted gold used sparingly as an accent
- serif headlines with clean sans-serif body copy
- spacious card layouts
- premium borders instead of heavy chrome
- quiet motion and understated transitions

Reference mood:
- luxury interiors
- premium tabletop styling
- quiet-luxury brand presentation

## Verification Notes
The backend has deterministic recommendation tests in `Backend/test/cart.test.js`.

The iOS side currently relies on manual verification because `xcodebuild` is unavailable in this environment due Command Line Tools being active instead of full Xcode.
