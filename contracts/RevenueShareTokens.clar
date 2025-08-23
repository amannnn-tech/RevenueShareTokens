;; Copyright Protection System
;; A blockchain-based system for registering and verifying copyright ownership

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-found (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-data (err u104))

;; Copyright registration structure
(define-map copyright-registry
    (buff 32) ;; content-hash as key
    {
        owner: principal,
        title: (string-ascii 100),
        registration-block: uint,
        timestamp: uint
    }
)

;; Track total registrations
(define-data-var total-registrations uint u0)

;; Function 1: Register Copyright
;; Allows users to register copyright for their creative work
(define-public (register-copyright (content-hash (buff 32)) (title (string-ascii 100)))
    (begin
        ;; Validate inputs
        (asserts! (> (len title) u0) err-invalid-data)
        (asserts! (is-none (map-get? copyright-registry content-hash)) err-already-registered)
        
        ;; Register the copyright
        (map-set copyright-registry content-hash
            {
                owner: tx-sender,
                title: title,
                registration-block: block-height,
                timestamp: (unwrap-panic (get-block-info? time block-height))
            }
        )
        
        ;; Update total registrations counter
        (var-set total-registrations (+ (var-get total-registrations) u1))
        
        ;; Print registration event
        (print {
            event: "copyright-registered",
            content-hash: content-hash,
            owner: tx-sender,
            title: title,
            block: block-height
        })
        
        (ok true)
    )
)

;; Function 2: Verify Copyright Ownership
;; Allows anyone to verify the copyright ownership of content
(define-read-only (verify-copyright (content-hash (buff 32)))
    (match (map-get? copyright-registry content-hash)
        copyright-info (ok copyright-info)
        err-not-found
    )
)

;; Additional read-only functions for contract information

;; Get total number of copyright registrations
(define-read-only (get-total-registrations)
    (ok (var-get total-registrations))
)

;; Get contract owner
(define-read-only (get-contract-owner)
    (ok contract-owner)
)