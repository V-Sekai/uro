# Patches for external dependencies
Dependencies below are version locked, you should test patch compatibility before updates.

## 0001-ex_marcel-fix-warning.patch
**Module:** `ex_marcel`

**Not required**, fixes persistent warning in logs https://github.com/chaskiq/ex-marcel/pull/2

## 0002-assent-base-header.patch
**Module:** `assent`

**Required** for Vroid OAuth, adds default headers to all `assent` requests.
Default headers are set in provider custom strategy using key `:base_headers`
