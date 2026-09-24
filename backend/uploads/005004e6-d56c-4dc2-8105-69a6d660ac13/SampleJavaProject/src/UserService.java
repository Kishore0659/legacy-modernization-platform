package service;

import java.util.List;
import java.util.ArrayList;

public class UserService extends BaseService implements AuthService {

    private String username;

    private List<String> users = new ArrayList<>();

    public UserService(String username) {
        this.username = username;
    }

    public void login(String user) {
        authenticate(user);
        saveUser(user);
    }

    public void logout() {
        clearSession();
    }

    private void authenticate(String user) {
        System.out.println("Authenticating " + user);
    }

    private void saveUser(String user) {
        users.add(user);
    }

    private void clearSession() {
        users.clear();
    }
}