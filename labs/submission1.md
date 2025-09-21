# Benefits of signing commits

Signing commits using SSH or GPG provides:

-  Author authentication - confirms that the commit was made by the real owner of the key.
- Data integrity - ensures that the commit has not been modified after creation.
- Anti-forgery protection - eliminates the possibility of falsifying the project history.
- Verified label on GitHub - increases trust in the code and its origin.

GitHub keeps the signature verification forever, even if the key is later revoked or expires. SSH signature is easier to set up and can use an existing key.