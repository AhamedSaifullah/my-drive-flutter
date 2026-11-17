# Project Memory

## Cloud storage integration plan

This project will support linking external cloud storage providers, beginning with
Google Drive and later adding Dropbox. The backend owns provider OAuth credentials,
provider tokens, synchronization, and file metadata. Flutter owns the signed-in user
experience and never receives or stores provider access/refresh tokens.

### End-to-end Google Drive flow

1. The user signs in to My Drive and receives the My Drive JWT.
2. From the dashboard, Flutter calls `POST /cloud/google/link` with that JWT.
3. NestJS creates a short-lived, signed `state` containing the user ID and a nonce,
   then returns the provider authorization URL.
4. Flutter opens that URL in the system browser using `flutter_web_auth_2`. Do not
   use an embedded WebView because Google blocks embedded OAuth user agents.
5. After consent, Google redirects to the public NestJS HTTPS callback:
   `GET /cloud/google/callback?code=...&state=...`.
6. NestJS verifies the state, exchanges the authorization code, encrypts the
   provider access and refresh tokens, and saves them for the user.
7. NestJS redirects to the app deep link
   `mydrive://linked?provider=google`.
8. Flutter handles the deep link, routes back to the dashboard, and reloads cloud
   account and file data.

The callback URL must be HTTPS and registered with the provider. During development,
use a tunnel such as ngrok and register that public callback URL. Provider client
secrets and provider tokens must remain on the server.

### Backend data model

`cloud_accounts`:

- `userId`
- `provider`
- `providerAccountId`
- `encryptedAccessToken`
- `encryptedRefreshToken`
- `expiresAt`
- `status`

`files`:

- `cloudAccountId`
- `providerFileId`
- `name`
- `mimeType`
- `category`: `image`, `video`, `audio`, `document`, or `other`
- `size`
- `modifiedAt`
- `thumbnailUrl`
- `parentId`

Recommended constraints and indexes are a unique provider-account identity per cloud
account and user, a unique `(cloudAccountId, providerFileId)` pair, and indexes for
`category`, `modifiedAt`, and `parentId` to support dashboard pagination and folders.

### Security requirements

- Encrypt provider tokens at rest with AES-256-GCM.
- Keep the encryption key outside the database, preferably in deployment secret
  management or a KMS-backed secret.
- Never log provider access tokens, refresh tokens, client secrets, or authorization
  codes. The existing Flutter login debug logging must also be removed or redacted
  before release.
- Sign and expire OAuth state, include a nonce, and enforce one-time use to prevent
  tampering and replay. Do not trust a user ID from an unsigned state value.
- Keep the My Drive JWT in the app's secure storage; provider tokens must never be
  sent to Flutter.

### Classification and synchronization

- For Google Drive, classify by MIME type. Use server-side Drive queries such as
  `mimeType contains 'image/'` where appropriate, plus an explicit document MIME
  type list.
- Dropbox MIME types are not sufficiently reliable for classification, so use the
  file extension as a fallback or primary classifier.
- Run the first provider import in a BullMQ background job.
- Use Google Drive's Changes API for incremental synchronization.
- Use Dropbox cursors for incremental listing and webhooks when available.
- Make sync idempotent with provider IDs and upserts. Add pagination, retry with
  backoff, and server-side provider token refresh.

Suggested application endpoints are:

- `POST /cloud/google/link`
- `GET /cloud/google/callback`
- `GET /cloud/accounts`
- `GET /files?category=image&page=1`
- `GET /files/summary`
- An optional provider unlink endpoint and file download/temporary-link endpoint.

The exact endpoint names and response shapes remain a backend contract to confirm.

### Flutter architecture implications

Add a feature such as `lib/features/cloud/` using the same feature-first pattern as
auth:

- `data/cloud_api.dart` for raw Dio calls
- `data/cloud_repository.dart` for mapping responses and errors
- `data/models/` for cloud-account, file, summary, and link-response DTOs
- `presentation/cloud_controller.dart` for Riverpod state
- presentation widgets/pages for account linking, file categories, summaries, and
  loading/error/empty states

The UI must call the repository/controller, never Dio directly. The existing Dio
client and auth interceptor should attach the My Drive bearer token. A dedicated
browser-auth service should call `flutter_web_auth_2`, and GoRouter should have a
deep-link completion route (for example `/linked`) that invalidates cloud account,
file, and summary providers before returning to `/home`.

The dashboard should expose a **Link Google Drive** action, show link/sync status,
and refresh after the OAuth callback. Provider-specific linking should be modeled so
Dropbox can be added without changing the dashboard's core file UI.

### Open decisions before implementation

- Final NestJS callback host and deep-link scheme configuration.
- Google OAuth scopes and Google Cloud consent-screen/client configuration.
- Dropbox scopes and redirect configuration.
- Exact backend response contracts and error format.
- Encryption-key management and rotation policy.
- Redis/BullMQ deployment and sync scheduling policy.
- Whether files are streamed through the API or exposed through short-lived provider
  links. Google thumbnails may require an authorized server request; Dropbox supports
  temporary links.

### Current app context

The Flutter app already uses GoRouter for auth redirects, Riverpod for state, Dio
through repositories, and `FlutterSecureStorage` for the My Drive JWT. The cloud
integration should preserve those boundaries and should be implemented only after
the corresponding NestJS OAuth callback and token-storage APIs are available.
