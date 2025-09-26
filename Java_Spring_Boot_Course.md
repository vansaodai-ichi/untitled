# Java Spring Boot Course: From Basic to Advanced

## Course Overview
This comprehensive course covers Java Spring Boot development from foundational concepts to advanced enterprise patterns and best practices.

---

## Module 1: Introduction to Spring Boot

### What is Spring Boot?
- **Auto-configuration**: Automatically configures Spring applications based on dependencies
- **Standalone**: Creates standalone Spring applications with embedded servers
- **Production-ready**: Includes metrics, health checks, and externalized configuration
- **No XML configuration**: Convention over configuration approach

### Key Features
- Embedded servers (Tomcat, Jetty, Undertow)
- Starter dependencies
- Auto-configuration
- Actuator for monitoring
- Spring Boot CLI

### Basic Project Structure
```
src/
├── main/
│   ├── java/
│   │   └── com/example/demo/
│   │       └── DemoApplication.java
│   └── resources/
│       ├── application.properties
│       └── static/
│       └── templates/
└── test/
    └── java/
```

---

## Module 2: Getting Started - Your First Spring Boot Application

### 2.1 Creating a Spring Boot Project

**Using Spring Initializr**
```java
// Generated main class
@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
```

**Dependencies (pom.xml)**
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### 2.2 Hello World Controller

```java
@RestController
public class HelloController {
    
    @GetMapping("/hello")
    public String hello() {
        return "Hello, Spring Boot!";
    }
    
    @GetMapping("/hello/{name}")
    public String helloName(@PathVariable String name) {
        return "Hello, " + name + "!";
    }
}
```

### 2.3 Configuration Properties

**application.properties**
```properties
server.port=8080
spring.application.name=demo-app
logging.level.com.example=DEBUG
```

**application.yml**
```yaml
server:
  port: 8080
spring:
  application:
    name: demo-app
logging:
  level:
    com.example: DEBUG
```

---

## Module 3: Core Spring Boot Concepts

### 3.1 Annotations Overview

| Annotation | Purpose |
|------------|---------|
| `@SpringBootApplication` | Main application class |
| `@RestController` | REST API controller |
| `@Service` | Service layer component |
| `@Repository` | Data access layer |
| `@Component` | General Spring component |
| `@Configuration` | Configuration class |
| `@Bean` | Bean definition |

### 3.2 Dependency Injection

```java
@Service
public class UserService {
    
    private final UserRepository userRepository;
    
    // Constructor injection (recommended)
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
}
```

### 3.3 Component Scanning

```java
@SpringBootApplication
@ComponentScan(basePackages = {"com.example.demo", "com.example.shared"})
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
```

---

## Module 4: Building REST APIs

### 4.1 Basic REST Controller

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    private final UserService userService;
    
    public UserController(UserService userService) {
        this.userService = userService;
    }
    
    @GetMapping
    public List<User> getAllUsers() {
        return userService.getAllUsers();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        User user = userService.getUserById(id);
        return user != null ? ResponseEntity.ok(user) : ResponseEntity.notFound().build();
    }
    
    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody @Valid User user) {
        User createdUser = userService.createUser(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody @Valid User user) {
        User updatedUser = userService.updateUser(id, user);
        return ResponseEntity.ok(updatedUser);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }
}
```

### 4.2 Request and Response Handling

```java
@RestController
public class ProductController {
    
