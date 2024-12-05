import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import utils/coord.{type Coord, Coord}
import utils/read_file

pub type Grid =
  Dict(Coord, String)

const max = 140

pub fn run() {
  let input = read_file.load_data_or_panic("files/day4.ex.txt")
  let parsed = parse(input)

  let result = part1(parsed)
  io.println("Day 4: Part 1 - " <> int.to_string(result))

  let result = part2(parsed)
  io.println("Day 4: Part 2 - " <> int.to_string(result))
}

fn parse(input: String) -> Grid {
  {
    use row, r <- list.index_map(string.split(input, "\n"))
    use col, c <- list.index_map(string.to_graphemes(row))
    #(Coord(r, c), col)
  }
  |> list.flatten
  |> dict.from_list
}

fn xmas_acc(grid: Grid, coord: Coord, acc: Int) -> Int {
  use <- bool.guard(coord.r == max, acc)
  use <- bool.lazy_guard(coord.c == max, fn() {
    xmas_acc(grid, coord.next_row(coord), acc)
  })
  case dict.get(grid, coord) {
    Ok("A") ->
      list.fold(coord.eight_directions, acc, fn(found, dir) {
        found + scan_for_word(grid, "MMAS", coord.go(coord, dir), dir)
      })
    _ -> acc
  }
  |> xmas_acc(grid, coord.next_col(coord), _)
}

fn scan_for_word(grid: Grid, word: String, coord: Coord, dir: Coord) {
  case string.pop_grapheme(word), dict.get(grid, coord) {
    Ok(#(first, "")), Ok(v) if first == v -> 1
    Ok(#(first, rest)), Ok(v) if first == v ->
      scan_for_word(grid, rest, coord.go(coord, dir), dir)
    _, _ -> 0
  }
}

fn part1(grid: Grid) -> Int {
  xmas_acc(grid, coord.origin, 0)
}

fn part2(grid: Grid) -> Int {
  xmas_dash_acc(grid, coord.origin, 0)
}

fn xmas_dash_acc(grid: Grid, coord: Coord, acc: Int) -> Int {
  use <- bool.guard(coord.r == max, acc)
  use <- bool.lazy_guard(coord.c == max, fn() {
    xmas_dash_acc(grid, coord.next_row(coord), acc)
  })

  case dict.get(grid, coord) {
    Ok("A") -> acc + find_xmas(grid, coord)
    _ -> acc
  }
  |> xmas_dash_acc(grid, coord.next_col(coord), _)
}

fn find_xmas(grid: Grid, coord: Coord) -> Int {
  let found =
    [Coord(-1, -1), Coord(1, 1), Coord(-1, 1), Coord(1, -1)]
    |> list.map(fn(dir) { dict.get(grid, coord.go(coord, dir)) })
    |> result.values()
    |> string.join("")

  case found {
    "MSMS" | "MSSM" | "SMSM" | "SMMS" -> 1
    _ -> 0
  }
}
