import gleam/io
// import gleam/result.{try}
import gleam/hackney
import gleam/http.{Post}
import gleam/http/request
import gleam/http/response
// import gleeunit/should
import gleam/json.{object, string, int}
import gleam/otp/task.{async, await}

// https://api.openai.com/v1/chat/completions

// type Message {
//   Message(role, content)
// }

pub fn request(
  messages: json.Json,
) -> Result(response.Response(String), hackney.Error) {
  let assert Ok(request) =
    request.to("http://localhost:5000/v1/chat/completions")

  // let body =
  //   object([
  //     #(
  //       "messages",
  //       json.preprocessed_array([
  //         object([
  //           #("role", string("system")),
  //           #("content", string("you are a helpful assistant")),
  //         ]),
  //         object([#("role", string("user")), #("content", string("hello"))]),
  //       ]),
  //     ),
  //   ])

  let body = object([#("messages", messages), #("max_tokens", int(64))])
  io.println(
    body
    |> json.to_string(),
  )

  // Send the HTTP request to the server
  request
  |> request.set_method(Post)
  |> request.prepend_header("accept", "application/json")
  |> request.prepend_header("Content-Type", "application/json")
  |> request.set_body(
    body
    |> json.to_string(),
  )
  |> io.debug()
  |> hackney.send
}

pub fn main() {
  io.println("Hello from openai_api!")

  let assert Ok(response) =
    await(
      async(fn() {
        request(
          json.preprocessed_array([
            object([
              #("role", string("system")),
              #("content", string("you are a helpful assistant")),
            ]),
            object([#("role", string("user")), #("content", string("hello"))]),
          ]),
        )
      }),
      10_000,
    )

  response.body
  |> io.println()

  // We get a response record back
  // response.status
  // |> should.equal(200)

  // response
  // |> response.get_header("content-type")
  // |> should.equal(Ok("application/json"))

  Ok(response)
}
