# Dream Valley 2.0 — Native Build Device Test Plan (#35)

The 2.0 native build adds the paywall-capable pieces. **Nothing native was
executable before this** — every piece is logic-verified but unrun. This is the
real test pass. Run it methodically before submission.

All pieces ship DARK. `PAYWALL_NATIVE_ENABLED` flips only AFTER approval AND a
deliberate, separate owner decision.

> **v1 = TEXT-ONLY native upgrade (supersedes D1).** The native upgrade CTA is
> informational only — "Subscribe at dreamvalley.app", no tappable checkout
> link/button. The v1 native monetization bridge is: free → text-only CTA →
> user subscribes on **web** → returns → **restore** (or same-session
> boot-read) activates premium. Restore (A/D) + boot-read ARE the whole v1
> bridge. **Scenario 1 (native in-app pay) does NOT exist in v1** and is removed
> from this plan. The openExternal bridge + Stripe-return re-fetch are BUILT and
> intact but DORMANT on native v1 (no native branch triggers them) — kept for
> IAP-next / web use. IAP is the planned **immediate next version** (~v2.1);
> text-only is the fast-safe v1 while IAP is built, not the permanent model.

---

## 0. Prerequisites & test arrangement (READ FIRST — the plan is unrunnable without this)

### 0.1 The dormancy problem
On prod, native is **dormant**: `PAYWALL_NATIVE_ENABLED=false` → the backend
forces `is_premium=true` for every `DreamValleyApp/*` UA. So on a prod-pointing
build, **every native user is premium regardless** — you cannot observe
free-vs-premium, which scenarios 2 (premium half) and 4 require.

**Resolution — test against a non-prod environment with native paywall ON:**
- Build variant with `kAppUrl` → the **Vercel test web URL** (not
  `https://dreamvalley.app`), backed by the **Render test backend**.
- On that test backend set `PAYWALL_NATIVE_ENABLED=true` + Stripe **test** keys
  + a live test price/webhook. Prod stays dark and untouched.
- Alternative (riskier, not recommended): a code change letting
  `PAYWALL_TEST_FAMILY_IDS` bypass native dormancy on prod for one test family.
  Avoid unless you can't stand up the test env — it edits the dormancy gate.

