import java.sql.*;
import java.io.*;
import java.util.*;
import java.text.*;
import java.net.*;
import java.security.*;
import javax.crypto.*;
import javax.crypto.spec.*;
import java.util.logging.Logger;

public class LegacyBankingSystem {

    // Hardcoded credentials - security issue
    private String databaseUrl = "jdbc:mysql://localhost:3306/bankdb";
    private String databaseUser = "root";
    private String databasePassword = "admin123";

    // Hardcoded secret
    private String secretKey = "MY_SUPER_SECRET_KEY_12345";

    private Connection connection;
    private List<Customer> customers = new ArrayList<>();
    private List<Account> accounts = new ArrayList<>();
    private List<Transaction> transactions = new ArrayList<>();

    private int totalOperations = 0;
    private int failedOperations = 0;

    public LegacyBankingSystem() {
        try {
            connection = DriverManager.getConnection(
                    databaseUrl,
                    databaseUser,
                    databasePassword
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void createCustomer(String name, String email, String password) {

        if (name != null) {
            if (!name.isEmpty()) {
                if (email != null) {
                    if (email.contains("@")) {
                        if (password != null) {
                            if (password.length() > 3) {

                                Customer c = new Customer();
                                c.name = name;
                                c.email = email;
                                c.password = password;

                                customers.add(c);
                                totalOperations++;

                                System.out.println(
                                        "Customer created successfully: " + name
                                );

                            } else {
                                System.out.println("Weak password");
                                failedOperations++;
                            }
                        }
                    } else {
                        System.out.println("Invalid email");
                        failedOperations++;
                    }
                }
            }
        }
    }

    public void createAccount(String customerName, String type, double balance) {

        if (customerName == null) {
            System.out.println("Customer is null");
            return;
        }

        if (type == null) {
            System.out.println("Account type is null");
            return;
        }

        if (balance < 0) {
            System.out.println("Invalid balance");
            return;
        }

        Customer found = null;

        for (Customer c : customers) {
            if (c != null) {
                if (c.name != null) {
                    if (c.name.equals(customerName)) {
                        found = c;
                        break;
                    }
                }
            }
        }

        if (found != null) {

            Account account = new Account();
            account.customer = found;
            account.type = type;
            account.balance = balance;
            account.accountNumber =
                    "ACC" + System.currentTimeMillis();

            accounts.add(account);

            System.out.println(
                    "Account created: " + account.accountNumber
            );

        } else {
            System.out.println("Customer not found");
        }
    }

    public boolean login(String email, String password) {

        if (email == null || password == null) {
            return false;
        }

        for (Customer customer : customers) {

            if (customer.email != null) {

                if (customer.email.equals(email)) {

                    if (customer.password != null) {

                        if (customer.password.equals(password)) {

                            System.out.println("Login successful");

                            return true;

                        } else {

                            System.out.println("Wrong password");

                            failedOperations++;

                            return false;
                        }

                    }
                }
            }
        }

        return false;
    }

    public void deposit(String accountNumber, double amount) {

        if (accountNumber == null) {
            return;
        }

        if (amount <= 0) {
            System.out.println("Invalid amount");
            return;
        }

        for (Account account : accounts) {

            if (account != null) {

                if (account.accountNumber != null) {

                    if (account.accountNumber.equals(accountNumber)) {

                        account.balance =
                                account.balance + amount;

                        Transaction t = new Transaction();
                        t.accountNumber = accountNumber;
                        t.amount = amount;
                        t.type = "DEPOSIT";
                        t.date = new Date();

                        transactions.add(t);

                        totalOperations++;

                        System.out.println(
                                "Deposited " + amount
                        );

                        return;
                    }
                }
            }
        }

        System.out.println("Account not found");
    }

    public void withdraw(String accountNumber, double amount) {

        if (amount <= 0) {
            return;
        }

        for (Account account : accounts) {

            if (account.accountNumber != null) {

                if (account.accountNumber.equals(accountNumber)) {

                    if (account.balance >= amount) {

                        account.balance =
                                account.balance - amount;

                        Transaction t = new Transaction();
                        t.accountNumber = accountNumber;
                        t.amount = amount;
                        t.type = "WITHDRAW";
                        t.date = new Date();

                        transactions.add(t);

                        System.out.println(
                                "Withdraw successful"
                        );

                    } else {

                        System.out.println(
                                "Insufficient balance"
                        );

                        failedOperations++;
                    }

                    return;
                }
            }
        }
    }

    public void transfer(
            String from,
            String to,
            double amount) {

        if (from == null || to == null) {
            return;
        }

        if (amount <= 0) {
            return;
        }

        Account source = null;
        Account destination = null;

        for (Account a : accounts) {

            if (a.accountNumber != null) {

                if (a.accountNumber.equals(from)) {
                    source = a;
                }

                if (a.accountNumber.equals(to)) {
                    destination = a;
                }
            }
        }

        if (source != null) {

            if (destination != null) {

                if (source.balance >= amount) {

                    source.balance =
                            source.balance - amount;

                    destination.balance =
                            destination.balance + amount;

                    Transaction t = new Transaction();

                    t.accountNumber = from;
                    t.amount = amount;
                    t.type = "TRANSFER";
                    t.date = new Date();

                    transactions.add(t);

                    System.out.println(
                            "Transfer completed"
                    );

                } else {

                    System.out.println(
                            "Not enough balance"
                    );
                }

            } else {

                System.out.println(
                        "Destination account not found"
                );
            }

        } else {

            System.out.println(
                    "Source account not found"
            );
        }
    }

    // SQL injection vulnerability
    public void searchCustomer(String name) {

        try {

            String sql =
                    "SELECT * FROM customers WHERE name = '"
                            + name + "'";

            Statement statement =
                    connection.createStatement();

            ResultSet result =
                    statement.executeQuery(sql);

            while (result.next()) {

                System.out.println(
                        result.getString("name")
                );

                System.out.println(
                        result.getString("email")
                );
            }

        } catch (Exception e) {

            e.printStackTrace();
        }
    }

    // Another SQL injection vulnerability
    public void deleteCustomer(String email) {

        try {

            String sql =
                    "DELETE FROM customers WHERE email = '"
                            + email + "'";

            Statement statement =
                    connection.createStatement();

            statement.executeUpdate(sql);

        } catch (Exception e) {

            e.printStackTrace();
        }
    }

    public void saveCustomer(Customer customer) {

        try {

            String sql =
                    "INSERT INTO customers(name,email,password) VALUES ('"
                            + customer.name + "','"
                            + customer.email + "','"
                            + customer.password + "')";

            Statement statement =
                    connection.createStatement();

            statement.executeUpdate(sql);

        } catch (Exception e) {

            System.out.println(
                    "Database error"
            );
        }
    }

    public void generateReport() {

        System.out.println(
                "========== BANK REPORT =========="
        );

        System.out.println(
                "Customers: " + customers.size()
        );

        System.out.println(
                "Accounts: " + accounts.size()
        );

        System.out.println(
                "Transactions: " + transactions.size()
        );

        System.out.println(
                "Operations: " + totalOperations
        );

        System.out.println(
                "Failed Operations: " + failedOperations
        );

        double totalBalance = 0;

        for (Account account : accounts) {

            if (account != null) {

                totalBalance =
                        totalBalance + account.balance;

                System.out.println(
                        account.accountNumber
                        + " : "
                        + account.balance
                );
            }
        }

        System.out.println(
                "Total Balance: " + totalBalance
        );
    }

    public void printTransactions() {

        for (Transaction transaction : transactions) {

            System.out.println(
                    transaction.type
                    + " | "
                    + transaction.accountNumber
                    + " | "
                    + transaction.amount
                    + " | "
                    + transaction.date
            );
        }
    }

    public void exportCustomers(String fileName) {

        try {

            FileWriter writer =
                    new FileWriter(fileName);

            for (Customer customer : customers) {

                writer.write(
                        customer.name
                        + ","
                        + customer.email
                        + ","
                        + customer.password
                        + "\n"
                );
            }

            writer.close();

        } catch (IOException e) {

            e.printStackTrace();
        }
    }

    public void importCustomers(String fileName) {

        try {

            BufferedReader reader =
                    new BufferedReader(
                            new FileReader(fileName)
                    );

            String line;

            while ((line = reader.readLine()) != null) {

                String[] data =
                        line.split(",");

                if (data.length >= 3) {

                    Customer customer =
                            new Customer();

                    customer.name = data[0];
                    customer.email = data[1];
                    customer.password = data[2];

                    customers.add(customer);
                }
            }

            reader.close();

        } catch (Exception e) {

            e.printStackTrace();
        }
    }

    public void encryptPassword(String password) {

        try {

            Cipher cipher =
                    Cipher.getInstance("AES");

            SecretKeySpec key =
                    new SecretKeySpec(
                            secretKey.substring(0, 16)
                                    .getBytes(),
                            "AES"
                    );

            cipher.init(
                    Cipher.ENCRYPT_MODE,
                    key
            );

            byte[] encrypted =
                    cipher.doFinal(
                            password.getBytes()
                    );

            System.out.println(
                    Arrays.toString(encrypted)
            );

        } catch (Exception e) {

            e.printStackTrace();
        }
    }

    public void calculateInterest() {

        for (Account account : accounts) {

            if (account.type.equals("SAVINGS")) {

                if (account.balance > 100000) {

                    account.balance =
                            account.balance * 1.07;

                } else if (account.balance > 50000) {

                    account.balance =
                            account.balance * 1.05;

                } else if (account.balance > 10000) {

                    account.balance =
                            account.balance * 1.03;

                } else {

                    account.balance =
                            account.balance * 1.01;
                }

            } else if (account.type.equals("CURRENT")) {

                if (account.balance > 100000) {

                    account.balance =
                            account.balance * 1.01;

                } else {

                    account.balance =
                            account.balance * 1.005;
                }

            } else if (account.type.equals("FIXED")) {

                if (account.balance > 500000) {

                    account.balance =
                            account.balance * 1.09;

                } else if (account.balance > 100000) {

                    account.balance =
                            account.balance * 1.07;

                } else {

                    account.balance =
                            account.balance * 1.05;
                }
            }
        }
    }

    public void processTransaction(
            String type,
            String account,
            double amount) {

        if (type == null) {
            return;
        }

        if (type.equals("DEPOSIT")) {

            deposit(account, amount);

        } else if (type.equals("WITHDRAW")) {

            withdraw(account, amount);

        } else if (type.equals("TRANSFER")) {

            System.out.println(
                    "Transfer requires destination"
            );

        } else if (type.equals("REFUND")) {

            deposit(account, amount);

        } else if (type.equals("FEE")) {

            withdraw(account, amount);

        } else if (type.equals("INTEREST")) {

            calculateInterest();

        } else {

            System.out.println(
                    "Unknown transaction"
            );
        }
    }

    public void backupDatabase(String path) {

        try {

            Process process =
                    Runtime.getRuntime().exec(
                            "mysqldump -u root -padmin123 bankdb > "
                                    + path
                    );

            process.waitFor();

        } catch (Exception e) {

            e.printStackTrace();
        }
    }

    public void networkRequest(String url) {

        try {

            URL website =
                    new URL(url);

            HttpURLConnection connection =
                    (HttpURLConnection)
                            website.openConnection();

            connection.setRequestMethod("GET");

            BufferedReader reader =
                    new BufferedReader(
                            new InputStreamReader(
                                    connection.getInputStream()
                            )
                    );

            String line;

            while ((line = reader.readLine()) != null) {

                System.out.println(line);
            }

            reader.close();

        } catch (Exception e) {

            e.printStackTrace();
        }
    }

    public void calculateCustomerScore(Customer customer) {

        int score = 0;

        if (customer != null) {

            if (customer.name != null) {
                score += 10;
            }

            if (customer.email != null) {
                score += 10;
            }

            if (customer.password != null) {

                if (customer.password.length() > 8) {
                    score += 20;
                } else {
                    score += 5;
                }
            }

            if (customer.loginCount > 100) {

                score += 30;

            } else if (customer.loginCount > 50) {

                score += 20;

            } else if (customer.loginCount > 10) {

                score += 10;
            }

            if (customer.active) {

                if (customer.verified) {

                    score += 20;

                } else {

                    score += 5;
                }

            } else {

                score -= 10;
            }
        }

        System.out.println(
                "Customer score: " + score
        );
    }

    public void hugeLegacyMethod() {

        String a = "A";
        String b = "B";
        String c = "C";
        String d = "D";
        String e = "E";
        String f = "F";
        String g = "G";
        String h = "H";

        int x = 0;

        for (int i = 0; i < 100; i++) {

            if (i % 2 == 0) {

                x += i;

                if (i % 3 == 0) {

                    x += 3;

                    if (i % 5 == 0) {

                        x += 5;

                    } else {

                        x -= 2;
                    }

                } else {

                    x += 1;
                }

            } else {

                x -= i;

                if (i > 50) {

                    if (i % 7 == 0) {

                        x += 7;

                    } else {

                        x -= 1;
                    }
                }
            }
        }

        System.out.println(
                a + b + c + d + e + f + g + h + x
        );
    }

    public void closeConnection() {

        try {

            if (connection != null) {

                connection.close();
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }
    }

    public static void main(String[] args) {

        LegacyBankingSystem system =
                new LegacyBankingSystem();

        system.createCustomer(
                "Kishore",
                "kishore@gmail.com",
                "password123"
        );

        system.createCustomer(
                "Rahul",
                "rahul@gmail.com",
                "1234"
        );

        system.createAccount(
                "Kishore",
                "SAVINGS",
                150000
        );

        system.createAccount(
                "Kishore",
                "CURRENT",
                50000
        );

        system.login(
                "kishore@gmail.com",
                "password123"
        );

        system.deposit(
                "ACC123",
                10000
        );

        system.withdraw(
                "ACC123",
                5000
        );

        system.generateReport();

        system.printTransactions();

        system.calculateInterest();

        system.hugeLegacyMethod();

        system.closeConnection();
    }
}

class Customer {

    String name;
    String email;
    String password;

    int loginCount;
    boolean active;
    boolean verified;

    public Customer() {

        loginCount = 0;
        active = true;
        verified = false;
    }

    public void login() {

        loginCount++;

        System.out.println(
                "Customer login: " + name
        );
    }

    public void logout() {

        System.out.println(
                "Customer logout: " + name
        );
    }

    public void activate() {

        active = true;
    }

    public void deactivate() {

        active = false;
    }

    public void verify() {

        verified = true;
    }

    public void printDetails() {

        System.out.println(name);
        System.out.println(email);
        System.out.println(password);
        System.out.println(loginCount);
        System.out.println(active);
        System.out.println(verified);
    }
}

class Account {

    String accountNumber;
    String type;

    double balance;

    Customer customer;

    public void printAccount() {

        System.out.println(
                accountNumber
        );

        System.out.println(
                type
        );

        System.out.println(
                balance
        );

        if (customer != null) {

            System.out.println(
                    customer.name
            );
        }
    }

    public boolean isActive() {

        if (balance >= 0) {

            return true;

        } else {

            return false;
        }
    }
}

class Transaction {

    String accountNumber;
    String type;

    double amount;

    Date date;

    public void printTransaction() {

        System.out.println(
                accountNumber
        );

        System.out.println(
                type
        );

        System.out.println(
                amount
        );

        System.out.println(
                date
        );
    }
}

class OldNotificationService {

    public void sendEmail(
            String email,
            String message) {

        System.out.println(
                "Sending email to "
                        + email
        );

        System.out.println(message);
    }

    public void sendSMS(
            String phone,
            String message) {

        System.out.println(
                "Sending SMS to "
                        + phone
        );

        System.out.println(message);
    }

    public void sendNotification(
            String email,
            String phone,
            String message) {

        if (email != null) {

            sendEmail(
                    email,
                    message
            );
        }

        if (phone != null) {

            sendSMS(
                    phone,
                    message
            );
        }
    }
}

class LegacyLogger {

    public void log(String message) {

        System.out.println(
                new Date()
                        + " : "
                        + message
        );
    }

    public void error(String message) {

        System.err.println(
                new Date()
                        + " ERROR : "
                        + message
        );
    }

    public void warning(String message) {

        System.out.println(
                new Date()
                        + " WARNING : "
                        + message
        );
    }
}