    @GetMapping("/products")
    public ResponseEntity<Page<Product>> getProducts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String category) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<Product> products = productService.getProducts(category, pageable);
        return ResponseEntity.ok(products);
    }
    
    @PostMapping("/products")
    public ResponseEntity<Product> createProduct(@RequestBody @Valid CreateProductRequest request) {
        Product product = productService.createProduct(request);
        URI location = ServletUriComponentsBuilder
                .fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(product.getId())
                .toUri();
        return ResponseEntity.created(location).body(product);
    }
}
```

### 4.3 Exception Handling

```java
@ControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFound(ResourceNotFoundException ex) {
        ErrorResponse error = new ErrorResponse("RESOURCE_NOT_FOUND", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }
    
    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ErrorResponse> handleValidation(ValidationException ex) {
        ErrorResponse error = new ErrorResponse("VALIDATION_ERROR", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneral(Exception ex) {
        ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "An unexpected error occurred");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}
```

---

## Module 5: Data Access with Spring Data JPA

### 5.1 Entity Definition

```java
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true)
    @Email
    private String email;
    
    @Column(nullable = false)
    @Size(min = 2, max = 100)
    private String firstName;
    
    @Column(nullable = false)
    @Size(min = 2, max = 100)
    private String lastName;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
    
    // Constructors, getters, setters, equals, hashCode
}
```

### 5.2 Repository Interface

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    Optional<User> findByEmail(String email);
    
    List<User> findByFirstNameContainingIgnoreCase(String firstName);
    
    @Query("SELECT u FROM User u WHERE u.createdAt >= :date")
    List<User> findUsersCreatedAfter(@Param("date") LocalDateTime date);
    
    @Modifying
    @Query("UPDATE User u SET u.lastName = :lastName WHERE u.id = :id")
    int updateUserLastName(@Param("id") Long id, @Param("lastName") String lastName);
    
    Page<User> findByFirstNameContaining(String firstName, Pageable pageable);
}
```

### 5.3 Service Layer

```java
@Service
@Transactional
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }
    
    @Transactional(readOnly = true)
    public Page<User> getAllUsers(Pageable pageable) {
        return userRepository.findAll(pageable);
    }
    
    @Transactional(readOnly = true)
    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
    }
    
    public User createUser(CreateUserRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new ValidationException("Email already exists");
        }
        
        User user = new User();
        user.setEmail(request.getEmail());
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        
        return userRepository.save(user);
    }
    
    public User updateUser(Long id, UpdateUserRequest request) {
        User user = getUserById(id);
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        return userRepository.save(user);
    }
    
    public void deleteUser(Long id) {
        User user = getUserById(id);
        userRepository.delete(user);
    }
}
```

### 5.4 Database Configuration

**application.yml**
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/myapp
    username: ${DB_USERNAME:admin}
    password: ${DB_PASSWORD:password}
    driver-class-name: com.mysql.cj.jdbc.Driver
  
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect
        format_sql: true
  
  flyway:
    enabled: true
    locations: classpath:db/migration
```

---

## Module 6: Security with Spring Security

### 6.1 Basic Security Configuration

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {
    
    private final JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    private final JwtRequestFilter jwtRequestFilter;
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/products/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .exceptionHandling(ex -> ex.authenticationEntryPoint(jwtAuthenticationEntryPoint))
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS));
        
        http.addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}
```

### 6.2 JWT Implementation

```java
@Component
public class JwtTokenUtil {
    
    private String secret = "mySecret";
    private int jwtExpiration = 86400;
    
    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        return createToken(claims, userDetails.getUsername());
    }
    
    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration * 1000))
                .signWith(SignatureAlgorithm.HS512, secret)
                .compact();
    }
    
    public Boolean validateToken(String token, UserDetails userDetails) {
        final String username = getUsernameFromToken(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }
    
    public String getUsernameFromToken(String token) {
        return getClaimFromToken(token, Claims::getSubject);
    }
    
    public Date getExpirationDateFromToken(String token) {
        return getClaimFromToken(token, Claims::getExpiration);
    }
}
```

### 6.3 Authentication Controller

```java
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    private final AuthenticationManager authenticationManager;
    private final UserService userService;
    private final JwtTokenUtil jwtTokenUtil;
    
    @PostMapping("/login")
    public ResponseEntity<JwtResponse> authenticateUser(@RequestBody @Valid LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getUsername(),
                        loginRequest.getPassword())
        );
        
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        String jwt = jwtTokenUtil.generateToken(userDetails);
        
        return ResponseEntity.ok(new JwtResponse(jwt));
    }
    
    @PostMapping("/register")
    public ResponseEntity<MessageResponse> registerUser(@RequestBody @Valid SignupRequest signUpRequest) {
        if (userService.existsByUsername(signUpRequest.getUsername())) {
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Username is already taken!"));
        }
        
        if (userService.existsByEmail(signUpRequest.getEmail())) {
            return ResponseEntity.badRequest()
                    .body(new MessageResponse("Error: Email is already in use!"));
        }
        
        User user = userService.createUser(signUpRequest);
        return ResponseEntity.ok(new MessageResponse("User registered successfully!"));
    }
}
```