The **non-entitlement mechanics** (Keychain, boot-read identity adoption,
external-checkout open, resume trigger, restore email→code→token) ARE observable
on a prod-pointing build (they don't depend on the paywall being active). Only
the free-vs-premium *reflection* needs the test env.

### 0.2 Inspectable build for the deep checks
The `_selfTest()` probe, log reading, and web-state inspection need an
**inspectable** WebView. Use a **debug or profile build on a physical device**
(`flutter run --profile`) for those — release/TestFlight WKWebView is NOT
inspectable on iOS 16.4+ unless inspectability is explicitly enabled.
Use the **TestFlight release build** for distribution sanity + black-box flow.

### 0.3 How to read the verification signals
- **Native logs** — iOS: Xcode → Devices & Simulators → Open Console (filter
  `DVAuth` / `DVSystem`). Android: `adb logcat | grep -E "DVAuth|DVSystem"`.
- **WebView JS console** — iOS: Safari → Develop → [device] → [the WebView] →
  Web Inspector. Android: `chrome://inspect`. Run `window.DreamValleyAuth…`,
  read `localStorage`, watch Network for `/users/me` + `/subscriptions/current`.
- **PostHog** (if wired): `native_token_adopted {result}`, `restore_succeeded`,
  `restore_keychain_failed`.

### 0.4 Test data to prepare
- Two emails you control (one = a subscribed test family's payment-receipt
  email; one = an unknown email).
- A test family that subscribed on **web** (has `recovery_email` + active sub).
- A way to cancel that sub (Stripe test dashboard) for the scenario-4 setup.
- Stripe test card `4242 4242 4242 4242`, any future expiry/CVC.
- A physical iOS device (ideally also an older one for the lag/legacy pass) +
  a physical Android device.
- If testing legacy regression: a 1.0 build (App Store version or a 1.0 archive).

---

## 1. (B) Keychain — real-device storage + uninstall-wipe

Inspectable build. WebView Web Inspector open.

- [ ] `window.DreamValleyAuth.isAvailable === true` (bridge present; UA is 2.0).
- [ ] `await window.DreamValleyAuth._selfTest()` → **`{ok:true}`**
      (store→read→clear→read-after-clear all correct against the REAL Keychain).
- [ ] `await window.DreamValleyAuth.storeToken('probe-123')` → `true`, then
      `await window.DreamValleyAuth.readToken()` → `'probe-123'`. Log shows
      `[DVAuth] store: success (write-back verified...)`.
- [ ] Sign in / restore so a REAL family token is stored. Note it.
- [ ] **UNINSTALL** the app completely (delete from home screen).
- [ ] **REINSTALL** + launch.
- [ ] `await window.DreamValleyAuth.readToken()` → **`null`** (Keychain wiped on
      uninstall, as designed). *If non-null, that's a finding — the
      uninstall-wipe assumption is wrong; revisit the "survives via restore, not
      persistence" promise.*
- [ ] App is NOT stuck: it falls to a fresh anon device-mint and `/restore` is
      reachable → user can re-restore. (Falls to restore, not a crash/lock.)

---

## 2. Native upgrade CTA is TEXT-ONLY (v1 — no in-app pay)

Any build (the CTA gating is `isNativeApp()`, paywall-flag independent).

- [ ] On native, the upgrade screen (`/upgrade`) shows **"Subscribe at
      dreamvalley.app, then restore below."** as TEXT — NO checkout button, NO
      tappable external-payment link, NO StoreKit buy button.
- [ ] A **"Restore subscription"** button is present → tapping it opens
      `/restore` (the working v1 bridge).
- [ ] In the player's locked-content gate, native shows the same text-only
      "Subscribe at dreamvalley.app" + a "Restore subscription" link to
      `/restore`.
- [ ] Confirm tapping upgrade does NOT open external Safari and does NOT fire
      `[DVSystem] openExternal` (the openExternal/Stripe-return bridge is
      dormant on native v1 — built but untriggered).

*Scenario 1 (native in-app pay) is intentionally absent in v1 — see the
text-only callout at the top. Native users subscribe on web, then restore.*

---

## 3. Scenario 2 — web subscriber, fresh native install (restore + persist)

Test env. A family subscribed on web (recovery_email set). Fresh native install.

- [ ] Fresh install → onboard → free anon.
- [ ] `/restore` → enter the **payment-receipt email** → Send code.
- [ ] 6-digit code email arrives. Enter it → Verify.
- [ ] **Success** screen (NOT save_failed). Log:
      `[DVAuth] store: success (write-back verified...)`.
- [ ] Console: `await window.DreamValleyAuth.readToken()` → the family token.
- [ ] App reflects **PREMIUM**, real family (username / saved content).
- [ ] **Force-quit** (swipe up from app switcher) → **reopen**.
- [ ] Still **PREMIUM**, same family — boot-read adopted the Keychain token, no
      fresh anon mint. (`native_token_adopted result:ok`.)

**Wrong-email / wrong-code UX (can also run on prod build):**
- [ ] `/restore` with an UNKNOWN email + any code → "No subscription found for
      this email…" (the `no_subscription` path).
- [ ] `/restore` with the REAL email + a WRONG code → "That code didn't match…"
      (the `invalid_or_expired` path — NOT "no subscription").

---

## 4. Scenario 3 — returning native user (boot-read adopts real family)

Continues from §3 (Keychain has a real token). Tests the
localStorage-wiped-but-Keychain-intact case (ITP / storage pressure).

- [ ] In the inspector console: `localStorage.clear()` (clears WEB storage only;
      Keychain is native, untouched).
- [ ] Force-quit + reopen (or reload).
- [ ] Boot-read: `readToken()` returns the Keychain token → `/users/me` **200** →
      adopts → logs into the **REAL family** (username, family_id, saved content)
      — NOT a fresh anon account.
- [ ] After the guarded reload: `localStorage.getItem('dreamweaver_token')` ===
      the Keychain token. (`native_token_adopted result:ok`.)

---

## 5. Scenario 4 — cancelled subscriber (THE invariant test)

Test env. Setup: take a restored premium family (§3), then **cancel its sub** on
the Stripe test dashboard and let it go to free (downgrade past period end). The
**token stays valid** (not revoked).

- [ ] Cold-start (force-quit + reopen).
- [ ] Boot-read: `readToken()` → token → `/users/me` → **200** (valid token =
      identity intact) → adopt + setUser → **LOGGED IN**.
- [ ] User is **logged in** as their family (username/saved content) — NOT
      bounced to login, NOT a fresh anon mint.
- [ ] User sees **FREE** (paywall CTA, premium content locked) — backend
      entitlement reports free **separately**.
- [ ] **NOT ghost-premium** — premium content is locked.
- [ ] Negative check: `await window.DreamValleyAuth.readToken()` STILL returns
      the token — a 200-but-free must **NOT** clear the Keychain (only a 401 does).

This is the invariant: **token = identity, backend = entitlement, presence ≠
premium.** If the user is logged in AND free here, the invariant holds end to end.

---

## 6. storeToken(false) → save_failed (needs a debug-instrumented build)

Real Keychain rarely fails, so force it: in a debug build make
`DreamValleyAuthStorage.store()` return `false` once (a debug flag), then:

- [ ] Restore (or sign in). storeToken returns false →
      [DVAuth] `write-back MISMATCH` log.
- [ ] UI shows **save_failed** ("couldn't save on this device") — NOT success,
      NOT "you're all set".
- [ ] Tap **Retry** (with the forced-failure flag now off) → re-attempts the
      Keychain WRITE (not a re-verify; the code is already consumed) → succeeds →
      success screen.

---

## 7. Legacy 1.0 — no regression (D2 version gate)

A 1.0 build on a device (prod or test).

- [ ] UA = `DreamValleyApp/1.0`.
- [ ] Boot is immediate — **no ~3s hang** (version gate: major < 2 →
      `tryAdoptNativeToken` returns at once, no bridge-wait).
- [ ] With native paywall ON (test env): the 1.0 user is **un-paywalled /
      premium-treated** (D2: < 2.0 = legacy). No paywall, full content.

---

## 7b. Android parity pass

Repeat §1–§6 on a physical Android device:
- Storage = EncryptedSharedPreferences (Keystore-rooted). Uninstall also wipes.
- External open = `ACTION_VIEW`. Logs via `adb logcat | grep -E "DVAuth|DVSystem"`.
- Web inspect via `chrome://inspect`.

---

## 8. COMPLIANCE — SETTLED: text-only v1 (supersedes D1)

Resolved 2026-06-04: **v1 native is TEXT-ONLY** — "Subscribe at dreamvalley.app",
no tappable checkout link/button. Rationale: IAP is the immediate next version
(~v2.1), so the linked-reader-app path (D1) would be a throwaway middle step
(build it, clear review, rip it out for IAP). Skip the disposable step.

This is the cleanest reader-app posture and the lowest rejection risk:
- No external-payment link → no guideline 3.1.3(a) external-link justification.
- No External Link Account Entitlement (RAA) application.
- No StoreKit / IAP products (those come in v2.1).
- Restore link is allowed in reader apps.

The openExternal bridge + Stripe-return re-fetch stay BUILT and intact but
DORMANT on native v1 (verified in §2: no native branch triggers them) — kept for
IAP-next and web. text-only is the fast-safe v1, NOT the permanent monetization
model.

---

## 9. Assembly — cut the 2.0 build

- [ ] `pubspec.yaml` is `version: 2.0.0+5`. UA is `DreamValleyApp/2.0` (both OS).
- [ ] iOS: `flutter build ipa --release` → upload via Xcode/Transporter to App
      Store Connect → TestFlight. Signing valid.
- [ ] Android: `flutter build appbundle --release` signed with the release
      keystore (`key.properties`).
- [ ] Smoke launch each: app loads `dreamvalley.app`, bridges register (auth +
      system + media — check logs), no crash.
- [ ] Run §1–§7b on the cut build (or the test-env variant for the
      entitlement-visible scenarios).

---

## 10. Declarations (text-only reader app — no IAP, no RAA)

- [ ] **App Privacy:** declare data collection accurately (email for restore,
      analytics) — correct the prior "no data collection" if it was declared.
- [ ] **No IAP:** no StoreKit / in-app purchase products declared (IAP is v2.1).
- [ ] **No External Link Account Entitlement (RAA)** for v1.
- [ ] **Text-only CTA:** verify on the build that native renders ONLY "Subscribe
      at dreamvalley.app" text + a Restore link — NO checkout button, NO tappable
      external-payment link, NO StoreKit buy button (gated by `isNativeApp()`).
- [ ] **Review notes:** state it's a reader app (audio stories); subscriptions
      are managed on the web; restore brings an existing subscription into the app.
- [ ] Bundle ID `com.vervetogether.dreamvalley`; name "Dream Valley Stories";
      screenshots at the sizes in MEMORY (iPhone 6.7" = 1284×2778, etc.).

---

## 11. Submit → approve → (separately) flip the flag

- [ ] Submit for review.
- [ ] On approval: let adoption build (auto-update window).
- [ ] **Separately and deliberately**, flip `PAYWALL_NATIVE_ENABLED=true` on prod
      (`scripts/set_paywall.sh` or the documented path) — NOT part of submission.
      Pre/post `deploy_guard` snapshot/verify. This is its own decision.

Until that flip: native stays dormant (all users premium-treated), prod paywall
stays DARK. Submission and approval do NOT change live behavior.
