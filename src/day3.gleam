import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import utils/read_file

pub fn run() {
  let data = read_file.load_data_or_panic("./files/day3.txt")
  let values = parse(data)
  let result = part1(values)

  io.println("Day 3: Part1 - " <> result |> int.to_string)

  let values = parse2(data)
  let result = part2(values)

  io.println("Day 3: Part2 - " <> result |> int.to_string)
}

fn part1(data: List(#(Int, Int))) -> Int {
  let assert Ok(result) =
    data
    |> list.map(fn(value) { value.0 * value.1 })
    |> list.reduce(fn(acc, x) { acc + x })

  result
}

fn parse(data: String) -> List(#(Int, Int)) {
  let data = data |> string.trim |> string.to_graphemes
  parse_rec(data, [])
}

fn parse_rec(data: List(String), acc: List(#(Int, Int))) -> List(#(Int, Int)) {
  let three = data |> list.take(3)

  case three {
    ["m", "u", "l"] -> {
      let data = data |> list.drop(3)
      case proccess_mul(data, "") {
        Some(parsed) -> parse_rec(data, list.append(acc, [parsed]))
        None -> parse_rec(data, acc)
      }
    }
    _ -> {
      case data {
        [] -> acc
        [_, ..tail] -> parse_rec(tail, acc)
      }
    }
  }
}

fn parse2(data: String) -> List(#(Int, Int)) {
  let data = data |> string.trim |> string.to_graphemes
  parse_rec_enabled(data, [], True)
}

fn part2(data: List(#(Int, Int))) -> Int {
  let assert Ok(result) =
    data
    |> list.map(fn(value) { value.0 * value.1 })
    |> list.reduce(fn(acc, x) { acc + x })

  result
}

fn parse_rec_enabled(
  data: List(String),
  acc: List(#(Int, Int)),
  enabled: Bool,
) -> List(#(Int, Int)) {
  let found_mul = mul_parse(data, enabled)
  let found_enabled = enabled_parse(data)
  let found_disabled = disable_parse(data)

  case found_mul, found_enabled, found_disabled {
    True, False, False -> {
      let data = data |> list.drop(3)
      case proccess_mul(data, "") {
        Some(parsed) ->
          parse_rec_enabled(data, list.append(acc, [parsed]), enabled)
        None -> parse_rec_enabled(data, acc, enabled)
      }
    }
    False, True, False -> {
      let data = data |> list.drop(4)
      parse_rec_enabled(data, acc, True)
    }
    False, False, True -> {
      let data = data |> list.drop(7)
      parse_rec_enabled(data, acc, False)
    }
    _, _, _ -> {
      case data {
        [] -> acc
        [_, ..tail] -> parse_rec_enabled(tail, acc, enabled)
      }
    }
  }
}

fn mul_parse(data: List(String), enabled: Bool) -> Bool {
  let three = data |> list.take(3)

  case three {
    ["m", "u", "l"] ->
      case enabled {
        True -> True
        False -> False
      }
    _ -> False
  }
}

fn enabled_parse(data: List(String)) -> Bool {
  let four = data |> list.take(4)

  case four {
    ["d", "o", "(", ")"] -> {
      True
    }
    _ -> False
  }
}

fn disable_parse(data: List(String)) -> Bool {
  let seven = data |> list.take(7)

  case seven {
    ["d", "o", "n", "'", "t", "(", ")"] -> {
      True
    }
    _ -> False
  }
}

fn proccess_mul(data: List(String), buff: String) -> Option(#(Int, Int)) {
  let next = data |> list.take(1)
  let moved_list = data |> list.drop(1)

  case next {
    ["("] -> proccess_mul(moved_list, buff)
    [","] -> proccess_mul(moved_list, buff <> ",")
    [")"] -> {
      let parsed = buff |> string.split(on: ",") |> list.map(int.parse)
      let assert [Ok(first), Ok(second)] = parsed

      Some(#(first, second))
    }
    [num] -> {
      let parsed = num |> int.parse
      case parsed {
        Ok(_) -> proccess_mul(moved_list, buff <> num)
        Error(_) -> None
      }
    }
    _ -> None
  }
}
