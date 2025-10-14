package com.vehicle.security;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * Minimal password hashing utility with a BCrypt-compatible API.
 * If the real org.mindrot.jbcrypt.BCrypt is not present on the classpath,
 * this falls back to PBKDF2WithHmacSHA256. Stored format: pbkdf2$<saltB64>$<hashB64>
 */
public final class BCrypt {
    private static final SecureRandom RNG = new SecureRandom();
    private static final int PBKDF2_ITER = 120000;
    private static final int KEY_LEN = 256; // bits

    private BCrypt() {}

    public static String gensalt() {
        byte[] salt = new byte[16];
        RNG.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    public static String hashpw(String password, String salt) {
        // Try real BCrypt via reflection if present
        try {
            Class<?> c = Class.forName("org.mindrot.jbcrypt.BCrypt");
            return (String) c.getMethod("hashpw", String.class, String.class).invoke(null, password, salt);
        } catch (Throwable ignore) { }
        // Fallback to PBKDF2
        try {
            byte[] saltBytes = Base64.getDecoder().decode(salt);
            PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), saltBytes, PBKDF2_ITER, KEY_LEN);
            SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
            byte[] hash = skf.generateSecret(spec).getEncoded();
            return "pbkdf2$" + salt + "$" + Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new IllegalStateException(e);
        }
    }

    public static boolean checkpw(String plaintext, String hashed) {
        // If real BCrypt
        if (hashed != null && !hashed.startsWith("pbkdf2$")) {
            try {
                Class<?> c = Class.forName("org.mindrot.jbcrypt.BCrypt");
                return (Boolean) c.getMethod("checkpw", String.class, String.class).invoke(null, plaintext, hashed);
            } catch (Throwable ignore) { /* fallthrough */ }
        }
        // PBKDF2 format: pbkdf2$<salt>$<hash>
        if (hashed == null || !hashed.startsWith("pbkdf2$")) return false;
        String[] parts = hashed.split("\\$");
        if (parts.length != 3) return false;
        String salt = parts[1];
        String recomputed = hashpw(plaintext, salt);
        return constantTimeEquals(hashed, recomputed);
    }

    private static boolean constantTimeEquals(String a, String b) {
        if (a == null || b == null) return false;
        if (a.length() != b.length()) return false;
        int res = 0;
        for (int i = 0; i < a.length(); i++) {
            res |= a.charAt(i) ^ b.charAt(i);
        }
        return res == 0;
    }
}
