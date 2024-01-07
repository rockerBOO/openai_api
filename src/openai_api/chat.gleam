import gleam/json.{int, object}
import gleam/http.{Post}
import gleam/http/request
import gleam/httpc
import gleam/string
import gleam/dynamic.{field}
import gleam/io
import gleam/result
import openai_api/request as openai_request
import openai_api/response
import openai_api/error

pub fn completion(
  api: openai_request.OpenAi,
  messages: json.Json,
) -> Result(response.OpenAiResponse, error.OpenAiError) {
  let assert Ok(request) =
    request.to(string.concat([api.endpoint, "/v1/chat/completions"]))

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
  |> httpc.send()
  |> result.map_error(fn(e) { error.DynamicError(e) })
  |> result.map(fn(response) {
    response.body
    |> io.debug()
    |> json.decode(dynamic.decode6(
      response.OpenAiResponse,
      field("id", of: dynamic.string),
      field("object", of: dynamic.string),
      field("created", of: dynamic.int),
      field("model", of: dynamic.string),
      field(
        "choices",
        of: dynamic.list(dynamic.decode3(
          response.Choice,
          field("index", dynamic.int),
          field(
            "message",
            dynamic.decode2(
              response.Message,
              field("role", dynamic.string),
              field("content", dynamic.string),
            ),
          ),
          field("finish_reason", dynamic.string),
        )),
      ),
      field(
        "usage",
        of: dynamic.decode3(
          response.Usage,
          field("prompt_tokens", dynamic.int),
          field("completion_tokens", dynamic.int),
          field("total_tokens", dynamic.int),
        ),
      ),
    ))
    |> result.map_error(fn(e) { error.DecodeError(e) })
  })
  |> result.flatten()
}
