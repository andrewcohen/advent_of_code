import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.fold(0, fn(acc, report) {
    let levels = parse(report)
    case is_report_safe(levels) {
      True -> acc + 1
      False -> acc
    }
  })
}

pub fn pt_2(input: String) {
  input
  |> string.split("\n")
  |> list.fold(0, fn(acc, report) {
    let levels = report |> parse

    case is_report_safe(levels) {
      True -> acc + 1
      False -> {
        let is_any_combo_safe =
          levels
          |> combinations_when_dropping_1
          |> list.any(is_report_safe)
        case is_any_combo_safe {
          True -> acc + 1
          False -> acc
        }
      }
    }
  })
}

fn combinations_when_dropping_1(items) {
  let range = list.range(0, list.length(items))
  let indexed = list.index_map(items, fn(x, i) { #(i, x) })

  range
  |> list.map(fn(i) {
    list.filter_map(indexed, fn(x) {
      let #(j, x) = x

      case i == j {
        False -> Ok(x)
        True -> Error("skip")
      }
    })
  })
}

fn is_diff_safe(a, b) {
  case int.absolute_value(a - b) {
    diff if diff >= 1 && diff <= 3 -> True
    _ -> False
  }
}

fn parse(report) {
  report
  |> string.split(" ")
  |> list.filter_map(int.parse)
}

fn analyze(levels: List(Int)) {
  levels
  |> list.window_by_2
  |> list.map(fn(x) {
    let #(a, b) = x

    let order = int.compare(a, b)
    #(order, is_diff_safe(a, b))
  })
}

fn is_report_safe(levels) {
  let orderings = analyze(levels)

  let is_any_unsafe_diff = list.any(orderings, fn(o) { !o.1 })
  case is_any_unsafe_diff {
    True -> False
    False -> {
      let assert [#(first_order, _), ..rest] = orderings
      list.all(rest, fn(x) { order.compare(first_order, with: x.0) == order.Eq })
    }
  }
}
