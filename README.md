# Entitydown

Extract plain text and markup entities from Markdown text.

## Usage

```elixir
iex> Entitydown.extract "Hello, click [here](https://t.me/) to visit the Telegram official website."
{"Hello, click here to visit the Telegram official website.\n",
 [
   %Entitydown.Entity{
     type: :text_link,
     offset: 13,
     length: 4,
     url: "https://t.me/",
     language: nil
   }
 ]}

iex> Entitydown.extract "[_I am an italicized link_](https://t.me/)." # Nested
{"I am an italicized link.\n",
 [
   %Entitydown.Entity{
     type: :text_link,
     offset: 0,
     length: 23,
     url: "https://t.me/",
     language: nil
   },
   %Entitydown.Entity{
     type: :italic,
     offset: 0,
     length: 23,
     url: nil,
     language: nil
   }
 ]}
```

Its main purpose is to replace Telegram's support for Markdown because it lacks security (**which can easily lead to message sending failures**). This library converts Markdown text to secure entity parameters to avoid this issue.

This library is still under development and its support for Markdown is **not yet comprehensive**.
