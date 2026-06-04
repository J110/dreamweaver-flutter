# Dream Valley 2.0 — Native Build Device Test Plan (#35)

The 2.0 native build adds the paywall-capable pieces. **Nothing native was
executable before this** — every piece is logic-verified but unrun. This is the
real test pass. Run it methodically before submission.

All pieces ship DARK. `PAYWALL_NATIVE_ENABLED` flips only AFTER approval AND a
deliberate, separate owner decision.

---

## 0. Prerequisites & test arrangement (READ FIRST — the plan is unrunnable without this)

### 0.1 The dormancy problem
On prod, native is **dormant**: `PAYWALL_NATIVE_ENABLED=false` → the backend
forces `is_premium=true` for every `DreamValleyApp/*` UA. So on a prod-pointing
build, **every native user is premium regardless** — you cannot observe
free-vs-premium, which scenarios 1, 4, and the premium half of 2 all require.

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

## 2. Scenario 1 — new user pays (Stripe-return + webhook race)

Test env (native paywall ON). Fresh install, no prior token.
**See §8 first — confirm the native upgrade affordance is settled before this.**

- [ ] Fresh install → onboard → land as **FREE** (paywall CTA visible, premium
      content locked).
- [ ] Tap upgrade → checkout opens in **EXTERNAL Safari** (NOT the app WebView).
      Log: `[DVSystem] openExternal: opened=true`.
- [ ] Console: `localStorage.getItem('dv_checkout_pending')` → a timestamp.
- [ ] Pay in Safari with the test card.
- [ ] Return to the app (swipe / app switcher).
- [ ] On resume the app routes to `/upgrade/success`, polls, and within **~18s**
      flips to **PREMIUM** → returns to app, premium content unlocked.
      (Resume fired `__dvAppResumed`; `effective_premium` → true.)
- [ ] `dv_checkout_pending` is now cleared.

**Webhook-race sub-test:**
- [ ] Induce/observe webhook lag (Stripe dashboard → delay/resend the
      `customer.subscription.created` / `invoice.payment_succeeded`). Confirm
      `/upgrade/success` KEEPS polling (cache-busted, 9×2s) and confirms when the
      webhook lands — never shows fake premium.
- [ ] If lag > ~18s: confirm the soft **timeout** state (no false "you're free",
      no false success). Reopen / next `getCurrent` reflects premium once the
      webhook lands.

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

## 8. COMPLIANCE DECISION — settle BEFORE submission (affects §2 and the build)

There is a tension to resolve about the native upgrade affordance:
- **D1 (this session):** "reader-app, no IAP, no RAA, **external Stripe checkout,
  link to account page with upgrade**." → native links out to the account/upgrade
  page (reader-app allowance, guideline 3.1.3(a)). The openExternal + resume
  re-fetch (§2) supports exactly this.
- **native_build_requirements #3 (older, conservative):** native upgrade is
  **TEXT ONLY** — "Subscribe at dreamvalley.app", no clickable external-payment
  link.

These disagree on whether native has a tappable upgrade/account link. **Pick
one before submit:**
- (a) **Reader-app account link (D1, recommended):** native shows an upgrade
  screen with a link that opens the account/checkout page externally. Scenario 1
  native-pay (§2) is a real flow. Justify as a reader app (3.1.3) in review
  notes. If review pushes back, fall back to (b).
- (b) **Text-only (conservative):** native shows benefits + "Subscribe at
  dreamvalley.app" as text, NO tappable checkout. Then scenario 1 native-pay
  does NOT exist on native — users subscribe on web, the app reflects via
  restore (§3) / boot-read (§4). The openExternal bridge stays dormant on
  native (or is used only for a "Manage subscription" link).

Whichever is chosen must match what you DECLARE to Apple and what `isNativeApp()`
renders. This is the single most likely rejection vector — decide deliberately.

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

## 10. Declarations (per the §8 decision — reader-app / no IAP / no RAA)

- [ ] **App Privacy:** declare data collection accurately (email for restore,
      analytics) — correct the prior "no data collection" if it was declared.
- [ ] **No IAP:** no StoreKit / in-app purchase products declared.
- [ ] **No External Link Account Entitlement (RAA)** for v1.
- [ ] **Reader-app CTA** matches §8 choice — `isNativeApp()` gates it; verify on
      the build that native renders the chosen affordance (link vs text-only) and
      NO StoreKit buy button.
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