---

## Module 7: Testing Spring Boot Applications

### 7.1 Unit Testing

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void shouldReturnUserWhenValidId() {
        // Given
        Long userId = 1L;
        User expectedUser = new User();
        expectedUser.setId(userId);
        expectedUser.setEmail("test@example.com");
        
        when(userRepository.findById(userId)).thenReturn(Optional.of(expectedUser));
        
        // When
        User actualUser = userService.getUserById(userId);
        
        // Then
        assertThat(actualUser).isNotNull();
        assertThat(actualUser.getId()).isEqualTo(userId);
        assertThat(actualUser.getEmail()).isEqualTo("test@example.com");
    }
    
    @Test
    void shouldThrowExceptionWhenUserNotFound() {
        // Given
        Long userId = 999L;
        when(userRepository.findById(userId)).thenReturn(Optional.empty());
        
        // When & Then
        assertThatThrownBy(() -> userService.getUserById(userId))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("User not found with id: 999");
    }
}
```

### 7.2 Integration Testing

```java
@SpringBootTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Transactional
class UserRepositoryIntegrationTest {
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void shouldFindUserByEmail() {
        // Given
        User user = new User();
        user.setEmail("test@example.com");
        user.setFirstName("John");
        user.setLastName("Doe");
        entityManager.persistAndFlush(user);
        
        // When
        Optional<User> found = userRepository.findByEmail("test@example.com");
        
        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getFirstName()).isEqualTo("John");
    }
}
```

### 7.3 Web Layer Testing

```java
@WebMvcTest(UserController.class)
class UserControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    void shouldReturnUserList() throws Exception {
        // Given
        List<User> users = Arrays.asList(
                createUser(1L, "john@example.com", "John", "Doe"),
                createUser(2L, "jane@example.com", "Jane", "Smith")
        );
        
        Page<User> userPage = new PageImpl<>(users);
        when(userService.getAllUsers(any(Pageable.class))).thenReturn(userPage);
        
        // When & Then
        mockMvc.perform(get("/api/users")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", hasSize(2)))
                .andExpect(jsonPath("$.content[0].email", is("john@example.com")))
                .andExpect(jsonPath("$.content[1].email", is("jane@example.com")));
    }
    
    @Test
    void shouldCreateUserSuccessfully() throws Exception {
        // Given
        CreateUserRequest request = new CreateUserRequest();
        request.setEmail("new@example.com");
        request.setFirstName("New");
        request.setLastName("User");
        
        User createdUser = createUser(1L, "new@example.com", "New", "User");
        when(userService.createUser(any(CreateUserRequest.class))).thenReturn(createdUser);
        
        // When & Then
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(asJsonString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.email", is("new@example.com")))
                .andExpect(jsonPath("$.firstName", is("New")));
    }
}
```

---

## Module 8: Advanced Spring Boot Features

### 8.1 Profiles and Configuration

```java
@Configuration
public class DatabaseConfig {
    
    @Bean
    @Profile("dev")
    public DataSource devDataSource() {
        return new EmbeddedDatabaseBuilder()
                .setType(EmbeddedDatabaseType.H2)
                .build();
    }
    
    @Bean
    @Profile("prod")
    public DataSource prodDataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:mysql://prod-db:3306/myapp");
        config.setUsername("prod-user");
        config.setPassword("prod-password");
        config.setMaximumPoolSize(20);
        return new HikariDataSource(config);
    }
}
```

### 8.2 Custom Configuration Properties

```java
@ConfigurationProperties(prefix = "app.mail")
@Component
@Validated
public class MailProperties {
    
    @NotBlank
    private String host;
    
    @Range(min = 1, max = 65535)
    private int port;
    
    private boolean ssl = false;
    
    private List<String> defaultRecipients = new ArrayList<>();
    
    // Getters and setters
}

// Usage in service
@Service
public class MailService {
    
    private final MailProperties mailProperties;
    
    public MailService(MailProperties mailProperties) {
        this.mailProperties = mailProperties;
    }
    
    public void sendEmail(String to, String subject, String body) {
        // Implementation using mailProperties
    }
}
```

### 8.3 Events and Listeners

```java
// Custom event
public class UserCreatedEvent extends ApplicationEvent {
    private final User user;
    
