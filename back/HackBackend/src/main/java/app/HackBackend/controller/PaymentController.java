package app.HackBackend.controller;

import app.HackBackend.entity.Order;
import app.HackBackend.entity.Payment;
import app.HackBackend.repository.OrderRepository;
import app.HackBackend.repository.PaymentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;
import java.util.*;

@RestController
@RequestMapping("/api/payments")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class PaymentController {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private PaymentRepository paymentRepository;

    @Value("${razorpay.key.id:rzp_test_SEO5AnkQEjW8M8}")
    private String razorpayKeyId;

    @Value("${razorpay.key.secret:VLTLuSdC9pI9uT96QnAM7rkx}")
    private String razorpayKeySecret;

    @PostMapping("/create-order")
    public ResponseEntity<Map<String, Object>> createOrder(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();

        try {
            double amountInRupees = 350.0;
            if (request.containsKey("amount")) {
                Object amtObj = request.get("amount");
                if (amtObj instanceof Number) {
                    amountInRupees = ((Number) amtObj).doubleValue();
                } else if (amtObj instanceof String) {
                    String cleanAmt = ((String) amtObj).replaceAll("[^0-9.]", "");
                    if (!cleanAmt.isEmpty()) {
                        amountInRupees = Double.parseDouble(cleanAmt);
                    }
                }
            }

            String productTitle = (String) request.getOrDefault("productTitle", "Campus Marketplace Product");
            String buyerName = (String) request.getOrDefault("buyerName", request.getOrDefault("userName", "Hitija Mhatre"));
            String buyerEmail = (String) request.getOrDefault("buyerEmail", "student@campus.edu");
            String sellerName = (String) request.getOrDefault("sellerName", "Campus Peer Seller");

            int amountInPaise = (int) (amountInRupees * 100);
            String receipt = "receipt_rcpt_" + System.currentTimeMillis();
            String finalOrderId = "order_rzp_" + System.currentTimeMillis();

            // CALL RAZORPAY OFFICIAL ORDERS API
            try {
                RestTemplate restTemplate = new RestTemplate();
                String razorpayUrl = "https://api.razorpay.com/v1/orders";

                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);
                String auth = razorpayKeyId + ":" + razorpayKeySecret;
                byte[] encodedAuth = Base64.getEncoder().encode(auth.getBytes(StandardCharsets.UTF_8));
                String authHeader = "Basic " + new String(encodedAuth);
                headers.set("Authorization", authHeader);

                Map<String, Object> razorpayReq = new HashMap<>();
                razorpayReq.put("amount", amountInPaise);
                razorpayReq.put("currency", "INR");
                razorpayReq.put("receipt", receipt);

                HttpEntity<Map<String, Object>> entity = new HttpEntity<>(razorpayReq, headers);
                ResponseEntity<Map> rzpRes = restTemplate.postForEntity(razorpayUrl, entity, Map.class);

                if (rzpRes.getStatusCode() == HttpStatus.OK && rzpRes.getBody() != null) {
                    Map body = rzpRes.getBody();
                    finalOrderId = (String) body.get("id");
                }
            } catch (Exception rzpErr) {
                // Fallback to generated Order ID if API fails/offline
            }

            // PERSIST ORDER IN PostgreSQL 'orders' TABLE
            Order orderEntity = Order.builder()
                    .orderId(finalOrderId)
                    .productTitle(productTitle)
                    .amount(amountInRupees)
                    .currency("INR")
                    .buyerName(buyerName)
                    .buyerEmail(buyerEmail)
                    .sellerName(sellerName)
                    .status("CREATED")
                    .build();

            Order savedOrder = orderRepository.save(orderEntity);

            response.put("success", true);
            response.put("dbOrderId", savedOrder.getId());
            response.put("orderId", savedOrder.getOrderId());
            response.put("amount", amountInPaise);
            response.put("currency", "INR");
            response.put("keyId", razorpayKeyId);
            response.put("message", "Order created and saved in database table 'orders'!");

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Failed to create order: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PostMapping("/save-payment")
    public ResponseEntity<Map<String, Object>> savePayment(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();

        try {
            String paymentId = (String) request.getOrDefault("paymentId", "pay_" + System.currentTimeMillis());
            String orderId = (String) request.getOrDefault("orderId", "order_" + System.currentTimeMillis());
            String razorpaySignature = (String) request.get("razorpaySignature");
            String buyerName = (String) request.getOrDefault("buyerName", request.getOrDefault("userName", "Hitija Mhatre"));
            String buyerEmail = (String) request.getOrDefault("buyerEmail", "student@campus.edu");
            String paymentMode = (String) request.getOrDefault("paymentMode", "UPI");

            double amount = 350.0;
            if (request.containsKey("amount")) {
                Object amtObj = request.get("amount");
                if (amtObj instanceof Number) {
                    amount = ((Number) amtObj).doubleValue();
                } else if (amtObj instanceof String) {
                    String cleanAmt = ((String) amtObj).replaceAll("[^0-9.]", "");
                    if (!cleanAmt.isEmpty()) {
                        amount = Double.parseDouble(cleanAmt);
                    }
                }
            }

            // SAVE PAYMENT IN PostgreSQL 'payments' TABLE
            Payment paymentEntity = Payment.builder()
                    .paymentId(paymentId)
                    .orderId(orderId)
                    .razorpaySignature(razorpaySignature)
                    .amount(amount)
                    .currency("INR")
                    .status("SUCCESS")
                    .paymentMode(paymentMode)
                    .buyerName(buyerName)
                    .buyerEmail(buyerEmail)
                    .build();

            Payment savedPayment = paymentRepository.save(paymentEntity);

            // UPDATE MATCHING ORDER IN 'orders' TABLE IF EXISTS
            Optional<Order> orderOpt = orderRepository.findByOrderId(orderId);
            if (orderOpt.isPresent()) {
                Order order = orderOpt.get();
                order.setStatus("SUCCESS");
                order.setRazorpayPaymentId(paymentId);
                orderRepository.save(order);
            }

            response.put("success", true);
            response.put("dbPaymentId", savedPayment.getId());
            response.put("paymentId", savedPayment.getPaymentId());
            response.put("orderId", savedPayment.getOrderId());
            response.put("amount", savedPayment.getAmount());
            response.put("status", savedPayment.getStatus());
            response.put("message", "Payment recorded successfully in database table 'payments'!");

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Failed to record payment: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/all-orders")
    public ResponseEntity<List<Order>> getAllOrders() {
        return ResponseEntity.ok(orderRepository.findAll());
    }

    @GetMapping("/all-payments")
    public ResponseEntity<List<Payment>> getAllPayments() {
        return ResponseEntity.ok(paymentRepository.findAll());
    }
}
