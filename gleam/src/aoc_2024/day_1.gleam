import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  let #(left, right) =
    input
    |> get_lists
    |> fn(lists) {
      #(list.sort(lists.0, int.compare), list.sort(lists.1, int.compare))
    }

  list.zip(left, right)
  |> list.map(fn(pair) { int.absolute_value(pair.0 - pair.1) })
  |> list.fold(0, fn(acc, x) { acc + x })
}

pub fn pt_2(input: String) {
  let #(left, right) = get_lists(input)

  let counts =
    list.fold(over: right, from: dict.new(), with: fn(acc, x) {
      dict.upsert(acc, x, fn(x) {
        case x {
          Some(x) -> x + 1
          None -> 1
        }
      })
    })

  left
  |> list.map(fn(x) {
    let c = dict.get(counts, x) |> result.unwrap(0)
    c * x
  })
  |> list.reduce(fn(acc, x) { acc + x })
  |> result.unwrap(0)
}

fn parse_row(row) {
  use #(left, row) <- result.try(
    row
    |> string.split(" ")
    |> list.pop(fn(_) { True }),
  )
  use right <- result.try(list.last(row))

  use left <- result.try(int.parse(left))
  use right <- result.try(int.parse(right))

  Ok(#(left, right))
}

fn get_lists(input) {
  input
  |> string.split("\n")
  |> list.fold(#([], []), fn(acc, row) {
    case parse_row(row) {
      Ok(#(left, right)) -> #([left, ..acc.0], [right, ..acc.1])
      Error(_) -> acc
    }
  })
}
