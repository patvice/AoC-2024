import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order}
import gleam/string
import utils/read_file

pub fn run() {
  let data = read_file.load_and_split_data_or_panic("./files/day2.txt")
  let parsed = parse_data(data)

  let part1_num = part1(parsed)
  io.println("Day 2: Part1 - " <> int.to_string(part1_num))

  let part2_num = part2(parsed)
  io.println("Day 2: Part2 - " <> int.to_string(part2_num))
}

fn parse_data(data: List(String)) -> List(List(Int)) {
  data
  |> list.map(fn(line) {
    line
    |> string.trim
    |> string.split(on: " ")
    |> list.map(fn(num_str: String) -> Int {
      let assert Ok(num) = int.parse(num_str)
      num
    })
  })
}

fn part1(data: List(List(Int))) -> Int {
  data |> list.count(is_report_safe)
}

fn part2(data: List(List(Int))) -> Int {
  data
  |> list.count(fn(report) {
    report
    |> list.combinations({ report |> list.length } - 1)
    |> list.any(is_report_safe)
  })
}

fn is_report_safe(report: List(Int)) -> Bool {
  let report_window_sets = report |> list.window_by_2

  [order.Lt, order.Gt]
  |> list.any(fn(compare) {
    report_window_sets |> list.all(is_window_set_safe(_, compare))
  })
}

fn is_window_set_safe(window: #(Int, Int), compare_order: Order) -> Bool {
  int.compare(window.0, window.1) == compare_order
  && int.absolute_value(window.0 - window.1) <= 3
}
