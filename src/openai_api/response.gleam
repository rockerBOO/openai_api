import gleam/list
import gleam/result

pub type Usage {
  Usage(prompt_tokens: Int, completion_tokens: Int, total_tokens: Int)
}

pub type Message {
  Message(role: String, content: String)
}

pub type Choice {
  Choice(index: Int, message: Message, finish_reason: String)
}

pub type OpenAiResponse {
  OpenAiResponse(
    id: String,
    object: String,
    created: Int,
    model: String,
    choices: List(Choice),
    usage: Usage,
  )
}

pub fn first_response(response: OpenAiResponse) -> Result(String, Nil) {
  case response {
    OpenAiResponse(_id, _object, _created, _model, choices, _usage) ->
      list.first(choices)
      |> result.map(fn(choice) {
        case choice {
          Choice(_index, message, _finish_reason) ->
            case message {
              Message(_type, content) -> {
                content
              }
            }
        }
      })
  }
}
