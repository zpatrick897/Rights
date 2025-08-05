;; MusicToken.clar
;; A Clarity contract for managing music rights as fungible tokens
;; Features: mint, burn, transfer, lock, release, royalties, admin control

(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-INSUFFICIENT-BALANCE u101)
(define-constant ERR-MAX-SUPPLY u102)
(define-constant ERR-LOCKED u103)
(define-constant ERR-PAUSED u104)
(define-constant ERR-NO-ROYALTY u105)
(define-constant ZERO-ADDR 'SP000000000000000000002Q6VF78)

(define-constant TOKEN-NAME "MusicToken")
(define-constant TOKEN-SYMBOL "MUS")
(define-constant MAX-SUPPLY u100000000)

(define-data-var admin principal tx-sender)
(define-data-var paused bool false)
(define-data-var total-supply uint u0)

(define-map balances principal uint)
(define-map locked-balances principal uint)
(define-map royalty-rates principal uint)

;; --- Access Control ---
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

(define-private (not-paused)
  (asserts! (not (var-get paused)) (err ERR-PAUSED))
)

;; --- Admin Functions ---
(define-public (set-paused (pause bool))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (var-set paused pause)
    (ok pause)
  )
)

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (is-eq new-admin ZERO-ADDR)) (err ERR-NOT-AUTHORIZED))
    (var-set admin new-admin)
    (ok new-admin)
  )
)

;; --- Token Functions ---
(define-public (mint (recipient principal) (amount uint))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (let ((new-supply (+ amount (var-get total-supply))))
      (asserts! (<= new-supply MAX-SUPPLY) (err ERR-MAX-SUPPLY))
      (var-set total-supply new-supply)
      (map-set balances recipient (+ amount (default-to u0 (map-get? balances recipient))))
      (ok true)
    )
  )
)

(define-public (burn (amount uint))
  (begin
    (not-paused)
    (let ((bal (default-to u0 (map-get? balances tx-sender))))
      (asserts! (>= bal amount) (err ERR-INSUFFICIENT-BALANCE))
      (map-set balances tx-sender (- bal amount))
      (var-set total-supply (- (var-get total-supply) amount))
      (ok true)
    )
  )
)

(define-public (transfer (recipient principal) (amount uint))
  (begin
    (not-paused)
    (asserts! (not (is-eq recipient ZERO-ADDR)) (err ERR-NOT-AUTHORIZED))
    (let ((sender-bal (default-to u0 (map-get? balances tx-sender))))
      (asserts! (>= sender-bal amount) (err ERR-INSUFFICIENT-BALANCE))
      (map-set balances tx-sender (- sender-bal amount))
      (map-set balances recipient (+ amount (default-to u0 (map-get? balances recipient))))
      (ok true)
    )
  )
)

;; --- Royalty & Locking Logic ---
(define-public (set-royalty (rate uint))
  (begin
    (not-paused)
    (map-set royalty-rates tx-sender rate)
    (ok rate)
  )
)

(define-public (distribute-royalty (creator principal) (amount uint))
  (begin
    (not-paused)
    (let ((rate (default-to u0 (map-get? royalty-rates creator))))
      (asserts! (> rate u0) (err ERR-NO-ROYALTY))
      (let ((creator-share (/ (* amount rate) u100)))
        (asserts! (>= (default-to u0 (map-get? balances tx-sender)) creator-share) (err ERR-INSUFFICIENT-BALANCE))
        (map-set balances tx-sender (- (default-to u0 (map-get? balances tx-sender)) creator-share))
        (map-set balances creator (+ creator-share (default-to u0 (map-get? balances creator))))
        (ok creator-share)
      )
    )
  )
)

(define-public (lock (amount uint))
  (begin
    (not-paused)
    (let ((bal (default-to u0 (map-get? balances tx-sender))))
      (asserts! (>= bal amount) (err ERR-INSUFFICIENT-BALANCE))
      (map-set balances tx-sender (- bal amount))
      (map-set locked-balances tx-sender (+ amount (default-to u0 (map-get? locked-balances tx-sender))))
      (ok true)
    )
  )
)

(define-public (release (amount uint))
  (begin
    (not-paused)
    (let ((locked (default-to u0 (map-get? locked-balances tx-sender))))
      (asserts! (>= locked amount) (err ERR-LOCKED))
      (map-set locked-balances tx-sender (- locked amount))
      (map-set balances tx-sender (+ amount (default-to u0 (map-get? balances tx-sender))))
      (ok true)
    )
  )
)

;; --- Read-only views ---
(define-read-only (get-balance (who principal))
  (ok (default-to u0 (map-get? balances who)))
)

(define-read-only (get-locked (who principal))
  (ok (default-to u0 (map-get? locked-balances who)))
)

(define-read-only (get-royalty (who principal))
  (ok (default-to u0 (map-get? royalty-rates who)))
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-admin)
  (ok (var-get admin))
)

(define-read-only (is-paused)
  (ok (var-get paused))
)