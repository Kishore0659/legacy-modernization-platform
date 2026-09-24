package com.modernize.auth;

public interface AuthService {
    boolean authenticate(String token);
    void revokeSession(String userId);
}
