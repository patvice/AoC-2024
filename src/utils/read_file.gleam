import gleam/io
import gleam/string
import simplifile

pub type ConfigError {
  ConfigError(message: String)
}

pub fn load_data(filename: String) -> Result(String, ConfigError) {
  open_file(filename)
}

pub fn load_data_or_panic(filename: String) -> String {
  case load_data(filename) {
    Ok(data) -> data
    Error(error) -> {
      io.println("Error: " <> error.message)
      panic
    }
  }
}

pub fn load_and_split_data(
  filename: String,
) -> Result(List(String), ConfigError) {
  case open_file(filename) {
    Ok(data) -> {
      let transformed = data |> string.trim |> string.split(on: "\n")
      Ok(transformed)
    }
    Error(_) -> Error(ConfigError(message: "Failed to read config file"))
  }
}

pub fn load_and_split_data_or_panic(filename: String) -> List(String) {
  case load_and_split_data(filename) {
    Ok(data) -> data
    Error(error) -> {
      io.println("Error: " <> error.message)
      panic
    }
  }
}

fn open_file(filename: String) -> Result(String, ConfigError) {
  case simplifile.read(filename) {
    Ok(data) -> Ok(data)
    Error(_) -> Error(ConfigError(message: "Failed to read config file"))
  }
}
