;; Miner Registration Contract
;; This contract validates small-scale mining operations

(define-data-var last-miner-id uint u0)

;; Define miner data structure
(define-map miners
  { miner-id: uint }
  {
    name: (string-utf8 100),
    location: (string-utf8 100),
    license-number: (string-utf8 50),
    registration-date: uint,
    is-active: bool
  }
)

;; Register a new miner
(define-public (register-miner
    (name (string-utf8 100))
    (location (string-utf8 100))
    (license-number (string-utf8 50)))
  (let ((new-id (+ (var-get last-miner-id) u1)))
    (begin
      (var-set last-miner-id new-id)
      (map-set miners
        { miner-id: new-id }
        {
          name: name,
          location: location,
          license-number: license-number,
          registration-date: block-height,
          is-active: true
        }
      )
      (ok new-id)
    )
  )
)

;; Get miner details
(define-read-only (get-miner (miner-id uint))
  (map-get? miners { miner-id: miner-id })
)

;; Update miner status (active/inactive)
(define-public (update-miner-status (miner-id uint) (is-active bool))
  (let ((miner (map-get? miners { miner-id: miner-id })))
    (if (is-some miner)
      (begin
        (map-set miners
          { miner-id: miner-id }
          (merge (unwrap-panic miner) { is-active: is-active })
        )
        (ok true)
      )
      (err u1) ;; Miner not found
    )
  )
)

;; Check if miner is active
(define-read-only (is-miner-active (miner-id uint))
  (let ((miner (map-get? miners { miner-id: miner-id })))
    (if (is-some miner)
      (get is-active (unwrap-panic miner))
      false
    )
  )
)

