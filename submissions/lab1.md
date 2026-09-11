# Lab 1 submission
Signed commits help verify the identity of the person who created a commit and improve trust in the software supply chain. The xz-utils incident in March 2024 showed how dangerous compromised or malicious contributions can be, so verifying authorship and provenance is important. However, a valid signature does not guarantee that the code itself is safe, so code review and other security controls are still necessary.

## API checks

### Health check and initial notes

![GET /health and GET /notes responses](images/1.png)

### Create a note

![POST /notes response with the created note](images/2.png)

### List notes after creation

![GET /notes response including the new note](images/3.png)

## Commit signature verification

### Local verification

![git log --show-signature -1 showing a good signature](images/4.png)

### GitHub verification

![Commit marked Verified on GitHub](images/5.png)

## PR template

![PR template behavior](images/6.png)

The PR template is not auto-populated when opening a pull request to the upstream course repository. In my own fork, the template works correctly and is auto-populated as expected.
