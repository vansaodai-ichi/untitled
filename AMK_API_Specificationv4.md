# AMK Payment Integration API Specification
**Version:** 1.0  
**Date:** October 7, 2025  
**Bank Partner:** AMK (Angkor Mikroheranhvatho Kampuchea Co., Ltd)

## Table of Contents
1. [Overview](#overview)
2. [High-Level API Flow](#high-level-api-flow)
3. [Authentication](#authentication)
4. [Bill Payment Integration](#bill-payment-integration)
5. [KHQR Payment Integration](#khqr-payment-integration)
6. [Error Handling](#error-handling)
7. [Data Models](#data-models)
8. [Environment Configuration](#environment-configuration)

## Overview

The AMK Payment Integration API provides two main payment methods for Dai-Ichi Life Cambodia customers:
1. **Bill Payment** - Traditional payment processing for insurance premiums
2. **KHQR Payment** - QR code-based payment system for mobile payments

### System Architecture
- **Gateway Service**: Handles payment processing and verification
- **KHQR Service**: Manages QR code generation and payment confirmation
- **Integration Service**: Manages policy and premium inquiries

### Base URLs
- **Gateway Service**: `http://localhost:8080/AMK`
- **KHQR Service**: `http://localhost:8081/khqr`
- **AMK Partner API**: `http://10.116.17.153:8687`

## High-Level API Flow

### 🏗️ Service Architecture Overview

The AMK payment integration consists of two main microservices working together:

```
                    ┌─────────────────────────────────────┐
                    │         Mobile/Web Client           │
                    └─────────────┬───────────────────────┘
                                  │
        ┌─────────────────────────┼─────────────────────────┐
        │                         │                         │
        ▼                         ▼                         │
┌──────────────┐         ┌──────────────┐                  │
│GATEWAY-SERVICE│         │KHQR-SERVICE │                  │
│Port: 8080    │◄────────┤Port: 8081    │                  │
│              │         │              │                  │
│/AMK/payments │         │/khqr         │                  │
│/AMK/khqr     │         │              │                  │
└──────┬───────┘         └──────┬───────┘                  │
       │                        │                          │
       ▼                        ▼                          │
┌──────────────┐         ┌──────────────┐                  │
│AMK Bank API  │         │AMK QR API    │                  │
│Payment Verify│         │QR Generator  │                  │
│:444/amkpayway│         │:8687/qr      │                  │
└──────────────┘         └──────────────┘                  │
       ▲                                                   │
       └───────────────────────────────────────────────────┘
              (Webhook Callbacks)
```

---

### 💳 Bill Payment Flow (Gateway Service Focus)

**Service Responsibility**: Gateway Service handles all bill payment operations

```
┌─── STEP 1: Payment Inquiry ───┐
│                                │
│ Customer ──► Mobile App        │
│    │            │              │
│    ▼            ▼              │
│ "Policy P123"   GET /AMK/payments?query=P123
│                 │               │
│                 ▼               │
│            Gateway Service      │
│                 │               │
│                 ▼               │
│         AmkPaymentService       │
│          .inquiry()             │
│                 │               │
│                 ▼               │
│         Integration Service     │
│         (Premium Lookup)        │
│                 │               │
│                 ▼               │
│         Response: $150.00       │
└────────────────────────────────┘

┌─── STEP 2: Customer Payment ───┐
│                                │
│ Customer pays $150 via AMK     │
│ Bank's online banking system   │
│                                │
└────────────────────────────────┘

┌─── STEP 3: Payment Confirmation ──┐
│                                   │
│ AMK Bank ──► POST /AMK/payments   │
│     │            │                │
│     ▼            ▼                │
│ Webhook     Gateway Service       │
│             AmkPaymentController  │
│                  │                │
│                  ▼                │
│             AmkPaymentService     │
│             .confirmPayment()     │
│                  │                │
│                  ▼                │
│         ┌── Validate Payment      │
│         ├── Save PaymentDetail    │
│         ├── Send Kafka Event      │
│         └── Return Success        │
└───────────────────────────────────┘
```

**Key Gateway Service Components:**
- **AmkPaymentController**: REST endpoints `/AMK/payments` 
- **AmkPaymentService**: Business logic for payment processing
- **AmkPaymentServiceImpl**: Implementation with validation and Kafka publishing

---

### 📱 KHQR Payment Flow (Two-Service Interaction)

**Service Responsibility**: KHQR Service generates QR, Gateway Service processes payments

```
┌─── STEP 1: QR Generation (KHQR Service) ───┐
│                                            │
│ Customer ──► Mobile App                    │
│    │            │                          │
│    ▼            ▼                          │
│ "QR for P123"   GET /khqr?bankCode=AMK    │
│                 &billNumber=P123           │
│                 │                          │
│                 ▼                          │
│            KHQR Service                    │
│            KhqrController                  │
│                 │                          │
│                 ▼                          │
│         AmkKhqrServiceImpl                 │
│         .generateKhqr()                    │
│                 │                          │
│                 ├── Get Bank Config        │
│                 ├── Call Gateway Service   │
│                 │   GET /AMK/payments      │
│                 │   (Premium Info)         │
│                 ├── Call AMK QR API        │
│                 │   POST /qr/generator     │
│                 └── Return QR Code         │
│                                            │
└────────────────────────────────────────────┘

┌─── STEP 2: Customer Scans & Pays ──────────┐
│                                            │
│ Customer scans QR with mobile banking      │
│ AMK processes payment in real-time         │
│                                            │
└────────────────────────────────────────────┘

┌─── STEP 3: Payment Notification (Gateway) ─┐
│                                            │
│ AMK Bank ──► POST /AMK/khqr                │
│     │            │                          │
│     ▼            ▼                          │
│ Webhook     Gateway Service                │
│             AmkPaymentController           │
│             .confirmKhqrPayment()          │
│                 │                          │
│                 ▼                          │
│         AmkPaymentServiceImpl              │
│         .confirmKhqrPayment()              │
│                 │                          │
│                 ├── Verify with AMK API    │
│                 │   (AmkVerifyPaymentService)
│                 ├── Validate Payment Data  │
│                 ├── Save PaymentDetail     │
│                 ├── Send Kafka Event       │
│                 └── Return Success         │
│                                            │
└────────────────────────────────────────────┘
```

---

### 🔧 Service-Level API Responsibilities

#### Gateway Service (Port 8080)
| Endpoint | Method | Purpose | Implementation |
|----------|--------|---------|----------------|
| `/AMK/payments` | GET | Premium inquiry | `AmkPaymentService.inquiry()` |
| `/AMK/payments` | POST | Bill payment webhook | `AmkPaymentService.confirmPayment()` |
| `/AMK/khqr` | POST | QR payment webhook | `AmkPaymentService.confirmKhqrPayment()` |

**Key Classes:**
- `AmkPaymentController`: REST API endpoints
- `AmkPaymentService`: Abstract service layer
- `AmkPaymentServiceImpl`: Business logic implementation
- `AmkVerifyPaymentServiceImpl`: Payment verification with AMK

#### KHQR Service (Port 8081)
| Endpoint | Method | Purpose | Implementation |
|----------|--------|---------|----------------|
| `/khqr` | GET | Generate QR code | `AmkKhqrServiceImpl.generateKhqr()` |

**Key Classes:**
- `KhqrController`: REST API endpoint
- `KhqrServiceFactory`: Service selection based on bank
- `AmkKhqrServiceImpl`: AMK-specific QR generation

---

### 🔄 Inter-Service Communication

#### KHQR Service → Gateway Service
```java
// KHQR Service calls Gateway Service for premium info
AmkPaymentInquiryResDto inquiry = amkPaymentService.inquiry(billNumber);

// HTTP Call: GET http://localhost:8080/AMK/payments?query=P123456789
// Response: { "id": 150001, "amount": 150.00, "payer": "John Doe" }
```

#### Gateway Service → AMK APIs
```java
// Payment verification call
POST https://mms-uat.amkcambodia.com:444/amkpayway/v1/api/payment/payment-verify
// With HMAC-SHA512 signature authentication

// QR generation call (from KHQR Service)
POST http://10.116.17.153:8687/qr/generator
// With Bearer token authentication
```

---

### 📊 Data Flow Between Services

```
Premium Inquiry Flow:
Customer → KHQR Service → Gateway Service → Integration Service → DLIS/Ingenium

QR Generation Flow:
Customer → KHQR Service → AMK QR API → Base64 QR Image

Payment Confirmation Flow:
AMK Bank → Gateway Service → Verification → Database → Kafka Events

Service Configuration:
Gateway Service ←→ PostgreSQL Database
KHQR Service ←→ Gateway Service (HTTP calls)
Both Services ←→ Kafka Topics (event publishing)
```

---

### ⚡ Performance & Scalability

**Gateway Service Optimizations:**
- Connection pooling for database (20 connections)
- Kafka producer batching for events
- Payment verification with circuit breaker
- Event logging for audit trails

**KHQR Service Optimizations:**
- Caching of bank configurations
- Async QR generation
- Base64 encoding optimization
- Error handling with fallback

**Cross-Service Resilience:**
- Timeout handling (5 seconds max)
- Retry logic for failed calls
- Circuit breaker for AMK API
- Health checks between services

### API Endpoints Summary

| Service | Method | Endpoint | Purpose | Authentication |
|---------|--------|----------|---------|----------------|
| Gateway | GET | `/AMK/payments` | Premium inquiry | Bearer Token |
| Gateway | POST | `/AMK/payments` | Bill payment confirmation | Bearer Token |
| Gateway | POST | `/AMK/khqr` | KHQR payment webhook | Bearer Token |
| KHQR | GET | `/khqr` | Generate QR code | Bearer Token |
| AMK Partner | POST | `/auth/sign-in` | Authentication | Username/Password |
| AMK Partner | POST | `/qr/generator` | QR generation | Bearer Token |
| AMK Partner | POST | `/amkpayway/v1/api/payment/payment-verify` | Payment verification | HMAC-SHA512 |

### Integration Checklist

#### Pre-Integration Setup
- [ ] Configure AMK merchant accounts
- [ ] Set up authentication credentials
- [ ] Configure HMAC signature keys
- [ ] Test network connectivity to AMK APIs
- [ ] Set up Kafka topics and consumers

#### Bill Payment Integration
- [ ] Implement payment inquiry endpoint
- [ ] Implement payment confirmation endpoint
- [ ] Set up payment verification with AMK
- [ ] Configure webhook endpoints
- [ ] Test end-to-end payment flow

#### KHQR Payment Integration
- [ ] Implement QR code generation
- [ ] Set up KHQR webhook handling
- [ ] Configure payment verification
- [ ] Test QR scanning and payment
- [ ] Validate callback processing

#### Monitoring & Alerting
- [ ] Set up API monitoring dashboards
- [ ] Configure payment failure alerts
- [ ] Monitor AMK API response times
- [ ] Track payment success rates
- [ ] Set up Kafka lag monitoring

## Authentication

### AMK Integration Authentication
```http
POST http://10.116.17.153:8687/auth/sign-in
Content-Type: application/json

{
  "username": "BanhJiQRGenerateKH",
  "password": "AmkP@ssword"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

## Bill Payment Integration

### 1. Payment Inquiry

Retrieve premium information for a policy or application number.

**Endpoint:** `GET /AMK/payments`

**Parameters:**
- `query` (string, required): Policy number or application number (max 10 characters, alphanumeric only)

**Request:**
```http
GET /AMK/payments?query=P123456789
Authorization: Bearer {jwt_token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 150001,
    "policyNumber": "P123456789",
    "payer": "John Doe",
    "amount": 150.00,
    "currency": "USD",
    "dueDate": "2025-11-15"
  }
}
```

### 2. Payment Confirmation

Confirm a bill payment transaction.

**Endpoint:** `POST /AMK/payments`

**Request:**
```json
{
  "id": 150001,
  "policyNumber": "P123456789",
  "amount": 150.00,
  "currency": "USD",
  "bankTransactionId": "AMK202510070001",
  "payer": "John Doe",
  "paidDate": "20251007120000"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "transactionId": "AMK202510070001",
    "paymentReferenceId": "150001",
    "status": "CONFIRMED",
    "message": "Payment successfully processed"
  }
}
```

## KHQR Payment Integration

### 1. QR Code Generation

Generate a KHQR (Khmer QR) code for payment.

**Endpoint:** `GET /khqr`

**Parameters:**
- `bankCode` (object, required): Bank code information
- `billNumber` (string, required): Policy or application number

**Request:**
```http
GET /khqr?bankCode={"id":"AMK","bank":"AMK"}&billNumber=P123456789
Authorization: Bearer {jwt_token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "paymentId": 150001,
    "policyId": "P123456789",
    "customerName": "John Doe",
    "amount": 150.00,
    "currency": "USD",
    "qrCode": "iVBORw0KGgoAAAANSUhEUgAAA..."
  }
}
```

### 2. KHQR Payment Confirmation

Confirm a KHQR payment transaction (webhook from AMK).

**Endpoint:** `POST /AMK/khqr`

**Request:**
```json
{
  "invoice_number": "150001",
  "status": "SUCCESS",
  "merchant_number": "900000000290002",
  "paid_amount": 150.00,
  "currency": "USD",
  "paid_datetime": "2025-10-07 12:00:00.123456"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "transactionId": "AMK_KHQR_150001",
    "status": "CONFIRMED",
    "message": "KHQR payment successfully processed"
  }
}
```

### 3. Payment Verification

Verify payment status with AMK partner system.

**Internal Process:**
- Merchant ID: `900000000290002`
- Store ID: `800000000270001`
- Terminal ID: `70000002`
- Uses HMAC-SHA512 signature verification

**Verification Request to AMK:**
```http
POST https://mms-uat.amkcambodia.com:444/amkpayway/v1/api/payment/payment-verify
Content-Type: application/x-www-form-urlencoded

merchantId=900000000290002&storeId=800000000270001&terminalId=70000002&txId=150001&timestamp=1696665600000&hash={hmac_signature}
```

## Error Handling

### Standard Error Response
```json
{
  "success": false,
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Policy not found",
    "details": "Query: P123456789"
  }
}
```

### Common Error Codes
- `RESOURCE_NOT_FOUND`: Policy or payment not found
- `BAD_REQUEST`: Invalid request parameters
- `PAYMENT_VERIFICATION_DATA_MISMATCHED`: Payment verification failed
- `BANK_NOT_FOUND`: Bank configuration not found
- `MERCHANT_NOT_BIND`: Merchant account not configured
- `TRANSACTION_VERIFY_FAILED`: Payment verification with AMK failed
- `AMK_UNKNOWN_ERROR`: Unknown error from AMK system
- `SERVER_UNAVAILABLE`: AMK service unavailable

## Data Models

### AmkPaymentInquiryResDto
```json
{
  "id": "Long",
  "policyNumber": "String",
  "payer": "String", 
  "amount": "BigDecimal",
  "currency": "CurrencyVo (USD/KHR)",
  "dueDate": "LocalDate (YYYY-MM-dd)"
}
```

### AmkPaymentConfirmationReqDto
```json
{
  "id": "Long (required)",
  "policyNumber": "String (9-10 chars, required)",
  "amount": "BigDecimal (positive, required)",
  "currency": "CurrencyVo (required)",
  "bankTransactionId": "String (required)",
  "payer": "String (required)",
  "paidDate": "Date (yyyyMMddHHmmss, GMT+7, required)"
}
```

### AmkKhqrConfirmationReqDto
```json
{
  "invoice_number": "String",
  "status": "String",
  "merchant_number": "String",
  "paid_amount": "BigDecimal",
  "currency": "CurrencyVo",
  "paid_datetime": "Date (yyyy-MM-dd HH:mm:ss.SSSSSS, Asia/Bangkok)"
}
```

### GenerateKhqrReqDto
```json
{
  "bankCode": {
    "id": "String (required)",
    "bank": "String (required)"
  },
  "billNumber": "String (required)"
}
```

### GenerateKhqrResDto
```json
{
  "paymentId": "Long",
  "policyId": "String",
  "customerName": "String",
  "amount": "BigDecimal",
  "currency": "CurrencyVo",
  "qrCode": "String (Base64 encoded image)"
}
```

## Environment Configuration

### Gateway Service Configuration
```yaml
integration:
  amk-integration:
    base_url: http://10.116.17.153:8687
    verify-payment-url: https://mms-uat.amkcambodia.com:444/amkpayway/v1/api/payment/payment-verify
    merchant-id: 900000000290002
    store-id: 800000000270001
    terminal-id: 70000002
    secret-key: b9QhLjN/I/TI4UmTEQqidPJQI9ryO0gLSMalOMQ9wg5Yi7eLbp4bQ47xqC+Cu0FBkQcpLVvrDresPzFLWkkgtQ==
    auth:
      endpoint: /auth/sign-in
      username: BanhJiQRGenerateKH
      password: AmkP@ssword
```

### KHQR Service Configuration
```yaml
integration:
  gateway:
    base_url: http://localhost:8080
    access-token: {jwt_token}
    amk:
      inquiry: /AMK/payments
  amk-integration:
    base_url: http://10.116.17.153:8687
    currency: USD
    auth:
      endpoint: /auth/sign-in
      username: BanhJiQRGenerateKH
      password: AmkP@ssword
```

### Kafka Topics
```yaml
kafka-event-topic:
  gateway:
    payment:
      confirmed: dev.gateway.payment.confirmed
      verified: dev.gateway.payment.verified
      success: dev.gateway.payment.success
  khqr:
    generated-event: dev.khqr.generated-event
```

## Security Considerations

1. **Authentication**: All API calls require Bearer token authentication
2. **Request Validation**: Input validation using Jakarta Bean Validation
3. **HMAC Signature**: KHQR payment verification uses HMAC-SHA512 signatures
4. **TLS/SSL**: All external communications use HTTPS
5. **Data Encryption**: Sensitive configuration data is encrypted

## Integration Flow

### Bill Payment Flow
1. Customer initiates payment inquiry → `GET /AMK/payments`
2. System retrieves premium information from Integration Service
3. Customer completes payment through AMK system
4. AMK sends payment confirmation → `POST /AMK/payments`
5. System verifies payment and updates records
6. Kafka event published for downstream processing

### KHQR Payment Flow
1. Customer requests QR code → `GET /khqr`
2. System generates QR code via AMK integration
3. Customer scans QR and pays through mobile app
4. AMK sends webhook confirmation → `POST /AMK/khqr`
5. System verifies payment with AMK partner API
6. Payment confirmed and Kafka event published

This specification provides comprehensive coverage of the AMK integration for both bill payment and KHQR payment methods, including all necessary technical details for implementation and testing.