    public UserCreatedEvent(Object source, User user) {
        super(source);
        this.user = user;
    }
    
    public User getUser() {
        return user;
    }
}

// Event publisher
@Service
public class UserService {
    
    private final ApplicationEventPublisher eventPublisher;
    
    public User createUser(CreateUserRequest request) {
        User user = // ... create user logic
        
        // Publish event
        eventPublisher.publishEvent(new UserCreatedEvent(this, user));
        
        return user;
    }
}

// Event listener
@Component
public class UserEventListener {
    
    @Async
    @EventListener
    public void handleUserCreated(UserCreatedEvent event) {
        User user = event.getUser();
        // Send welcome email
        // Create user profile
        // Log user creation
    }
}
```

### 8.4 Caching

```java
@Configuration
@EnableCaching
public class CacheConfig {
    
    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager cacheManager = new CaffeineCacheManager("users", "products");
        cacheManager.setCaffeine(Caffeine.newBuilder()
                .maximumSize(1000)
                .expireAfterWrite(10, TimeUnit.MINUTES));
        return cacheManager;
    }
}

@Service
public class UserService {
    
    @Cacheable(value = "users", key = "#id")
    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
    
    @CacheEvict(value = "users", key = "#user.id")
    public User updateUser(User user) {
        return userRepository.save(user);
    }
    
    @CacheEvict(value = "users", allEntries = true)
    public void clearUserCache() {
        // Method to clear all user cache
    }
}
```

---

## Module 9: Microservices with Spring Boot

### 9.1 Service Discovery with Eureka

```java
// Eureka Server
@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}

// Eureka Client
@SpringBootApplication
@EnableEurekaClient
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
```

### 9.2 API Gateway with Spring Cloud Gateway

```java
@Configuration
public class GatewayConfig {
    
    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                .route("user-service", r -> r.path("/api/users/**")
                        .uri("lb://user-service"))
                .route("product-service", r -> r.path("/api/products/**")
                        .uri("lb://product-service"))
                .route("order-service", r -> r.path("/api/orders/**")
                        .filters(f -> f.circuitBreaker(c -> c.setName("order-service-cb")))
                        .uri("lb://order-service"))
                .build();
    }
}
```

### 9.3 Circuit Breaker with Resilience4j

```java
@Service
public class OrderService {
    
    private final PaymentServiceClient paymentServiceClient;
    
    @CircuitBreaker(name = "payment-service", fallbackMethod = "fallbackPayment")
    @Retry(name = "payment-service")
    @TimeLimiter(name = "payment-service")
    public CompletableFuture<PaymentResponse> processPayment(PaymentRequest request) {
        return CompletableFuture.supplyAsync(() -> paymentServiceClient.processPayment(request));
    }
    
    public CompletableFuture<PaymentResponse> fallbackPayment(PaymentRequest request, Exception ex) {
        PaymentResponse response = new PaymentResponse();
        response.setStatus("PENDING");
        response.setMessage("Payment service temporarily unavailable. Order will be processed later.");
        return CompletableFuture.completedFuture(response);
    }
}
```

---

## Module 10: Monitoring and Production

### 10.1 Spring Boot Actuator

```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when-authorized
  metrics:
    export:
      prometheus:
        enabled: true
```

```java
@Component
public class CustomHealthIndicator implements HealthIndicator {
    
    @Override
    public Health health() {
        // Check external service health
        if (checkExternalServiceHealth()) {
            return Health.up()
                    .withDetail("external-service", "Available")
                    .build();
        }
        return Health.down()
                .withDetail("external-service", "Not Available")
                .build();
    }
    
    private boolean checkExternalServiceHealth() {
        // Implementation to check external service
        return true;
    }
}
```

### 10.2 Custom Metrics

```java
@Service
public class UserService {
    
    private final Counter userCreationCounter;
    private final Timer userRetrievalTimer;
    
    public UserService(MeterRegistry meterRegistry) {
        this.userCreationCounter = Counter.builder("users.created")
                .description("Number of users created")
                .register(meterRegistry);
        
        this.userRetrievalTimer = Timer.builder("users.retrieval")
                .description("Time taken to retrieve users")
                .register(meterRegistry);
    }
    
