import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  input
  |> string.to_graphemes()
  |> get_tokens([])
  |> list.reverse()
  |> list.map(fn(token) {
    case token {
      Mul(a, b) -> a * b
      _ -> 0
    }
  })
  |> list.fold(0, fn(acc, x) { acc + x })
}

pub fn pt_2(input: String) {
  let tokens =
    input
    |> string.to_graphemes()
    |> get_tokens([])
    |> list.reverse()
  eval(tokens, True, 0)
}

pub type Token {
  Mul(a: Int, b: Int)
  Do
  Dont
}

fn get_tokens(input, acc) {
  case input {
    ["m", "u", "l", "(", ..rest] -> {
      let #(tok, rest) = parse_mul(rest, "")
      case parse_token(tok) {
        Ok(tok) -> get_tokens(rest, [tok, ..acc])
        Error(_) -> get_tokens(rest, acc)
      }
    }
    ["d", "o", "(", ")", ..rest] -> get_tokens(rest, [Do, ..acc])
    ["d", "o", "n", "'", "t", "(", ")", ..rest] ->
      get_tokens(rest, [Dont, ..acc])
    [_, ..rest] -> get_tokens(rest, acc)

    [] -> acc
  }
}

fn is_digit(c: String) {
  case c {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

fn parse_mul(input, acc) {
  case input {
    [")", ..rest] -> #(acc, rest)
    [h, ..rest] -> {
      case is_digit(h) {
        True -> parse_mul(rest, acc <> h)
        False if h == "," -> parse_mul(rest, acc <> h)
        False -> #("", rest)
      }
    }
    _ -> #(acc, input)
  }
}

fn parse_token(token) {
  case string.split(token, ",") {
    [a, b] -> {
      let assert Ok(a) = int.parse(a)
      let assert Ok(b) = int.parse(b)
      Ok(Mul(a, b))
    }
    _ -> Error("invalid token")
  }
}

fn eval(tokens, enabled, acc) {
  case tokens {
    [tok, ..rest] -> {
      case tok {
        Mul(a, b) if enabled -> eval(rest, True, acc + a * b)
        Do -> eval(rest, True, acc)
        Dont -> eval(rest, False, acc)
        _ -> eval(rest, enabled, acc)
      }
    }
    [] -> acc
  }
}
