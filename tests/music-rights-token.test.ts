// tests/music-token.test.ts
import { describe, it, expect, beforeEach } from 'vitest'

type Principal = string

type Result<T> = { value: T } | { error: number }

type ContractState = {
  admin: Principal
  paused: boolean
  totalSupply: bigint
  balances: Map<Principal, bigint>
  locked: Map<Principal, bigint>
  MAX_SUPPLY: bigint
}

let state: ContractState

const initState = (): ContractState => ({
  admin: 'ST1ADMIN0000000000000000000000000000000000',
  paused: false,
  totalSupply: 0n,
  balances: new Map(),
  locked: new Map(),
  MAX_SUPPLY: 100_000_000n,
})

const isAdmin = (caller: Principal): boolean => caller === state.admin

const mint = (caller: Principal, recipient: Principal, amount: bigint): Result<boolean> => {
  if (!isAdmin(caller)) return { error: 100 }
  const newSupply = state.totalSupply + amount
  if (newSupply > state.MAX_SUPPLY) return { error: 103 }
  state.totalSupply = newSupply
  state.balances.set(recipient, (state.balances.get(recipient) || 0n) + amount)
  return { value: true }
}

const transfer = (caller: Principal, recipient: Principal, amount: bigint): Result<boolean> => {
  if (state.paused) return { error: 104 }
  const senderBal = state.balances.get(caller) || 0n
  if (senderBal < amount) return { error: 101 }
  state.balances.set(caller, senderBal - amount)
  state.balances.set(recipient, (state.balances.get(recipient) || 0n) + amount)
  return { value: true }
}

const lockTokens = (caller: Principal, amount: bigint): Result<boolean> => {
  if (state.paused) return { error: 104 }
  const balance = state.balances.get(caller) || 0n
  if (balance < amount) return { error: 101 }
  state.balances.set(caller, balance - amount)
  state.locked.set(caller, (state.locked.get(caller) || 0n) + amount)
  return { value: true }
}

const releaseTokens = (caller: Principal, amount: bigint): Result<boolean> => {
  if (state.paused) return { error: 104 }
  const lockedAmt = state.locked.get(caller) || 0n
  if (lockedAmt < amount) return { error: 102 }
  state.locked.set(caller, lockedAmt - amount)
  state.balances.set(caller, (state.balances.get(caller) || 0n) + amount)
  return { value: true }
}

const setPaused = (caller: Principal, pause: boolean): Result<boolean> => {
  if (!isAdmin(caller)) return { error: 100 }
  state.paused = pause
  return { value: pause }
}

describe('MusicToken Contract Mock Tests', () => {
  const userA = 'ST1USERAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  const userB = 'ST1USERBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'
  const admin = 'ST1ADMIN0000000000000000000000000000000000'

  beforeEach(() => {
    state = initState()
  })

  it('admin can mint tokens', () => {
    const result = mint(admin, userA, 5000n)
    expect(result).toEqual({ value: true })
    expect(state.balances.get(userA)).toBe(5000n)
  })

  it('non-admin cannot mint', () => {
    const result = mint(userA, userA, 100n)
    expect(result).toEqual({ error: 100 })
  })

  it('should not mint above max supply', () => {
    const result = mint(admin, userA, 200_000_000n)
    expect(result).toEqual({ error: 103 })
  })

  it('should transfer tokens when not paused', () => {
    mint(admin, userA, 1000n)
    const result = transfer(userA, userB, 300n)
    expect(result).toEqual({ value: true })
    expect(state.balances.get(userA)).toBe(700n)
    expect(state.balances.get(userB)).toBe(300n)
  })

  it('should not transfer if paused', () => {
    mint(admin, userA, 1000n)
    setPaused(admin, true)
    const result = transfer(userA, userB, 300n)
    expect(result).toEqual({ error: 104 })
  })

  it('should lock tokens', () => {
    mint(admin, userA, 500n)
    const result = lockTokens(userA, 200n)
    expect(result).toEqual({ value: true })
    expect(state.balances.get(userA)).toBe(300n)
    expect(state.locked.get(userA)).toBe(200n)
  })

  it('should release locked tokens', () => {
    mint(admin, userA, 600n)
    lockTokens(userA, 400n)
    const result = releaseTokens(userA, 150n)
    expect(result).toEqual({ value: true })
    expect(state.locked.get(userA)).toBe(250n)
    expect(state.balances.get(userA)).toBe(350n)
  })

  it('should fail to lock more than balance', () => {
    mint(admin, userA, 100n)
    const result = lockTokens(userA, 200n)
    expect(result).toEqual({ error: 101 })
  })

  it('should fail to release more than locked', () => {
    mint(admin, userA, 300n)
    lockTokens(userA, 100n)
    const result = releaseTokens(userA, 150n)
    expect(result).toEqual({ error: 102 })
  })

  it('admin can pause and unpause', () => {
    let result = setPaused(admin, true)
    expect(result).toEqual({ value: true })
    expect(state.paused).toBe(true)

    result = setPaused(admin, false)
    expect(result).toEqual({ value: false })
    expect(state.paused).toBe(false)
  })

  it('non-admin cannot pause', () => {
    const result = setPaused(userA, true)
    expect(result).toEqual({ error: 100 })
  })
})