    public User createUser(CreateUserRequest request) {
        userCreationCounter.increment();
        // Implementation
    }
    
    public User getUserById(Long id) {
        return userRetrievalTimer.recordCallable(() -> {
            return userRepository.findById(id)
                    .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        });
    }
}
```

### 10.3 Logging Configuration

```yaml
logging:
  level:
    com.example: INFO
    org.springframework.security: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: application.log
    max-size: 10MB
    max-history: 30
```

```java
@RestController
public class UserController {
    
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);
    
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        logger.info("Retrieving user with id: {}", id);
        
        try {
            User user = userService.getUserById(id);
            logger.debug("Found user: {}", user.getEmail());
            return ResponseEntity.ok(user);
        } catch (ResourceNotFoundException ex) {
            logger.warn("User not found with id: {}", id);
            throw ex;
        } catch (Exception ex) {
            logger.error("Error retrieving user with id: {}", id, ex);
            throw ex;
        }
    }
}
```

---

## Module 11: Best Practices and Patterns

### 11.1 DTOs and Validation

```java
public class CreateUserRequest {
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;
    
    @NotBlank(message = "First name is required")
    @Size(min = 2, max = 50, message = "First name must be between 2 and 50 characters")
    private String firstName;
    
    @NotBlank(message = "Last name is required")
    @Size(min = 2, max = 50, message = "Last name must be between 2 and 50 characters")
    private String lastName;
    
    @Pattern(regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\\S+$).{8,}$",
             message = "Password must contain at least 8 characters with at least one digit, one lowercase, one uppercase, and one special character")
    private String password;
    
    // Getters and setters
}

@Component
public class UserMapper {
    
    public User toEntity(CreateUserRequest request) {
        User user = new User();
        user.setEmail(request.getEmail());
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        return user;
    }
    
    public UserResponse toResponse(User user) {
        UserResponse response = new UserResponse();
        response.setId(user.getId());
        response.setEmail(user.getEmail());
        response.setFirstName(user.getFirstName());
        response.setLastName(user.getLastName());
        response.setCreatedAt(user.getCreatedAt());
        return response;
    }
}
```

### 11.2 Builder Pattern for Complex Objects

```java
@Entity
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String customerEmail;
    private BigDecimal totalAmount;
    private OrderStatus status;
    private LocalDateTime createdAt;
    
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<OrderItem> items = new ArrayList<>();
    
    // Private constructor for builder
    private Order() {}
    
    public static OrderBuilder builder() {
        return new OrderBuilder();
    }
    
    public static class OrderBuilder {
        private Order order = new Order();
        
        public OrderBuilder customerEmail(String customerEmail) {
            order.customerEmail = customerEmail;
            return this;
        }
        
        public OrderBuilder totalAmount(BigDecimal totalAmount) {
            order.totalAmount = totalAmount;
            return this;
        }
        
        public OrderBuilder status(OrderStatus status) {
            order.status = status;
            return this;
        }
        
        public OrderBuilder addItem(OrderItem item) {
            order.items.add(item);
            item.setOrder(order);
            return this;
        }
        
        public Order build() {
            order.createdAt = LocalDateTime.now();
            return order;
        }
    }
}
```

### 11.3 Repository Pattern with Specifications

```java
public class UserSpecifications {
    
    public static Specification<User> hasFirstName(String firstName) {
        return (root, query, criteriaBuilder) -> {
            if (firstName == null || firstName.isEmpty()) {
                return criteriaBuilder.conjunction();
            }
            return criteriaBuilder.like(
                criteriaBuilder.lower(root.get("firstName")),
                "%" + firstName.toLowerCase() + "%"
            );
        };
    }
    
    public static Specification<User> hasEmail(String email) {
        return (root, query, criteriaBuilder) -> {
            if (email == null || email.isEmpty()) {
                return criteriaBuilder.conjunction();
            }
            return criteriaBuilder.equal(root.get("email"), email);
        };
    }
    
    public static Specification<User> createdAfter(LocalDateTime date) {
        return (root, query, criteriaBuilder) -> {
            if (date == null) {
                return criteriaBuilder.conjunction();
            }
            return criteriaBuilder.greaterThanOrEqualTo(root.get("createdAt"), date);
        };
    }
}

