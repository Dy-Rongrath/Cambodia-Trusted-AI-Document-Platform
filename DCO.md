# Developer Certificate of Origin (DCO)

To certify your contributions to the Cambodia Trusted AI Document Platform, include a `Signed-off-by` line in your Git commit message.

```text
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 Open Source Development Labs, Inc.
Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.


Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same license (unless I am permitted to submit
    under a different license), as indicated in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

---

## Project Sign-off Policy & Instructions

DCO sign-off is required by project contribution policy for all commits.

> **Status Notice:** DCO sign-off is required by project policy. Automated DCO validation (e.g., via a GitHub Action check bot) is not currently configured and may be added after Phase 1 if contribution volume justifies it.

### How to Sign-off Your Commits

Include a `Signed-off-by` line in your Git commit message body:

```text
Signed-off-by: Your Name <your.email@example.com>
```

You can automatically add this line to your commit message using the `-s` or `--signoff` option with `git commit`:

```bash
git commit -s -m "feat(auth): validate JWT audience claim"
```

By adding a `Signed-off-by` line, you confirm that you agree to the terms of the Developer Certificate of Origin 1.1 text above.
