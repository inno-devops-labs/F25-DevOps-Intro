# Why Commit Signing is Crucial

Commit signing provides cryptographic verification for two critical security aspects in version control:

*   **Authenticity:** Proves that a commit actually originated from the claimed author, preventing identity spoofing in a system where `user.email` can be easily forged.

***Integrity:** Guarantees that the code and its metadata (message, timestamp, author information) remain unaltered since the commit was signed. Any modification will cause verification to fail.

This process establishes a verifiable chain of trust, protects against malicious code injection by unauthorized parties, and serves as a fundamental security practice for modern software supply chains. Platforms like GitHub and Bitbucket display a "Verified" badge for properly signed commits.