# QA Tests List

## Authentication

- [ ] Login on the website
- [ ] Login with the editor
  - [ ] Upload avatar
  - [ ] Upload world

## Automation

These items are covered by API integration tests in the `test/qa/` directory. Run all QA tests with:

```bash
mix test test/qa/
```

Or run individual tests:

- `mix test test/qa/website_login_test.exs` - Login on the website
- `mix test test/qa/editor_login_test.exs` - Login with the editor
- `mix test test/qa/upload_avatar_test.exs` - Upload avatar
- `mix test test/qa/upload_world_test.exs` - Upload world

The tests use the existing PostgreSQL database configured in `config/test.exs` and create a test user with upload permissions for each test run. Shared test setup is in `test/qa/support/qa_case.ex`.
