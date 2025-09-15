A commit object points to a tree, contains parent commit, author/committer information with timestamps, GPG signature for verification, and the commit message.
A tree object represents a directory structure, listing files (blobs) and other trees with their permissions, object types, hashes, and names.
A blob object stores the actual content of a file without any metadata - just the raw data that was in the file when it was committed.
