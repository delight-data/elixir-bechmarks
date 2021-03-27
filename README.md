# Benchmarks Elixir

Benchmarks to test some Elixir implementations.

```
asdf install
mix deps.get
mix run benchmarks/<name of the benchmark>
```

## String templating at runtime

During runtime, you receive a string (the template) where variables are encoded in it. You also receive a list of bindings.

The expected output is a list of strings of the same size of the list of bindings. Each of those strings corresponds to the template, with the variables replaced by the binding values.

I noticed that this issue is often resolved in two steps : prepare the template in some way, and then apply the bindings. In many use-cases, those two steps are ran at different times.
I therefore created a second bechmark, that only compares the methodes w.r.t. the time they take to apply the binding to the prepared template.
I differentiate both benchmarks by calling them _preparation included_ and _preparation excluded_.

### Example
Template : `"I like <%= music_genre %>, especially during <%= season %>."`

Bindings : `[[{:music_genre, "rock"}, {:season, "spring"}], [{:music_genre, "jazz"}, {:season, "summer"}]]`

Expected output : `["I like rock, especially during spring.", "I like jazz, especially during summer."]`

### Use cases
1. You are designing a webpage editor. Therefore, some HTML pages are created by your users. When displaying those pages, you want to replace context variables in the page.
You are in the _preparation excluded_ scenario, since you can prepare the template when it is uploaded by the user, and then only the time to bind the variables matters.

2. You are provided with a template email that you need to send immediatly to a thousand people. That email template contains recipient-specific variables.
Since you need to parse the template and send the emails immediately, you are in the _preparation included_ scenario : the preparation time matters.