import gleam/io
import gleam/json.{object, string}
import gleam/otp/task.{async, await}
import gleam/result
import openai_api/chat
import openai_api/response
import openai_api/request as openai_request

pub fn main() {
  io.println("Hello from openai_api!")

  let assert Ok(response) =
    await(
      async(fn() {
        chat.completion(
          openai_request.OpenAi("http://localhost:5000"),
          json.preprocessed_array([
            object([
              #("role", string("system")),
              #("content", string("you are a helpful assistant")),
            ]),
            object([#("role", string("user")), #("content", string("hello"))]),
          ]),
        )
        |> result.map(fn(resp) {
          resp
          |> response.first_response()
          |> io.debug()
        })
      }),
      10_000,
    )

  Ok(response)
}
