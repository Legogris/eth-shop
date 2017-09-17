# Simple decentralized marketplace example

Supports products that can be paid in ether and/or any ERC20 token(s).

## Flow
1. (Admin) Add vendor to store
2. (Vendor) Create Product, add to Shop
3. (Buyer) Call Product.placeOrder (or order is deployed manually by buyer/seller)
4. (Buyer) Pay order
5. (Seller) Withdraw payment

Tests illustrate usage.

## TODO
* Track order status
* Test coverage for Product and Shop
* Web UI
* Refund claims