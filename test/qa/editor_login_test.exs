defmodule Uro.QA.EditorLoginTest do
  use Uro.QA.Support.QACase

  test "Login with the editor", %{user: user, qa_password: password} do
    # POST /api/v1/session with user credentials
    conn =
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/api/v1/session", %{
        "user" => %{
          "email" => user.email,
          "password" => password
        }
      })

    conn = Endpoint.call(conn, [])

    assert conn.status == 200
    assert %{"data" => data} = Jason.decode!(conn.resp_body)
    assert is_binary(data["access_token"])
    assert is_map(data["user"])
    assert is_map(data["user_privilege_ruleset"])
  end
end
