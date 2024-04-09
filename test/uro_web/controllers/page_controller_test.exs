defmodule UroWeb.PageControllerTest do
  use UroWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    assert html_response(conn, 200) =~
             ~r/<!DOCTYPE html>\n<html lang="en">\n  <head>\n    <meta charset="utf-8"\/>\n    <meta http-equiv="X-UA-Compatible" content="IE=edge"\/>\n    <meta name="viewport" content="width=device-width, initial-scale=1.0"\/>\n    <title>Uro<\/title>\n    <link rel="stylesheet" href="\/css\/app.css"\/>\n    <link rel="shortcut icon" href="\/favicon.ico" type="image\/x-icon">\n    <link rel="icon" href="\/favicon.ico" type="image\/x-icon">\n<meta content="[^"]*" name="csrf-token">\n  <\/head>\n/
  end
end
