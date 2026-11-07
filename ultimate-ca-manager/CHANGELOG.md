# Changelog

## 2.251

- Upgrading from upstream version 2.249-5 -> 2.251

> Upstream v2.251: https://github.com/NeySlim/ultimate-ca-manager/releases/tag/v2.251
>
> ## What's Changed
>
> ### Added
> - CAs: Ed25519 and Ed448 keys can be generated for a root, intermediate or external CA, and an EdDSA CA key imported with or after its certificate (`POST /cas/import`, certificate import with its key, `POST /cas/<id>/key`) is accepted instead of a 400 (#436, reported by @Faraphel).
> - Certificates: templates and the issue form can add custom X.509 extensions, each an OID, a critical flag and its DER value in hex, and the certificate and CA details list the extensions UCM has no section for, with their raw value (#437, requested by @Faraphel).
> ### Security
> - Database: on PostgreSQL, an error carried the values bound to its statement, private keys included, into the logs despite hidden parameters: in the quoted statement, in the refused row of a NOT NULL or CHECK violation, and in the input a data error quotes. These are now removed from the message; its first line, the other DETAIL lines, HINT and SQLSTATE are kept.
> - Revocation: a key revoked as compromised was kept only for a certificate of a CA held here, so a Let's Encrypt certificate revoked as compromised then deleted let the ACME client certify the same key again. Such keys are now kept whatever CA issued the certificate, and refused at the request, the renewal and the finalization (migration 129).
> - Key recovery: a request named its certificate by number, and SQLite gives a deleted certificate's number to the next one created, so an approved request could export another certificate's private key, after a replacing restore in particular. Approval and recovery now answer 410 unless the number still names the certificate the request was opened on, and a replacing restore cancels the open requests on the certificates it removes.
> ### Fixed
> - XCEP: an ECDSA template was announced without its key algorithm, so Windows generated an RSA key of the curve's size and the enrolment failed. The template now names its curve (`ECDSA_P256`, `ECDSA_P384`, `ECDSA_P521`) as a signature key.
> - WSTEP: two templates sharing an EKU were told apart by their id alone, so a P-384 request was issued under the P-256 template and stamped with its OID. The request key must now fit the template: same curve or ML-DSA set, an RSA key at least as long.
> - WSTEP: the CMC envelope Windows signs with an ECDSA key was refused, because CertEnroll names the key type (`id-ecPublicKey`) as its signature algorithm. It is now verified with the digest the envelope declares.
> - Database: on PostgreSQL in a schema other than `public`, the integrity check reported 0 tables. It now counts the tables of the schema in use.
> - Database migration: to PostgreSQL in a schema other than `public` (a `search_path` in the URL), the sequences of the copied tables were never found, so the migration was refused at its verification. The sequences of the schema in use are now realigned, and the reset the failure message asks for names that schema.
> - Database: on PostgreSQL, the database reset waited forever for the transaction of its own request. It now closes that transaction before dropping the tables.
> - Renewals: a renewed OCSP responder certificate was signed with the policies' default digest instead of the original's, and a renewal that changed the digest said nothing. Both keep the original's while it is at least the CA key's and the policies allow it, else follow the issuance rule, and log the change (#397).
> - XCEP: an ECDSA template outside FIPS mode announced no request hash, and a P-384 or P-521 template asked for its template digest, SHA-256 by default. ECDSA templates are now schema 3 and announce the stronger of the template digest and the one matching their key; RSA templates outside FIPS mode stay schema 2, whose hash MS-XCEP requires to be nil (#397).
> - EST and mTLS: server-generated keys were always RSA-2048, so a policy refusing it (CNSA, strict FIPS profile) refused EST `serverkeygen` and user mTLS certificates. The key now takes the issuing CA's strength, in the family of the `serverkeygen` request's key when RSA or EC, else the CA's (a browser-usable type for mTLS), and moves to the closest type the policies allow (#397).
> - Issuance: EST, SCEP, WSTEP, Sign CSR, TSA signer and unconfigured ACME orders signed with SHA-256 whatever the CA key, and a P-384 CA's CRLs too. Every path now signs with the bound template's digest, raised to the one matching the CA key (SHA-384 for P-384, SHA-512 for P-521), as a preference that yields to the closest stronger digest the policies allow, or the strongest allowed (#397).
> - Docker: the images lacked pyspnego's Kerberos backend, which the DEB and RPM installs can add, so the Kerberos binding of Windows autoenrollment could not work in a container. Both images now ship it, at the pyspnego version the requirements resolve (#435, thanks @JPromi).
> - Restore: two DNS providers, ACME CA accounts or webhooks of the same name were merged into one row, and one credential was lost. A clashing row is now restored as `name (2)`, and the restore result lists it; an account is matched by its account URL and a webhook by its URL first.
> - DNS providers, ACME CA accounts and webhooks: the API accepted a name already in use. It now answers 409, on creation and on rename.
> - ACME client: a renewal imported its certificate into a new row, so the HTTPS binding, deployment bindings and webhooks stayed on the old one, which `revoke_on_renewal` then revoked. The certificate is now renewed in place, keeping its id, and `certificate.renewed` is emitted.
> - ACME client: the key of a finalization lived only in memory, so a restart or a failed import after the CA had issued lost the certificate. The key is now stored encrypted on the order before the request, and a status check, a finalization or the next renewal imports the certificate the CA already issued (migration 123).
> - ACME client: a manual and a scheduled renewal of one order could run at once and obtain two certificates. Each renewal or finalization now holds a lease on its order, which a stopped process leaves for 10 minutes: a second one gets a 409, and the scheduler skips the order.
> - ACME client: after 5 failed scheduled renewals an order was never renewed again, silently. It is now retried once a day, each failure emits the `acme_order.renewal_failed` webhook event, the order list shows the failure count and last error, and the scheduler task reports a warning.
> - ACME client: an order whose CA account had been deleted renewed under another account, possibly at another CA. The renewal and the order's other actions now stop with a message saying what to do, and deleting or deactivating an account is refused (409) while issued orders renew through it; each order's automatic renewal can now be turned off from the order list (`PATCH /api/v2/acme/client/orders/<id>`).
> - ACME client: a CSR whose key was revoked as compromised was refused only at finalization, after the CA had opened an order and checked the challenges at each renewal. It is now refused with a 409 by the request and before a renewal opens any order.
> - ACME client: a failed manual renewal answered a bare 500 and was neither counted nor audited. It now answers 409 or 422 with the reason, counts towards the order's failures and emits `acme_order.renewal_failed`.
> - ACME client: an order the CA answered 404 or 410 for was polled until the timeout, up to several minutes per scheduler pass. Polling now stops at once and the order turns invalid with the reason.
> - ACME client: a restart during the automatic validation left the order `processing` for good. Such an order now goes back to `pending` with a message, ready for Verify, within about 15 minutes of its last activity (at startup, then by a scheduler task every 15 minutes), so the orders another instance on the same database is validating are left alone.
> - ACME client and proxy: removing a DNS-01 TXT record deleted every value of its name, so cleaning up one order could erase the challenge of another order, or of the wildcard and apex sharing the name, still validating. DNS providers now remove only the value of that order; DuckDNS and Hurricane Electric, which hold one value per name, and FreeDNS, whose record list truncates TXT values, keep clearing the name and log a warning, and FreeDNS no longer removes the `_acme-challenge` record of another domain of the account.
> - DNS providers: Namecheap found no host in its API's answers, which carry an XML namespace, so publishing a TXT record replaced every record of the zone with it. The hosts and the mail setting (`EmailType`) are now read and written back, and nothing is written when the read fails.
> - ACME client: the order list loaded all its pages at once, so a rate limit answering 429 to one of them left the page empty. Pages now load four at a time, one answered 429 is retried after its `Retry-After`, and a page still missing leaves the orders obtained with a notice saying the list is partial.
> - FIPS mode: Smart Import and the converter accepted a file holding an Ed25519 or Ed448 key, which the other imports refuse, and every import let through an EdDSA X.509 certificate. They now answer the same FIPS refusal before parsing; an encrypted PKCS#8 key can only be refused once decrypted.
> - ACME client: the order list stopped at the 100 newest orders, so an older issued order disappeared from the page. The API now pages (`page`, `per_page`) and the page loads every order.
> - ACME client: the TXT records of a DNS-01 order whose automatic validation failed stayed in the zone. They are now removed once the order is invalid or its finalization failed; an order left pending keeps them for Verify.
> - ACME client: deleting a certificate after revoking it did not stop its order, and the next pass issued a new one. The order's automatic renewal is now turned off, with a message saying so.
> - ACME client: a renewal used a DNS provider that had been disabled, and an order reusing the key of a deleted certificate silently got a new key. Both now stop before the CA with a message.
> - ACME client: the help of the renewal threshold did not say that a certificate whose life is shorter than 1.5 times the threshold renews in its last third. It now does.
> - ACME client: with `revoke_on_renewal`, a revocation the CA refused or never received was only logged, and a certificate revoked here as compromised was revoked at the CA as superseded. The CA now gets the local reason when it is keyCompromise, affiliationChanged, superseded or cessationOfOperation and none otherwise, and a failed revocation is retried by the renewal task until the certificate expires, emitting `acme_order.revocation_failed`.
> - Revocation: a key revoked as compromised was forgotten once its certificate was deleted, so the ACME client could certify it again. The revocation record, written when the issuing CA is held here, now keeps the key's SHA-256 (migration 128).
> - Restore: a membership, deployment binding, CRL binding, template pin or role permission was matched by the source's row numbers first, and could overwrite another row here. Rows are now matched by what they name; an archive records the database it comes from, and its numbers count only there and only when they still name the same rows.
> - Restore: a replacing restore failed on PostgreSQL as soon as a CRL, a cached OCSP response, a session or an ACME client order pointed at a row it removed, and left such rows pointing at nothing on SQLite. Both engines now clear regenerable rows and queues, detach or drop history as deleting the row does, empty the optional links the schema does not enforce, and refuse any other link with the row named.
> - Restore: a replacing restore wrote the archive before removing what it does not carry, so a SCEP slug or a name still held by a removed row failed with a bare 500. Removals now come first, a homonym replacing the row here keeps its name unless a kept row still points at that row, in which case it is restored as `name (2)`, and a remaining database conflict names the table and the row.
> - Restore: an archive over 50 MB was refused with a 413 although it had been created without a word. The restore upload now accepts and reads up to `BACKUP_MAX_UPLOAD_MB` (512 by default), refusals name the setting, and creating an archive a restore would not read warns.
> - Restore: an archive older than 2.230 holding an API key or an ACME domain was refused whole, its nested group members went to whichever account held the source's number, and its nested WebAuthn keys were ignored. A row whose required link is a bare number, nested members included, is now left out and listed, and the WebAuthn keys come back.
> - Restore: a hybrid certificate pair came back with the source's number for its partner, which on another installation named another certificate or none. The partner, and a SCEP request's profile, are now found by name; for any link an older archive carries as a bare number, a row here keeps its own link unless the archive records none or the restore removes the target, and a new row is restored without it, with a warning in the result.
> - Restore: an HSM field an older archive holds under another installation's key was dropped with a log line that did not name the provider. The log and the restore result now name the provider and the field.
> - Backups: ACME client orders, approval requests and key recovery requests were in no archive, so a restore lost the renewal schedule and every pending request. They are now carried, an order with its pending key and its renewal link, and a recovery request follows its certificate's refid and is cancelled when that certificate is not there.
> - Restore: settings naming a row by its number (the SCEP and ACME issuing CAs, the ACME public TLS certificate and proxy account, OCSP responders, SCEP challenges, SCTs, cross-certificate URLs) kept the source's number, so SCEP or ACME could sign with another CA. The archive now names those rows, the restore renumbers the settings, and one whose row is not there is emptied or left out with a warning. A replacing restore also drops the settings of the rows it removes, which SQLite would have handed to the archived row taking their number.
> - Restore: a failed restore left on disk the certificate and plaintext key files of the authorities and certificates it had rolled back, and a replacement left those of the rows it removed. Files are now written, and those of removed rows deleted, only with the commit.
> - Restore: a client certificate was found again by its serial number, unique only per issuer, so the same certificate could come back twice and another one with that serial be overwritten. It is now found by its fingerprint, as the archive identifies it.
> - Restore: ACME accounts and EAB credentials came back dated from the restore, and webhooks without their authentication token. Both now come back as archived.
> - Restore: a value longer than its column failed on PostgreSQL with a bare 500. It is now refused with a 400 naming the table, the row and the column.
> - Backups: a manual backup could read the database while a restore was committing and archive half of each. Backups and restores now share one lock: a restore is refused (409) while a backup runs, and a manual backup waits for a restore.
> - Restore: an archive older than migrations 101 to 105 put back what they had cleaned (legacy EAB keys, dead and `ldap_*` settings, SAML providers signing requests, group permissions stored as text). Those repairs are now replayed on the rows the restore writes.
> - CAs and certificates: deleting a CA left its SCEP challenge and OCSP responder settings, and deleting a certificate its SCTs, which SQLite could hand to the next row given that number. They now go with the row.
> - Database migration: a role inheriting from a role created after it made the copy to PostgreSQL fail when the database role cannot disable foreign keys. A link to a row of the same table is now written once the whole table is in.
> - mTLS: a client certificate could not be enrolled, imported or assigned when an enrolled certificate of another CA had the same serial number, legitimate in X.509. An enrolment is now identified by its issuer and serial, at login and by a restore too (migration 130).
> - Backups: a webhook's authentication token was archived twice, in the clear and encrypted under the source's key, which no other installation can read. The archive now carries it in the clear only, and a restore ignores the encrypted copy of an older archive.
> - Restore: rows sharing an identity the database does not keep unique, such as two revocation records of one serial, were matched to the archive at random, and a replacing restore silently kept the extra ones. Archived rows now go to them by rank, oldest first, a row without a complete identity is matched to none (the dedicated restorers still match one with any part of it set), a replacement removes those the archive does not carry and lists them in the result's warnings, and client certificates, discovered certificates and SCEP requests are identified by issuer and serial, endpoint, and transaction and CA.
> - DNS providers: Constellix called v1 record paths on the v4 API and added a second record for a name already holding a TXT value. It now uses the documented v4 records endpoint, reads every page, waits for an accepted creation to be listed, and adds or removes a value inside the name's single record, keeping disabled values disabled.
> - DNS providers: Checkdomain deleted TXT records through an endpoint the API does not have, by a record id it does not return, and read only the first page of domains and records. A value is now removed by replacing the zone's records without it, as the API documents, after reading every page; only the SOA, the apex NS and the generated `www` copies are left out.
> - DNS providers: Core Networks called zone and deletion endpoints the API does not have, logged in with a form instead of JSON and ignored a failed commit, so cleanup reported success with the record still published. It now uses the documented `/dnszones` endpoints, deletes one value through `records/delete` and fails when the commit fails.
> - DNS providers: Hostinger called an API host and record endpoints that do not exist. It now uses the documented `/api/dns/v1/zones` endpoints, appending a value on creation and rewriting the name's other TXT values, disabled ones included, on deletion.
> - DNS providers: Epik sent records in a shape the API rejects, read the listing with field names it does not use and deleted through a path it does not have, so no TXT record was ever removed. It now follows the documented v2 host-records calls and sends the key in the `Authorization` header instead of the deprecated `SIGNATURE` query parameter.
> - DNS providers: Mythic Beasts reported a TXT value deleted when the API had removed nothing, as when the zone stores it in another form. It now deletes the value as the API lists it and fails when no record was removed.
> - DNS providers: RcodeZero used the deprecated v1 API with upper-case change types and plain-string records, sent `ADD` on a name already holding a TXT value, and took a refusal answered with HTTP 200 for success. It now follows the v2 API, writes the whole rrset when adding a second value, and fails on `status: failed`.
> - DNS providers: Vultr read only the first page of domains and records, so a zone or a TXT value past it was never found. It now follows the `meta.links.next` cursor through every page.
> - DNS providers: Vercel read the first page of a zone's records only and reported success when a deletion failed. It now reads every page of the documented v5 listing, fails when the API refuses the deletion, and takes an optional team ID for domains owned by a team.
> - DNS providers: Google Cloud DNS took a failed read of the TXT records for an absent record, so a cleanup reported success with the value still published, and it read only the first page of managed zones. A failed read now fails, and every page of zones is read.
> - DNS providers: Porkbun reported a TXT record deleted when the listing or the deletion failed, and sent the TTL as text where the API takes an integer. Both failures now fail the cleanup, and the API's warnings, such as a domain not delegated to Porkbun, are logged.
> - DNS providers: Hurricane Electric reported a TXT record cleared whatever the update endpoint answered, `badauth` included. A clear the endpoint does not confirm now fails.
> - DNS providers: FreeDNS reported a TXT record created or deleted without checking the outcome, and took an unreadable record list for an absent record. A record missing after creation, still listed after deletion, or a list it cannot read now fails.
> - ACME client, renewals and proxy: a DNS-01 TXT cleanup the provider refused left nothing in the logs. It is now logged as a warning with the provider's answer, as is a failed record listing.
> - Database: a gunicorn worker dropped the inherited connections of the default database engine only. It now drops those of every engine.
> - Scheduler: under gunicorn the scheduled tasks ran in the master, so a worker forked while a task held a database connection shared it with the master. They now run in a dedicated scheduler process that the master starts, restarts within seconds after a crash or a reload, and stops with it, so a long task delays neither requests nor workers.
> - Syslog: the TCP connection opened by the gunicorn master was inherited by its workers, so the frames of several processes could interleave on one stream. Each worker now opens its own connection, leaving the master's open.
> - PKCS#11: a gunicorn worker went on using the library its master had initialized, a state Cryptoki leaves undefined after fork: a module that resets itself in the child, such as SoftHSM with `library.reset_on_fork`, refused every operation. Each process now initializes the library itself, and keeps the inherited state only when the module refuses a second initialization.
> ### Upgrade notes
> - Algorithms (#397): EST `serverkeygen` and mTLS no longer give RSA-2048 under an EC, RSA-3072 or ML-DSA CA; ACME orders without a digest, EST, SCEP, WSTEP, Sign CSR, the issue form and CRLs sign with SHA-384 or SHA-512 under a P-384 or P-521 CA, and renewals raise SHA-256 originals there; CRLs already issued are unchanged, only the next one follows the new default. A template whose digest a policy forbids no longer fails issuance or approval with a 400: the signature yields to the policy, with a notice. Under an RSA CA, an EC `serverkeygen` request now gets P-256, not RSA-2048.
> - XCEP: ECDSA templates are announced as schema 3 with a request hash.
> - Revocation: migration 129 adds the `compromised_keys` table and fills it from the certificates revoked as compromised and from the revocation records holding such a key's digest. A replacing restore adds the archived keys and never removes one known here.
> - Revocation records written before migration 128 carry no key digest: they learn it when their certificate is deleted, and until then the certificate row itself answers.
> - ACME client: the renewal task now removes the orders left `pending` for more than 7 days whose order at the CA has expired or whose expiry is unknown, with their TXT records, and audits each removal.
> - DNS providers, ACME CA accounts and webhooks: the upgrade renames duplicate names to `name (2)`, `name (3)`, oldest first, then makes the name unique (migration 124).
> - ACME client: a renewal now keeps the certificate's id and refid, and `/renew` and the renewal logs no longer announce a new certificate id. Certificates that past renewals imported as new rows stay in the inventory: archive or delete them by hand.
> - Backups: archives now carry ACME client orders, approval requests and key recovery requests, and the duplicate orders migration 121 removes are removed again from the orders a restore writes. An archive written before this version leaves the rows here as they are.
> - Restore: an order renewed or being finalized here since the archive was taken is kept by a merge, with its certificate, pending key and owed revocations. A replacement puts the archived order and certificate back, and its result names the serial of the certificate given up, still valid at the CA, and warns that the restored one may have been revoked there.
> - Restore: an archive written before this version carries those settings as bare numbers. Restored on another installation they are emptied or left out, and must be chosen again; on the installation that wrote it, a number is kept while it still names one of the archived rows.
> - ACME client: orders stopped by the old limit of 5 failed renewals resume at one attempt a day, and orders with no failure count recorded, which were skipped, are renewed again. Turn off the automatic renewal of an order you no longer want renewed, or delete it.
> - Restore: a replacing restore now removes the CRLs, cached OCSP responses, sessions, in-flight ACME server orders, approval requests (from an archive without them), Microsoft CA requests, SAML replay entries and webhook or deployment deliveries (history included) that point at a removed row, detaches ACME client orders, SCEP requests, discovery results and revocation records from it, and cancels the key recovery requests still open on a removed certificate. The restore message and its audit entry list them.
> - Restore: `BACKUP_MAX_UPLOAD_MB` (default 512) is the restore upload's own ceiling, the decompressed content may be four times that, and the archive may hold one JSON object per 100 bytes of it; a reverse proxy in front of UCM keeps its own body limit. A restore holds the archive in memory, with a peak of several times its size.
> - Templates: the upgrade adds the `custom_extensions` column, empty for every existing template (migration 127).
> - mTLS: migration 130 makes client certificate enrolments unique per issuer and serial instead of serial alone, first filling a missing issuer from the stored certificate.
> …

## 2.249-5

- Fix immediate exit after “Executing command:” with nothing: Supervisor starts
  the app with an empty command, so upstream `exec "$@"` was a no-op. Default
  to upstream’s gunicorn CMD (also set in the Dockerfile). Bind-mount fallback
  + `/data/ucm-addon.log` diagnostics kept; still `SYS_ADMIN` + root.

## 2.249-4

- Run the upstream entrypoint as root. Dropping to UID 1000 made the process
  exit immediately when `/ssl` bind-mounts were not writable by `ucm`.

## 2.249-3

- Replace empty/white store icons with Ultimate CA Manager’s real brand mark
  (upstream `favicon.svg` / in-app Logo — orange U-shield).
- Refresh `apparmor.txt` (profile `ultimate-ca-manager` matching slug) so
  Supervisor loads the custom AppArmor profile.

## 2.249-2

- Fix start crash: upstream Docker VOLUMEs at `/opt/ucm/data` and `/etc/ucm`
  cannot be replaced with symlinks (`Device or resource busy`). Bind-mount
  `/ssl/ucm/{data,etc}` over them instead (`SYS_ADMIN`).

## 2.249-1

- Add **HTTPS certificate file** / **HTTPS private key file** options so the
  first-time config can point at PEM paths under `/ssl` (copied to UCM’s
  `https_cert.pem` / `https_key.pem` on each start).

## 2.249

- First Home Assistant app release wrapping
  [Ultimate CA Manager](https://github.com/NeySlim/ultimate-ca-manager)
  `v2.249`. Thin wrapper: options → env, PKI under `/ssl/ucm/` (symlinked at
  `/data/ucm`), auto-persisted `KEY_ENCRYPTION_KEY`, `exec` upstream
  entrypoint as `ucm`. Upstream tracked via `upstream_repo` + Docker Hub
  image gate. Standard image (not `-fips`).

> Upstream v2.249: https://github.com/NeySlim/ultimate-ca-manager/releases/tag/v2.249
