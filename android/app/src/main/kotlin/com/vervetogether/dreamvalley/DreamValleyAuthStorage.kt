package com.vervetogether.dreamvalley

import android.content.Context
import android.util.Log
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

/**
 * Native auth-token storage backed by the Android Keystore.
 *
 * Mirror of iOS DreamValleyAuthStorage. Same MethodChannel contract:
 *   com.vervetogether.dreamvalley/auth  (Dart → Kotlin)
 *     "store" → { token: String } → Boolean (write-back-verified)
 *     "read"  → ()                → String? (or null on miss)
 *     "clear" → ()                → Boolean
 *
 * Storage: EncryptedSharedPreferences (androidx.security:security-crypto).
 *   - Master key in Android Keystore (hardware-backed where available),
 *     AES256_GCM key scheme.
 *   - Per-entry AES256_GCM for values + AES256_SIV for keys (deterministic
 *     key encryption is required so we can look up "session_token" by name).
 *   - Survives app updates. Uninstall wipes (by design — restore is the
 *     recovery path, NOT persistence across reinstall).
 *   - Min Android: 23 (M). Build script enforces this via Flutter minSdk.
 */
class DreamValleyAuthStorage(private val context: Context) {
    private val prefsName = "dv_auth_secure"
    private val tokenKey = "session_token"
    private val tag = "DVAuth"

    private fun prefs() = EncryptedSharedPreferences.create(
        context,
        prefsName,
        MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build(),
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
    )

    fun store(token: String): Boolean {
        if (token.isEmpty()) {
            Log.w(tag, "store: empty token rejected")
            return false
        }
        return try {
            val committed = prefs().edit().putString(tokenKey, token).commit()
            if (!committed) {
                Log.e(tag, "store: edit().commit() returned false")
                return false
            }
            // Write-back-verify: read it back and confirm match.
            val readBack = read()
            if (readBack == token) {
                Log.i(tag, "store: success (write-back verified, token_len=${token.length})")
                true
            } else {
                Log.e(tag, "store: write-back MISMATCH wrote_len=${token.length} read_len=${readBack?.length ?: -1}")
                false
            }
        } catch (e: Exception) {
            Log.e(tag, "store: exception ${e.message}", e)
            false
        }
    }

    fun read(): String? {
        return try {
            prefs().getString(tokenKey, null)
        } catch (e: Exception) {
            Log.e(tag, "read: exception ${e.message}", e)
            null
        }
    }

    fun clear(): Boolean {
        return try {
            val committed = prefs().edit().remove(tokenKey).commit()
            if (!committed) {
                Log.e(tag, "clear: edit().commit() returned false")
                false
            } else {
                Log.i(tag, "clear: success")
                true
            }
        } catch (e: Exception) {
            Log.e(tag, "clear: exception ${e.message}", e)
            false
        }
    }
}