// Usage
@Service
public class UserService {
    
    public Page<User> searchUsers(UserSearchCriteria criteria, Pageable pageable) {
        Specification<User> spec = Specification.where(null);
        
        if (criteria.getFirstName() != null) {
            spec = spec.and(UserSpecifications.hasFirstName(criteria.getFirstName()));
        }
        
        if (criteria.getEmail() != null) {
            spec = spec.and(UserSpecifications.hasEmail(criteria.getEmail()));
        }
        
        if (criteria.getCreatedAfter() != null) {
            spec = spec.and(UserSpecifications.createdAfter(criteria.getCreatedAfter()));
        }
        
        return userRepository.findAll(spec, pageable);
    }
}
```

---

## Module 12: Performance Optimization

### 12.1 Database Optimization

```java
@Entity
@NamedEntityGraph(
    name = "User.withOrders",
    attributeNodes = @NamedAttributeNode("orders")
)
public class User {
    // Entity definition
    
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Order> orders = new ArrayList<>();
}

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    @EntityGraph("User.withOrders")
    @Query("SELECT u FROM User u WHERE u.id = :id")
    Optional<User> findByIdWithOrders(@Param("id") Long id);
    
    @Query("SELECT u FROM User u JOIN FETCH u.orders WHERE u.id IN :ids")
    List<User> findUsersWithOrdersByIds(@Param("ids") List<Long> ids);
}
```

### 12.2 Async Processing

```java
@Configuration
@EnableAsync
public class AsyncConfig {
    
    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("Async-");
        executor.initialize();
        return executor;
    }
}

@Service
public class EmailService {
    
    @Async("taskExecutor")
    public CompletableFuture<Void> sendWelcomeEmail(String email) {
        try {
            // Simulate email sending
            Thread.sleep(2000);
            logger.info("Welcome email sent to: {}", email);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Email sending interrupted", e);
        }
        return CompletableFuture.completedFuture(null);
    }
    
    @Async
    @EventListener
    public void handleUserCreated(UserCreatedEvent event) {
        sendWelcomeEmail(event.getUser().getEmail());
        createUserProfile(event.getUser());
        updateStatistics();
    }
}
```

### 12.3 Connection Pooling

```yaml
spring:
  datasource:
    type: com.zaxxer.hikari.HikariDataSource
    hikari:
      pool-name: SpringBootJPAHikariCP
      maximum-pool-size: 25
      minimum-idle: 5
      connection-timeout: 20000
      idle-timeout: 300000
      max-lifetime: 1200000
      auto-commit: false
      data-source-properties:
        cachePrepStmts: true
        prepStmtCacheSize: 250
        prepStmtCacheSqlLimit: 2048
        useServerPrepStmts: true
```

---

## Course Summary and Next Steps

### Key Concepts Covered
1. ✅ Spring Boot fundamentals and auto-configuration
2. ✅ Building REST APIs with proper error handling
3. ✅ Data persistence with Spring Data JPA
4. ✅ Security implementation with JWT
5. ✅ Comprehensive testing strategies
6. ✅ Advanced features (caching, events, profiles)
7. ✅ Microservices architecture patterns
8. ✅ Production monitoring and metrics
9. ✅ Best practices and design patterns
10. ✅ Performance optimization techniques

### Recommended Learning Path
1. **Beginner**: Modules 1-4 (Basics and REST APIs)
2. **Intermediate**: Modules 5-8 (Data, Security, Testing, Advanced Features)
3. **Advanced**: Modules 9-12 (Microservices, Production, Optimization)

### Additional Resources
- Official Spring Boot Documentation
- Spring Guides and Tutorials
- Baeldung Spring Tutorials
- Practice with real-world projects
- Contribute to open-source Spring projects

### Certification Preparation
- Spring Professional Certification
- VMware Spring Professional
- Oracle Java Certifications

---

## Hands-on Project Ideas

1. **E-commerce API**: Product catalog, shopping cart, order processing
2. **Social Media Platform**: User management, posts, comments, likes
3. **Banking System**: Account management, transactions, security
4. **Task Management**: Projects, tasks, teams, notifications
5. **IoT Data Processing**: Sensor data collection, real-time processing

Remember: The best way to learn Spring Boot is by building real applications and gradually increasing complexity!