defmodule Uro.QA.UploadWorldTest do
  use Uro.QA.Support.QACase

  test "Upload world", %{user: user, qa_password: password} do
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
    map_data_path = Path.expand("../../fixtures/map_data.bin", __DIR__)
    preview_path = Path.expand("../../fixtures/preview.jpg", __DIR__)

    # Build multipart body manually
    boundary = "----WebKitFormBoundary#{:rand.uniform(1_000_000)}"

    body_parts = [
      ~s(--#{boundary}\r\n),
      ~s(Content-Disposition: form-data; name="map[name]"\r\n\r\n),
      "Test World\r\n",
      ~s(--#{boundary}\r\n),
      ~s(Content-Disposition: form-data; name="map[description]"\r\n\r\n),
      "QA test world\r\n",
      ~s(--#{boundary}\r\n),
      ~s(Content-Disposition: form-data; name="map[user_content_data]"; filename="#{Path.basename(map_data_path)}"\r\n),
      ~s(Content-Type: application/octet-stream\r\n\r\n),
      File.read!(map_data_path),
      "\r\n",
      ~s(--#{boundary}\r\n),
      ~s(Content-Disposition: form-data; name="map[user_content_preview]"; filename="#{Path.basename(preview_path)}"\r\n),
      ~s(Content-Type: image/jpeg\r\n\r\n),
      File.read!(preview_path),
      "\r\n",
      ~s(--#{boundary}--\r\n)
    ]

    body = IO.iodata_to_binary(body_parts)

    # POST /api/v1/dashboard/maps with multipart
    conn =
      conn(:post, "/api/v1/dashboard/maps", body)
      |> put_req_header("authorization", "Bearer #{access_token}")
      |> put_req_header("content-type", "multipart/form-data; boundary=#{boundary}")
      |> put_req_header("content-length", Integer.to_string(byte_size(body)))

    conn = Endpoint.call(conn, [])

    assert conn.status == 200
    assert %{"data" => data} = Jason.decode!(conn.resp_body)
    assert is_binary(data["id"])
    assert %{"map" => map} = data
    assert is_map(map)
  end
end
