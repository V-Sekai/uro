# Dialyzer ignore file for incomplete features and known dependency/opaque issues.
# Format: {file, warning_type} or {file, short_description} etc.
# See https://hexdocs.pm/dialyxir/readme.html#ignore-warnings

[
  # Ecto.Multi opaque type - pipeline passes struct between new/insert/update
  {"lib/uro/accounts.ex", :call_without_opaque},
  {"lib/uro/shared_content.ex", :call_without_opaque},
  {"lib/uro/user_content.ex", :call_without_opaque}
]
