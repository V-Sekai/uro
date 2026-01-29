defmodule Uro.QA.UploadAvatarTest do
  use Uro.QA.Support.QACase

  test "Upload avatar", %{user: user, qa_password: password} do
    # First login to get access token
    login_conn =
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/api/v1/session", %{
        "user" => %{
          "email" => user.email,
          "password" => password
        }
      })

    login_conn = Endpoint.call(login_conn, [])
    assert login_conn.status == 200
    %{"data" => %{"access_token" => access_token}} = Jason.decode!(login_conn.resp_body)

    # Create Plug.Upload for multipart
    avatar_data_path = Path.expand("../../fixtures/avatar_data.bin", __DIR__)
    preview_path = Path.expand("../../fixtures/preview.jpg", __DIR__)

    # Build multipart body manually
    boundary = "----WebKitFormBoundary#{:rand.uniform(1_000_000)}"

    body_parts = [
      ~s(--#{boundary}\r\n),
      ~s(Content-Disposition: form-data; name="avatar[name]"\r\n\r\n),
      "Test Avatar\r\n",
      ~s(--#{boundary}\r\n),
      ~s(Content-Disposition: form-data; name="avatar[description]"\r\n\r\n),
      "QA test avatar\r\n",
      ~s(--#{boundary}\r\n),
      ~s(Content-Disposition: form-data; name="avatar[user_content_data]"; filename="#{Path.basename(avatar_data_path)}"\r\n),
      ~s(Content-Type: application/octet-stream\r\n\r\n),
      File.read!(avatar_data_path),
      "\r\n",
      ~s(--#{boundary}\r\n),
      ~s(Content-Disposition: form-data; name="avatar[user_content_preview]"; filename="#{Path.basename(preview_path)}"\r\n),
      ~s(Content-Type: image/jpeg\r\n\r\n),
      File.read!(preview_path),
      "\r\n",
      ~s(--#{boundary}--\r\n)
    ]

    body = IO.iodata_to_binary(body_parts)

    # POST /api/v1/dashboard/avatars with multipart
    conn =
      conn(:post, "/api/v1/dashboard/avatars", body)
      |> put_req_header("authorization", "Bearer #{access_token}")
      |> put_req_header("content-type", "multipart/form-data; boundary=#{boundary}")
      |> put_req_header("content-length", Integer.to_string(byte_size(body)))

    conn = Endpoint.call(conn, [])

    assert conn.status == 200
    assert %{"data" => data} = Jason.decode!(conn.resp_body)
    assert is_binary(data["id"])
    assert %{"avatar" => avatar} = data
    assert is_map(avatar)
  end
end
