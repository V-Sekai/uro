defmodule Uro.QA.WebsiteLoginTest do
  use Uro.QA.Support.QACase

  test "Login on the website", %{user: user, qa_password: password} do
    # POST /api/v1/login with email/password
    conn =
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/api/v1/login", %{
        "email" => user.email,
        "password" => password
      })

    # Dispatch through endpoint and router
    conn = Endpoint.call(conn, [])

    assert conn.status == 200
    assert %{"data" => session_data} = Jason.decode!(conn.resp_body)
    assert is_map(session_data)
  end
end
