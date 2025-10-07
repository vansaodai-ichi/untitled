# KHQR Payment Integration API Documentation

**Version:** 1.0  
**Date:** October 7, 2025  
**Service:** KHQR Payment Integration Service  
**Bank Partner:** Bank Partner Integration

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Authentication & Security](#authentication--security)
4. [API Endpoints](#api-endpoints)
5. [Data Models](#data-models)
6. [Error Handling](#error-handling)
7. [Integration Flow](#integration-flow)
8. [Configuration](#configuration)
9. [Monitoring & Logging](#monitoring--logging)

## Overview

The KHQR Payment Integration API provides a seamless interface for generating KHQR (Khmer QR) codes and processing QR-based payments for Dai-Ichi Life Cambodia insurance premiums through partner bank payment infrastructure.

### Key Features
- **QR Code Generation**: Dynamic QR code creation for insurance premium payments
- **Real-time Payment Processing**: Instant payment confirmation via webhook integration
- **Multi-currency Support**: USD and KHR currency handling
- **Security**: OAuth2 authentication and HMAC signature verification
- **Resilience**: Circuit breaker patterns and retry mechanisms
- **Audit Trail**: Comprehensive transaction logging and monitoring

### Service Information
- **Base URL**: `http://localhost:8081`
- **Service Port**: `8081`
- **Health Check**: `GET /actuator/health`
- **API Prefix**: `/khqr`

## Architecture

### Service Components

```mermaid
graph TB
    subgraph "KHQR Service Components"
        KC[KHQR Controller<br/>• Request validation<br/>• Response formatting]
        KS[KHQR Service Impl<br/>• Business logic<br/>• QR generation<br/>• Payment processing]
        PS[Payment Service<br/>• Policy inquiry<br/>• Gateway integration]
        SF[Service Factory<br/>• Bank routing<br/>• Service selection]
    end
    
    subgraph "External Dependencies"
        GW[Gateway Service<br/>:8080/gateway/payments<br/>• Policy inquiry<br/>• Payment verification]
        BANK[Bank QR API<br/>:8687/qr/generator<br/>• QR code generation<br/>• OAuth2 secured]
        DB[(PostgreSQL<br/>• QR sessions<br/>• Bank configs<br/>• Merchant accounts)]
    end
    
    KC --> SF
    SF --> KS
    KS --> PS
    PS --> GW
    KS --> BANK
    KS --> DB
```

### Technology Stack
- **Framework**: Spring Boot 3.x
- **Language**: Java 17+
- **Database**: PostgreSQL
- **Authentication**: OAuth2, JWT
- **Message Format**: JSON
- **Security**: HMAC-SHA512
- **Validation**: Jakarta Validation

## Authentication & Security

### 1. Service Authentication
The KHQR service uses JWT tokens for client authentication:

```bash
# Include JWT token in Authorization header
Authorization: Bearer {jwt_token}
```

### 2. Bank Partner Authentication
OAuth2 client credentials flow for Bank API integration:

```bash
curl -X POST "{bank_base_url}/auth/token" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "{bank_username}",
    "password": "{bank_password}"
  }'
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

### 3. Security Headers
```bash
# Required headers for all API requests
-H "Authorization: Bearer {access_token}"
-H "Content-Type: application/json"
-H "X-Request-ID: {correlation_id}"
-H "X-Timestamp: {unix_timestamp}"
```

## API Endpoints

### 1. Generate KHQR Code

Generate a QR code for insurance premium payment.

**Endpoint:** `GET /khqr`

#### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `bankCode` | object | Yes | Bank identifier object |
| `billNumber` | string | Yes | Policy or application number |

#### Bank Code Object Structure
```json
{
  "id": "BANK01",
  "bank": "BANK01"
}
```

#### Example Request
```bash
curl -X GET "http://localhost:8081/khqr?bankCode=BANK01&billNumber=P123456789" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "Content-Type: application/json"
```

#### Response

**Success Response (200)**
```json
{
  "success": true,
  "data": {
    "paymentId": 150001,
    "policyId": "P123456789",
    "customerName": "John Doe",
    "amount": 150.00,
    "currency": "USD",
    "qrCode": "iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAAA..."
  },
  "timestamp": "2025-10-07T12:00:00Z",
  "correlationId": "req-12345-67890"
}
```

**Error Response (400)**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": {
      "billNumber": "Bill number is required",
      "bankCode": "Bank code must be specified"
    }
  },
  "timestamp": "2025-10-07T12:00:00Z",
  "correlationId": "req-12345-67890"
}
```

#### Internal Process Flow

1. **Request Validation**: Validate bankCode and billNumber parameters
2. **Bank Configuration**: Retrieve bank configuration and merchant account
3. **Policy Inquiry**: Query Gateway service for payment details
4. **OAuth Authentication**: Authenticate with Bank QR API
5. **QR Generation**: Generate QR code via Bank partner API
6. **Response Processing**: Encode QR code to Base64 and return response

#### Implementation Details

```java
@GetMapping
public SuccessResponse<GenerateKhqrResDto> generateKhqr(
    @Valid GenerateKhqrReqDto generateKhqrReqDto) {
    
    return SuccessResponse.success(
        khqrServiceFactory
            .getPaymentService(BankVo.from(generateKhqrReqDto.getBankCode()))
            .generateKhqr(generateKhqrReqDto)
    );
}
```

### 2. Health Check Endpoint

Monitor service health and dependencies.

**Endpoint:** `GET /actuator/health`

#### Example Request
```bash
curl -X GET "http://localhost:8081/actuator/health" \
  -H "Content-Type: application/json"
```

#### Response
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "PostgreSQL",
        "validationQuery": "isValid()"
      }
    },
    "bankApi": {
      "status": "UP",
      "details": {
        "baseUrl": "http://10.116.17.153:8687",
        "responseTime": "120ms"
      }
    },
    "gatewayService": {
      "status": "UP", 
      "details": {
        "baseUrl": "http://localhost:8080",
        "responseTime": "45ms"
      }
    }
  }
}
```

## Data Models

### 1. Generate KHQR Request DTO

```java
public class GenerateKhqrReqDto {
    @NotNull
    private BankCodeVo bankCode;
    
    @NotBlank
    private String billNumber;
}

public enum BankCodeVo {
    BANK01(1L, "BANK01"),
    BANK02(2L, "BANK02"),
    BANK03(3L, "BANK03");
    
    private final Long id;
    private final String bank;
}
```

### 2. Generate KHQR Response DTO

```java
public class GenerateKhqrResDto {
    private Long paymentId;
    private String policyId;
    private String customerName;
    private BigDecimal amount;
    private CurrencyVo currency;
    private String qrCode; // Base64 encoded QR image
}

public enum CurrencyVo {
    USD("USD", "US Dollar"),
    KHR("KHR", "Cambodian Riel");
    
    private final String code;
    private final String name;
}
```

### 3. Bank QR Generation Request

```java
public class KhqrGenerateReqDto {
    private String merchantId;     // "900000000290002"
    private String currency;       // "USD" or "KHR"
    private BigDecimal amount;     // Payment amount
    private String billNumber;     // Policy/payment ID
    private String payer;          // Customer name
}
```

### 4. Payment Inquiry Response

```java
public class PaymentInquiryResDto extends AbstractPaymentInquiryRes {
    private Long id;
    private String policyNumber;
    private String payer;
    private BigDecimal amount;
    private CurrencyVo currency;
    private LocalDate dueDate;
}
```

### 5. OAuth2 Token Response

```java
public class OAuth2TokenResDto {
    private String access_token;
    private String token_type;
    private Integer expires_in;
    private String scope;
}
```

## Error Handling

### Error Response Structure

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": "Additional error context or field validation errors",
    "correlationId": "req-12345-67890",
    "timestamp": "2025-10-07T12:00:00Z",
    "retryAfter": 30
  }
}
```

### Error Codes

| Code | HTTP Status | Description | Recovery Action |
|------|-------------|-------------|-----------------|
| `VALIDATION_ERROR` | 400 | Invalid request parameters | Fix request parameters |
| `BANK_NOT_FOUND` | 404 | Bank configuration not found | Check bank code |
| `MERCHANT_NOT_BIND` | 400 | Merchant account not configured | Contact support |
| `RESOURCE_NOT_FOUND` | 404 | Policy or payment not found | Verify bill number |
| `PARTNER_RESPONSE_INVALID` | 502 | Invalid response from Bank Partner | Retry request |
| `FAILED_TO_AUTHENTICATE_WITH_BANK_PARTNER` | 401 | Bank authentication failed | Check credentials |
| `SERVER_UNAVAILABLE` | 503 | Bank service unavailable | Retry with backoff |
| `INTERNAL_ERROR` | 500 | Internal service error | Contact support |

### Exception Handling Implementation

```java
@ExceptionHandler(CustomException.class)
public ResponseEntity<ErrorResponse> handleCustomException(CustomException e) {
    ErrorResponse error = ErrorResponse.builder()
        .code(e.getErrorCode())
        .message(e.getMessage())
        .details(e.getDetails())
        .correlationId(MDC.get("correlationId"))
        .timestamp(Instant.now())
        .build();
        
    return ResponseEntity
        .status(e.getHttpStatus())
        .body(error);
}
```

## Integration Flow

### Complete KHQR Payment Flow

```mermaid
sequenceDiagram
    participant Client as Mobile/Web App
    participant KHQR as KHQR Service
    participant Gateway as Gateway Service
    participant BANK_QR as Bank QR API
    participant BANK_PAY as Bank Payment API
    participant DB as PostgreSQL
    
    Note over Client, DB: KHQR Payment Generation & Processing Flow
    
    Client->>KHQR: 1. GET /khqr?bankCode=BANK01&billNumber=P123
    Note right of Client: JWT authenticated request
    
    KHQR->>KHQR: 2. Validate request & bank config
    KHQR->>Gateway: 3. GET /gateway/payments?query=P123
    Note right of Gateway: Policy inquiry with bill type KHQR_PAYMENT
    
    Gateway-->>KHQR: 4. Payment details response
    Note left of Gateway: {id, policyNumber, payer, amount, currency, dueDate}
    
    KHQR->>BANK_QR: 5. POST /auth/token
    Note right of BANK_QR: OAuth2 client credentials authentication
    BANK_QR-->>KHQR: 6. Access token
    
    KHQR->>BANK_QR: 7. POST /qr/generator
    Note right of BANK_QR: {merchantId, currency, amount, billNumber, payer}
    BANK_QR-->>KHQR: 8. QR code (binary image)
    
    KHQR->>DB: 9. Store QR session & metadata
    KHQR-->>Client: 10. QR code (Base64) + payment details
    
    Note over Client, DB: Customer scans QR and pays via Bank mobile app
    
    BANK_PAY->>Gateway: 11. POST /gateway/khqr (webhook)
    Note right of BANK_PAY: Payment confirmation webhook
    Gateway->>BANK_PAY: 12. Payment verification request
    BANK_PAY-->>Gateway: 13. Verification response
    Gateway->>DB: 14. Update payment status
    Gateway-->>BANK_PAY: 15. Confirmation response
```

### Policy Inquiry Integration

```mermaid
sequenceDiagram
    participant KHQR as KHQR Service
    participant Gateway as Gateway Service
    participant Integration as Integration Service
    participant DLIS as DLIS System
    participant Cache as Redis Cache
    
    KHQR->>Gateway: Policy inquiry request
    Gateway->>Cache: Check cached policy data
    
    alt Cache Hit
        Cache-->>Gateway: Cached policy details
    else Cache Miss
        Gateway->>Integration: Get policy details
        Integration->>DLIS: Query policy system
        DLIS-->>Integration: Policy response
        Integration-->>Gateway: Policy details
        Gateway->>Cache: Update cache (15min TTL)
    end
    
    Gateway-->>KHQR: Policy details for QR generation
```

## Configuration

### Application Properties

```properties
# KHQR Service Configuration
server.port=8081
spring.application.name=khqr-service

# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/qr-code
spring.datasource.username=postgres
spring.datasource.password=${DB_PASSWORD}
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect

# Bank Integration Configuration
integration.bank-integration.base_url=http://10.116.17.153:8687
integration.bank-integration.auth.endpoint=/auth/token
integration.bank-integration.auth.username=${BANK_USERNAME}
integration.bank-integration.auth.password=${BANK_PASSWORD}
integration.bank-integration.currency=USD

# Gateway Service Integration
integration.gateway.base_url=http://localhost:8080
integration.gateway.access-token=${GATEWAY_ACCESS_TOKEN}
integration.gateway.bank.inquiry=/gateway/payments

# Security Configuration
security.jwt.secret=${JWT_SECRET}
security.jwt.expiration=3600

# Monitoring Configuration
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=always
```

### Bank Configuration

```sql
-- Bank configuration table
CREATE TABLE banks (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Merchant account configuration
CREATE TABLE merchant_accounts (
    id BIGSERIAL PRIMARY KEY,
    bank_id BIGINT REFERENCES banks(id),
    account_number VARCHAR(50) NOT NULL,
    account_name VARCHAR(100) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample data
INSERT INTO banks (id, code, name) VALUES (1, 'BANK01', 'Partner Bank One');
INSERT INTO merchant_accounts (bank_id, account_number, account_name) 
VALUES (1, '900000000290002', 'Dai-Ichi Life Cambodia QR Merchant');
```

### Environment Variables

```bash
# Database
DB_PASSWORD=your_db_password

# Bank Integration
BANK_USERNAME=your_bank_username
BANK_PASSWORD=your_bank_password

# Security
JWT_SECRET=your_jwt_secret_key
GATEWAY_ACCESS_TOKEN=your_gateway_token

# Optional: Override URLs for different environments
BANK_BASE_URL=http://10.116.17.153:8687
GATEWAY_BASE_URL=http://localhost:8080
```

## Monitoring & Logging

### Metrics & Health Checks

```java
// Custom health indicators
@Component
public class BankApiHealthIndicator implements HealthIndicator {
    
    @Override
    public Health health() {
        try {
            // Test Bank API connectivity
            ResponseEntity<String> response = restTemplate.getForEntity(
                bankBaseUrl + "/health", String.class);
            
            if (response.getStatusCode().is2xxSuccessful()) {
                return Health.up()
                    .withDetail("bankApi", "Available")
                    .withDetail("responseTime", "120ms")
                    .build();
            }
        } catch (Exception e) {
            return Health.down()
                .withDetail("bankApi", "Unavailable")
                .withDetail("error", e.getMessage())
                .build();
        }
        
        return Health.down().build();
    }
}
```

### Logging Configuration

```properties
# Logging levels
logging.level.dlkh.paymenthub.khqr=DEBUG
logging.level.org.springframework.web.client=DEBUG
logging.level.org.springframework.security=INFO

# Structured logging
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level [%X{correlationId}] %logger{36} - %msg%n

# Log file configuration
logging.file.name=logs/khqr-service.log
logging.file.max-size=100MB
logging.file.max-history=30
```

### Key Log Events

```java
// QR generation request
log.info("Request generate KHQR: {}", generateKhqrReqDto);

// Bank API calls
log.info("Generate KHQR request: {}", khqrGenerateReqDto);

// Policy inquiry
log.info("Inquiry premiums: {}", uri.toUriString());
log.info("Inquiry premiums response: {}", response);

// Error scenarios
log.error("Failed to authenticate with Bank Partner: {}", error);
log.warn("QR generation failed, retrying: {}", retryAttempt);
```

### Monitoring Dashboard Metrics

- **Request Rate**: QR generation requests per minute
- **Response Time**: 95th percentile response times
- **Error Rate**: Failed requests percentage
- **Bank API Health**: Partner API availability
- **Database Connections**: Active/idle connection count
- **JWT Token Validation**: Authentication success rate

### Alerting Rules

```yaml
# Prometheus alerting rules
groups:
  - name: khqr-service
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected in KHQR service"
          
      - alert: BankApiDown
        expr: up{job="bank-api"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Bank API is down"
```

## Best Practices

### 1. Security Best Practices
- Always validate JWT tokens before processing requests
- Use HTTPS in production environments
- Implement rate limiting per client/IP
- Store sensitive configuration in environment variables
- Log security events for audit purposes

### 2. Performance Best Practices
- Implement connection pooling for database and HTTP clients
- Cache policy data to reduce Gateway service calls
- Use async processing for non-critical operations
- Implement circuit breakers for external API calls
- Monitor and tune JVM parameters

### 3. Error Handling Best Practices
- Provide meaningful error messages to clients
- Log detailed error information for debugging
- Implement retry logic with exponential backoff
- Use correlation IDs for request tracing
- Implement graceful degradation for partial failures

### 4. Development Best Practices
- Use DTOs for API request/response validation
- Implement comprehensive unit and integration tests
- Use proper HTTP status codes
- Version your APIs for backward compatibility
- Document all configuration parameters

---

**Document Version**: 1.0  
**Last Updated**: October 7, 2025  
**Contact**: Payment Hub Development Team  
**Support**: support@daiichi.com.kh