# Rights

A blockchain-powered platform for music rights management that gives artists, producers, and collaborators full transparency, control, and revenue from their work — all on-chain.

---

## Overview

**Rights** consists of ten main smart contracts that work together to create a decentralized, automated, and transparent system for managing music ownership, licensing, and royalties:

1. **Track Registry Contract** – Registers music tracks and contributors.
2. **Ownership Token Contract** – Issues and tracks fractional ownership tokens.
3. **Royalty Splitter Contract** – Automates revenue distribution by share.
4. **Usage Oracle Adapter Contract** – Connects streaming/play data to the platform.
5. **License Manager Contract** – Facilitates on-chain music licensing and payments.
6. **Payment Router Contract** – Routes and logs all incoming royalty and license payments.
7. **Dispute Resolution Contract** – Resolves ownership and revenue conflicts.
8. **Royalty Claim Contract** – Allows verified rights holders to claim their share.
9. **Account Verification Contract** – Verifies artist identity and prevents fraud.
10. **Upgrade Manager Contract** – Manages versioning and upgradability of key modules.

---

## Features

- **Immutable music registration** for full transparency  
- **Fractional ownership tokens** for track contributors  
- **Automated royalty payouts** based on usage and ownership  
- **Decentralized licensing** for sync, performance, and commercial use  
- **On-chain payment logs** for transparent revenue history  
- **Dispute resolution** with verifiable evidence  
- **Royalty claim system** for quick access to earnings  
- **Secure identity verification** for real artists and rights holders  
- **Plug-and-play oracle support** for streaming and usage data  
- **Upgradeable architecture** for long-term sustainability  

---

## Smart Contracts

### Track Registry Contract
- Registers a new track with metadata
- Stores contributors and initial ownership percentages
- Immutable track ID reference for all interactions

### Ownership Token Contract
- Issues NFTs or tokens representing share of ownership
- Enables transfer, resale, or delegation of rights
- Tied to verified identities

### Royalty Splitter Contract
- Distributes income based on token-based ownership
- Supports multiple payout currencies
- Transparent payment logs

### Usage Oracle Adapter Contract
- Receives play/stream/download data
- Validates and normalizes usage events
- Interfaces with external data providers

### License Manager Contract
- Allows users to purchase licenses for tracks
- Handles usage type (sync, mechanical, performance)
- Sends funds to Royalty Splitter

### Payment Router Contract
- Central hub for processing incoming payments
- Logs, routes, and emits event data
- Supports both on-chain and off-chain sources

### Dispute Resolution Contract
- Facilitates claim disputes
- Proposes new splits or ownership states
- On-chain voting or arbitration hooks

### Royalty Claim Contract
- Allows verified holders to claim accumulated royalties
- Supports claim windows and batch claiming
- Emission of on-chain proof of payout

### Account Verification Contract
- KYC or industry registry verification of artists
- Ties wallets to real-world identities
- Helps prevent royalty fraud or misattribution

### Upgrade Manager Contract
- Proxy controller for contract upgrades
- Version tracking for all modules
- Ensures backward compatibility

---

## Installation

1. Install [Clarinet CLI](https://docs.hiro.so/clarinet/getting-started)
2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/rights.git
   ```
3. Run tests:
    ```bash
    npm test
    ```
4. Deploy contracts:
    ```bash
    clarinet deploy
    ```

---

## Usage

Each smart contract operates independently but integrates within a single music rights lifecycle.
Refer to individual contract documentation for usage examples, call signatures, and integration points.

---

## License

MIT License