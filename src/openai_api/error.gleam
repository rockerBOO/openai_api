import gleam/json
import gleam/dynamic

pub type OpenAiError {
  DynamicError(dynamic.Dynamic)
  DecodeError(json.DecodeError)
}
