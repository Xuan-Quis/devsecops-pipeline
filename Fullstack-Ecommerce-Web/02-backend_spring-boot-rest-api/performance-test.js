import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 10 }, // Ramp up to 10 users
    { duration: '5m', target: 10 }, // Stay at 10 users
    { duration: '2m', target: 0 },  // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests must complete below 500ms
    http_req_failed: ['rate<0.1'],    // Error rate must be below 10%
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

export default function () {
  // Test API endpoints
  let responses = http.batch([
    ['GET', `${BASE_URL}/api/products`],
    ['GET', `${BASE_URL}/api/products/1`],
    ['GET', `${BASE_URL}/api/brands`],
    ['GET', `${BASE_URL}/api/types`],
  ]);

  // Check responses
  responses.forEach((response, index) => {
    check(response, {
      [`status is 200 for request ${index}`]: (r) => r.status === 200,
      [`response time < 500ms for request ${index}`]: (r) => r.timings.duration < 500,
    });
  });

  sleep(1);
} 