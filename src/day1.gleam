import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import utils/read_file

pub fn run() {
  let data = read_file.load_and_split_data_or_panic("./files/day1.txt")
  let one_list = format_join_list(data)
  let two_lists = format_data(data)

  let num = part_one(one_list)
  io.println("Part 1: " <> int.to_string(num))

  let num = part_two(two_lists)
  io.println("Part 2: " <> int.to_string(num))
}

fn format_data(data: List(String)) -> #(List(String), List(String)) {
  let two_lists = format_data_i(data, [], [])
  let first_list = list.sort(two_lists.0, by: string.compare)
  let second_list = list.sort(two_lists.1, by: string.compare)

  #(first_list, second_list)
}

fn format_join_list(data: List(String)) -> List(#(String, String)) {
  let lists = format_data(data)
  join_list(lists.0, lists.1)
}

fn join_list(list: List(String), list2: List(String)) -> List(#(String, String)) {
  case list {
    [] -> []
    [head, ..tail] -> {
      case list2 {
        [] -> []
        [head2, ..tail2] -> {
          [#(head, head2), ..join_list(tail, tail2)]
        }
      }
    }
  }
}

fn format_data_i(
  data: List(String),
  one: List(String),
  two: List(String),
) -> #(List(String), List(String)) {
  case data {
    [] -> #(one, two)
    [head, ..tail] -> {
      let parts = string.split(head, on: "   ")
      case parts {
        [first, second] ->
          format_data_i(
            tail,
            list.append(one, [first]),
            list.append(two, [second]),
          )
        [""] -> #(one, two)
        _ -> {
          io.println("Error: Invalid input:")
          io.debug(parts)

          panic
        }
      }
    }
  }
}

fn part_one(data: List(#(String, String))) -> Int {
  sum_list(data)
}

fn sum_list(list: List(#(String, String))) -> Int {
  case list {
    [] -> 0
    [head, ..tail] -> {
      let first = int.parse(head.0) |> result.unwrap(0)
      let second = int.parse(head.1) |> result.unwrap(0)

      let value = int.absolute_value(second - first)
      value + sum_list(tail)
    }
  }
}

pub fn part_two(data: #(List(String), List(String))) -> Int {
  count_repeat(data.0, data.1)
}

fn count_repeat(first: List(String), second: List(String)) -> Int {
  case first {
    [] -> 0
    [head, ..tail] -> {
      let instances = count_repeat_i(head, second, 0)

      let num = int.parse(head) |> result.unwrap(0)
      let product = instances * num
      product + count_repeat(tail, second)
    }
  }
}

fn count_repeat_i(id: String, list: List(String), count: Int) -> Int {
  case list {
    [] -> count
    [head, ..tail] -> {
      case id == head {
        True -> count_repeat_i(id, tail, count + 1)
        False -> count_repeat_i(id, tail, count)
      }
    }
  }
}
