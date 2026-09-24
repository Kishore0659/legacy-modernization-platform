public class LegacyUserService {

    private String password = "admin_secret_123";

    public void login(String username) {
        System.out.println("Authenticating user: " + username);

        if (username.equals("admin")) {
            System.out.println("Admin access granted.");
        }
    }
}