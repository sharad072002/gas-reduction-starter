# Gas Reduction Challenge

> Web3Proof Challenge — Prove you can optimize for production

## 🎯 Objective

Optimize this NFT marketplace contract to reduce gas costs by **at least 30%**.

## 📊 Gas Targets

| Function | Current | Target | Save |
|----------|---------|--------|------|
| `mint()` | ~65,000 | <45,000 | 30% |
| `transfer()` | ~50,000 | <35,000 | 30% |
| `batchMint(10)` | ~120,000 | <80,000 | 33% |

## 📋 Requirements

- [ ] Meet all gas targets
- [ ] All existing tests must pass
- [ ] Maintain exact same functionality
- [ ] No breaking changes to interface

## 🛠 Setup

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Setup project
git clone https://github.com/YOUR_USERNAME/gas-reduction-starter
cd gas-reduction-starter
forge install
forge build

# Run gas benchmark
forge test --gas-report
```

## 📁 Structure

```
├── src/
│   └── NFTMarket.sol       # OPTIMIZE THIS
├── test/
│   └── Gas.t.sol           # Gas benchmarks
├── .gas-snapshot           # Target gas values
└── foundry.toml
```

## 💡 Optimization Techniques

Consider these approaches:
- **Storage packing** — Pack multiple variables into single slot
- **Calldata vs memory** — Use calldata for read-only arrays
- **Unchecked math** — Use unchecked blocks where safe
- **Short-circuit** — Order conditions by gas cost
- **Batch operations** — Combine multiple writes
- **Custom errors** — Replace require strings

## ✅ Evaluation Criteria

| Criteria | Points |
|----------|--------|
| mint() gas target | 30 |
| transfer() gas target | 30 |
| batchMint() gas target | 20 |
| All tests pass | 10 |
| Code readability | 10 |

**Pass threshold: 60/100**

## 📤 Submission

1. Fork this repository
2. Optimize the contract
3. Run `forge snapshot` to verify
4. Push to your fork
5. Submit on [Web3Proof](https://web3proof.dev)

## 📚 Resources

- [Gas Optimization Tips](https://www.rareskills.io/post/gas-optimization)
- [EVM Opcodes & Gas](https://www.evm.codes/)
- [Foundry Gas Reports](https://book.getfoundry.sh/forge/gas-reports)

---

Good luck! ⚡
# gas-reduction-starter
