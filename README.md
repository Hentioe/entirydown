# Entitydown

Extract plain text and markup entities from Markdown text.

## Usage

```elixir
iex> Entitydown.extract "Hello, click [here](https://t.me) to visit the Telegram official website."  
{"Hello, click here to visit the Telegram official website.\n",
 [
   %Entitydown.Entity{
     type: :text_link,
     offset: 13,
     length: 4,
     content: nil,
     url: "https://t.me",
     language: nil
   }
 ]}
```

Its main purpose is to replace Telegram's support for Markdown because it lacks security (**which can easily lead to message sending failures**). This library converts Markdown text to secure entity parameters to avoid this issue.

This library is still under development and its support for Markdown is **not yet comprehensive**.
